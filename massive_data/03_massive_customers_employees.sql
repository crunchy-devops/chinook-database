/*******************************************************************************
   Chinook Database - Massive Data Generation Script
   Script: 03_massive_customers_employees.sql
   Description: Generates thousands of customers and employees for the Chinook database.
   DB Server: PostgreSQL
   Author: Generated for extending Chinook database with massive dataset
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

-- Enable performance optimizations
SET synchronous_commit = OFF;
SET wal_level = minimal;
SET maintenance_work_mem = '256MB';
SET checkpoint_completion_target = 0.9;

-- Create temporary functions for data generation
CREATE OR REPLACE FUNCTION generate_first_name() RETURNS TEXT AS $$
DECLARE
    first_names TEXT[] := ARRAY[
        'James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Charles', 'Joseph', 'Thomas',
        'Christopher', 'Daniel', 'Paul', 'Mark', 'Donald', 'Steven', 'Andrew', 'Joshua', 'Kenneth', 'Kevin',
        'Brian', 'George', 'Timothy', 'Ronald', 'Edward', 'Jason', 'Jeffrey', 'Ryan', 'Jacob', 'Gary',
        'Mary', 'Patricia', 'Jennifer', 'Linda', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Karen',
        'Lisa', 'Nancy', 'Betty', 'Helen', 'Sandra', 'Donna', 'Carol', 'Ruth', 'Sharon', 'Michelle',
        'Laura', 'Sarah', 'Kimberly', 'Ashley', 'Amanda', 'Melissa', 'Deborah', 'Stephanie', 'Rebecca', 'Sharon',
        'Laura', 'Cynthia', 'Kathleen', 'Amy', 'Angela', 'Brenda', 'Emma', 'Olivia', 'Catherine', 'Samantha'
    ];
BEGIN
    RETURN first_names[floor(random() * array_length(first_names, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_last_name() RETURNS TEXT AS $$
DECLARE
    last_names TEXT[] := ARRAY[
        'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
        'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
        'Lee', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Young',
        'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams',
        'Baker', 'Nelson', 'Carter', 'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker',
        'Evans', 'Edwards', 'Collins', 'Stewart', 'Morris', 'Rogers', 'Reed', 'Cook', 'Morgan', 'Bell'
    ];
BEGIN
    RETURN last_names[floor(random() * array_length(last_names, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_company_name() RETURNS TEXT AS $$
DECLARE
    prefixes TEXT[] := ARRAY['Global', 'International', 'Universal', 'Worldwide', 'National', 'Regional', 'Local', 'Digital', 'Tech', 'Innovation'];
    suffixes TEXT[] := ARRAY['Inc', 'Corp', 'Ltd', 'LLC', 'Co', 'Group', 'Enterprises', 'Solutions', 'Systems', 'Technologies'];
    industries TEXT[] := ARRAY['Music', 'Entertainment', 'Media', 'Technology', 'Digital', 'Creative', 'Arts', 'Production', 'Recording', 'Broadcasting'];
BEGIN
    IF random() > 0.4 THEN
        RETURN prefixes[floor(random() * array_length(prefixes, 1)) + 1] || ' ' || 
               industries[floor(random() * array_length(industries, 1)) + 1] || ' ' ||
               suffixes[floor(random() * array_length(suffixes, 1)) + 1];
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_address() RETURNS TEXT AS $$
DECLARE
    numbers TEXT[] := ARRAY['123', '456', '789', '321', '654', '987', '147', '258', '369', '741'];
    streets TEXT[] := ARRAY['Main St', 'Oak Ave', 'Elm St', 'Pine Rd', 'Maple Dr', 'Cedar Ln', 'Washington Blvd', 'Lincoln Ave', 'Park St', 'Walnut St'];
    types TEXT[] := ARRAY['St', 'Ave', 'Rd', 'Dr', 'Ln', 'Blvd', 'Ct', 'Pl', 'Way', 'Terrace'];
BEGIN
    RETURN numbers[floor(random() * array_length(numbers, 1)) + 1] || ' ' ||
           streets[floor(random() * array_length(streets, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_city() RETURNS TEXT AS $$
DECLARE
    cities TEXT[] := ARRAY[
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego',
        'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte', 'San Francisco',
        'Indianapolis', 'Seattle', 'Denver', 'Washington', 'Boston', 'El Paso', 'Nashville', 'Detroit',
        'Oklahoma City', 'Portland', 'Las Vegas', 'Memphis', 'Louisville', 'Baltimore', 'Milwaukee', 'Albuquerque',
        'Tucson', 'Fresno', 'Sacramento', 'Kansas City', 'Mesa', 'Atlanta', 'Omaha', 'Colorado Springs',
        'Raleigh', 'Long Beach', 'Virginia Beach', 'Miami', 'Oakland', 'Minneapolis', 'Tampa', 'Tulsa'
    ];
BEGIN
    RETURN cities[floor(random() * array_length(cities, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_state() RETURNS TEXT AS $$
DECLARE
    states TEXT[] := ARRAY[
        'CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI',
        'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'WI',
        'CO', 'MN', 'SC', 'AL', 'LA', 'KY', 'OR', 'OK', 'CT', 'UT',
        'IA', 'NV', 'AR', 'MS', 'KS', 'NM', 'NE', 'ID', 'WV', 'HI',
        'NH', 'ME', 'MT', 'RI', 'DE', 'SD', 'ND', 'AK', 'VT', 'WY'
    ];
BEGIN
    RETURN states[floor(random() * array_length(states, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_country() RETURNS TEXT AS $$
DECLARE
    countries TEXT[] := ARRAY[
        'USA', 'Canada', 'United Kingdom', 'Germany', 'France', 'Australia', 'Japan', 'Brazil',
        'India', 'China', 'Mexico', 'Spain', 'Italy', 'Netherlands', 'Sweden', 'Norway',
        'Denmark', 'Finland', 'Belgium', 'Switzerland', 'Austria', 'Ireland', 'New Zealand',
        'South Korea', 'Singapore', 'Hong Kong', 'Taiwan', 'Israel', 'UAE', 'Saudi Arabia', 'South Africa'
    ];
BEGIN
    RETURN countries[floor(random() * array_length(countries, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_postal_code() RETURNS TEXT AS $$
DECLARE
    zip_codes TEXT[] := ARRAY[
        '10001', '90210', '60601', '33101', '85001', '19101', '78201', '92101',
        '75201', '98101', '80201', '32801', '94102', '60611', '30301', '77001',
        '55401', '44101', '38103', '63101', '40201', '97201', '46201', '72201',
        '98601', '83701', '53201', '37201', '27601', '28201', '80301', '84101'
    ];
BEGIN
    RETURN zip_codes[floor(random() * array_length(zip_codes, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_phone() RETURNS TEXT AS $$
DECLARE
    area_codes TEXT[] := ARRAY['212', '310', '312', '415', '617', '646', '718', '917', '202', '305'];
    exchange TEXT;
    number TEXT;
BEGIN
    exchange := lpad(floor(random() * 1000)::text, 3, '0');
    number := lpad(floor(random() * 10000)::text, 4, '0');
    RETURN '+1 (' || area_codes[floor(random() * array_length(area_codes, 1)) + 1] || ') ' || exchange || '-' || number;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_email(first_name TEXT, last_name TEXT) RETURNS TEXT AS $$
DECLARE
    domains TEXT[] := ARRAY['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com', 'icloud.com', 'mail.com', 'protonmail.com'];
    separators TEXT[] := ARRAY['.', '_', '-', ''];
    separator TEXT;
BEGIN
    separator := separators[floor(random() * array_length(separators, 1)) + 1];
    RETURN lower(first_name || separator || last_name || floor(random() * 1000)::text || '@' || domains[floor(random() * array_length(domains, 1)) + 1]);
END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Generate Massive Customers (100,000 customers)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 2000;
    total_customers INT := 100000;
    min_employee_id INT;
    max_employee_id INT;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Get employee ID range for support_rep_id
    SELECT MIN(employee_id), MAX(employee_id) INTO min_employee_id, max_employee_id FROM employee WHERE title LIKE '%Sales%';
    
    RAISE NOTICE 'Starting generation of % customers...', total_customers;
    start_time := clock_timestamp();
    
    FOR i IN 1..(total_customers / batch_size) LOOP
        INSERT INTO customer (first_name, last_name, company, address, city, state, country, postal_code, phone, fax, email, support_rep_id)
        SELECT 
            generate_first_name(),
            generate_last_name(),
            generate_company_name(),
            generate_address(),
            generate_city(),
            generate_state(),
            generate_country(),
            generate_postal_code(),
            generate_phone(),
            CASE WHEN random() > 0.7 THEN generate_phone() ELSE NULL END,
            generate_email(generate_first_name(), generate_last_name()),
            CASE WHEN min_employee_id IS NOT NULL THEN floor(random() * (max_employee_id - min_employee_id + 1)) + min_employee_id ELSE NULL END
        FROM generate_series(1, batch_size);
        
        IF i % 10 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Generated % batches (% customers, % seconds)...', i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining customers
    IF total_customers % batch_size > 0 THEN
        INSERT INTO customer (first_name, last_name, company, address, city, state, country, postal_code, phone, fax, email, support_rep_id)
        SELECT 
            generate_first_name(),
            generate_last_name(),
            generate_company_name(),
            generate_address(),
            generate_city(),
            generate_state(),
            generate_country(),
            generate_postal_code(),
            generate_phone(),
            CASE WHEN random() > 0.7 THEN generate_phone() ELSE NULL END,
            generate_email(generate_first_name(), generate_last_name()),
            CASE WHEN min_employee_id IS NOT NULL THEN floor(random() * (max_employee_id - min_employee_id + 1)) + min_employee_id ELSE NULL END
        FROM generate_series(1, total_customers % batch_size);
    END IF;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Customer generation completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
END $$;

COMMIT;

/*******************************************************************************
   Generate Additional Employees (50 employees)
********************************************************************************/
DO $$
DECLARE
    titles TEXT[] := ARRAY['Sales Manager', 'Sales Support Agent', 'IT Manager', 'IT Staff', 'General Manager', 'Marketing Manager', 'Finance Manager'];
    i INT;
BEGIN
    RAISE NOTICE 'Starting generation of 50 additional employees...';
    
    FOR i IN 1..50 LOOP
        INSERT INTO employee (last_name, first_name, title, reports_to, birth_date, hire_date, address, city, state, country, postal_code, phone, fax, email)
        VALUES (
            generate_last_name(),
            generate_first_name(),
            titles[floor(random() * array_length(titles, 1)) + 1],
            CASE WHEN random() > 0.5 THEN (SELECT employee_id FROM employee ORDER BY random() LIMIT 1) ELSE NULL END,
            '1970-01-01'::date + (floor(random() * 365 * 40) || ' days')::interval,
            '2020-01-01'::date + (floor(random() * 365 * 4) || ' days')::interval,
            generate_address(),
            generate_city(),
            generate_state(),
            generate_country(),
            generate_postal_code(),
            generate_phone(),
            CASE WHEN random() > 0.7 THEN generate_phone() ELSE NULL END,
            generate_email(generate_first_name(), generate_last_name())
        );
    END LOOP;
    
    RAISE NOTICE 'Employee generation completed!';
END $$;

COMMIT;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS generate_first_name();
DROP FUNCTION IF EXISTS generate_last_name();
DROP FUNCTION IF EXISTS generate_company_name();
DROP FUNCTION IF EXISTS generate_address();
DROP FUNCTION IF EXISTS generate_city();
DROP FUNCTION IF EXISTS generate_state();
DROP FUNCTION IF EXISTS generate_country();
DROP FUNCTION IF EXISTS generate_postal_code();
DROP FUNCTION IF EXISTS generate_phone();
DROP FUNCTION IF EXISTS generate_email();

-- Reset performance settings
SET synchronous_commit = ON;
SET wal_level = replica;

-- Generate statistics
ANALYZE customer;
ANALYZE employee;

SELECT 'Massive customers and employees generation completed!' as status,
       (SELECT COUNT(*) FROM customer) as total_customers,
       (SELECT COUNT(*) FROM employee) as total_employees;
