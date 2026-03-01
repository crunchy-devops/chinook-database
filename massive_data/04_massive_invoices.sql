/*******************************************************************************
   Chinook Database - Massive Data Generation Script
   Script: 04_massive_invoices.sql
   Description: Generates millions of invoices and invoice lines for the Chinook database.
   DB Server: PostgreSQL
   Author: Generated for extending Chinook database with massive dataset
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

-- Enable performance optimizations
SET synchronous_commit = OFF;
--SET wal_level = minimal;
SET maintenance_work_mem = '1GB';
--SET checkpoint_completion_target = 0.9;
SET temp_buffers = '512MB';
SET work_mem = '256MB';

-- Create temporary functions for data generation
CREATE OR REPLACE FUNCTION generate_invoice_date() RETURNS TIMESTAMP AS $$
DECLARE
    base_date TIMESTAMP := '2020-01-01'::timestamp;
    days_offset INT;
    seconds_offset INT;
BEGIN
    days_offset := floor(random() * 1460); -- 4 years worth of days
    seconds_offset := floor(random() * 86400); -- Random time of day
    RETURN base_date + (days_offset || ' days')::interval + (seconds_offset || ' seconds')::interval;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_billing_address() RETURNS TEXT AS $$
DECLARE
    numbers TEXT[] := ARRAY['123', '456', '789', '321', '654', '987', '147', '258', '369', '741'];
    streets TEXT[] := ARRAY['Main St', 'Oak Ave', 'Elm St', 'Pine Rd', 'Maple Dr', 'Cedar Ln', 'Washington Blvd', 'Lincoln Ave', 'Park St', 'Walnut St'];
    types TEXT[] := ARRAY['St', 'Ave', 'Rd', 'Dr', 'Ln', 'Blvd', 'Ct', 'Pl', 'Way', 'Terrace'];
BEGIN
    RETURN numbers[floor(random() * array_length(numbers, 1)) + 1] || ' ' ||
           streets[floor(random() * array_length(streets, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_billing_city() RETURNS TEXT AS $$
DECLARE
    cities TEXT[] := ARRAY[
        'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego',
        'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte', 'San Francisco',
        'Indianapolis', 'Seattle', 'Denver', 'Washington', 'Boston', 'El Paso', 'Nashville', 'Detroit',
        'Oklahoma City', 'Portland', 'Las Vegas', 'Memphis', 'Louisville', 'Baltimore', 'Milwaukee', 'Albuquerque'
    ];
BEGIN
    RETURN cities[floor(random() * array_length(cities, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_billing_state() RETURNS TEXT AS $$
DECLARE
    states TEXT[] := ARRAY[
        'CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI',
        'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'WI',
        'CO', 'MN', 'SC', 'AL', 'LA', 'KY', 'OR', 'OK', 'CT', 'UT'
    ];
BEGIN
    RETURN states[floor(random() * array_length(states, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_billing_country() RETURNS TEXT AS $$
DECLARE
    countries TEXT[] := ARRAY[
        'USA', 'Canada', 'United Kingdom', 'Germany', 'France', 'Australia', 'Japan', 'Brazil',
        'India', 'China', 'Mexico', 'Spain', 'Italy', 'Netherlands', 'Sweden', 'Norway'
    ];
BEGIN
    RETURN countries[floor(random() * array_length(countries, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_billing_postal_code() RETURNS TEXT AS $$
DECLARE
    zip_codes TEXT[] := ARRAY[
        '10001', '90210', '60601', '33101', '85001', '19101', '78201', '92101',
        '75201', '98101', '80201', '32801', '94102', '60611', '30301', '77001'
    ];
BEGIN
    RETURN zip_codes[floor(random() * array_length(zip_codes, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Generate Massive Invoices (500,000 invoices)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 10000;
    total_invoices INT := 500000;
    min_customer_id INT;
    max_customer_id INT;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Get customer ID range
    SELECT MIN(customer_id), MAX(customer_id) INTO min_customer_id, max_customer_id FROM customer;
    
    RAISE NOTICE 'Starting generation of % invoices...', total_invoices;
    start_time := clock_timestamp();
    
    FOR i IN 1..(total_invoices / batch_size) LOOP
        INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total)
        SELECT 
            floor(random() * (max_customer_id - min_customer_id + 1)) + min_customer_id,
            generate_invoice_date(),
            generate_billing_address(),
            generate_billing_city(),
            generate_billing_state(),
            generate_billing_country(),
            generate_billing_postal_code(),
            round((random() * 50 + 5)::numeric, 2) -- $5.00 to $55.00
        FROM generate_series(1, batch_size);
        
        IF i % 5 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Generated % batches (% invoices, % seconds)...', i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining invoices
    IF total_invoices % batch_size > 0 THEN
        INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total)
        SELECT 
            floor(random() * (max_customer_id - min_customer_id + 1)) + min_customer_id,
            generate_invoice_date(),
            generate_billing_address(),
            generate_billing_city(),
            generate_billing_state(),
            generate_billing_country(),
            generate_billing_postal_code(),
            round((random() * 50 + 5)::numeric, 2)
        FROM generate_series(1, total_invoices % batch_size);
    END IF;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Invoice generation completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
END $$;

COMMIT;

/*******************************************************************************
   Generate Massive Invoice Lines (5,000,000 invoice lines)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 50000;
    total_invoice_lines INT := 5000000;
    min_invoice_id INT;
    max_invoice_id INT;
    min_track_id INT;
    max_track_id INT;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Get ID ranges
    SELECT MIN(invoice_id), MAX(invoice_id) INTO min_invoice_id, max_invoice_id FROM invoice;
    SELECT MIN(track_id), MAX(track_id) INTO min_track_id, max_track_id FROM track;
    
    RAISE NOTICE 'Starting generation of % invoice lines...', total_invoice_lines;
    start_time := clock_timestamp();
    
    FOR i IN 1..(total_invoice_lines / batch_size) LOOP
        INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
        SELECT 
            floor(random() * (max_invoice_id - min_invoice_id + 1)) + min_invoice_id,
            floor(random() * (max_track_id - min_track_id + 1)) + min_track_id,
            round((random() * 2 + 0.5)::numeric, 2), -- $0.50 to $2.50
            floor(random() * 3) + 1 -- 1 to 3 quantity
        FROM generate_series(1, batch_size);
        
        IF i % 10 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Generated % batches (% invoice lines, % seconds)...', i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining invoice lines
    IF total_invoice_lines % batch_size > 0 THEN
        INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity)
        SELECT 
            floor(random() * (max_invoice_id - min_invoice_id + 1)) + min_invoice_id,
            floor(random() * (max_track_id - min_track_id + 1)) + min_track_id,
            round((random() * 2 + 0.5)::numeric, 2),
            floor(random() * 3) + 1
        FROM generate_series(1, total_invoice_lines % batch_size);
    END IF;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Invoice line generation completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
END $$;

COMMIT;

-- Update invoice totals based on their invoice lines (Optimized Version)
DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    total_invoices INT;
    total_invoice_lines INT;
BEGIN
    -- Get current counts
    SELECT COUNT(*) INTO total_invoices FROM invoice;
    SELECT COUNT(*) INTO total_invoice_lines FROM invoice_line;
    
    RAISE NOTICE 'Starting optimized invoice totals update...';
    RAISE NOTICE 'Invoices: %, Invoice Lines: %', total_invoices, total_invoice_lines;
    start_time := clock_timestamp();
    
    -- Fast update using JOIN aggregation
    UPDATE invoice i
    SET total = subquery.line_total
    FROM (
        SELECT 
            invoice_id,
            COALESCE(SUM(unit_price * quantity), 0) as line_total
        FROM invoice_line
        GROUP BY invoice_id
    ) subquery
    WHERE i.invoice_id = subquery.invoice_id;
    
    -- Handle invoices with no lines (should be 0)
    UPDATE invoice 
    SET total = 0 
    WHERE invoice_id NOT IN (SELECT DISTINCT invoice_id FROM invoice_line);
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Optimized invoice totals update completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
    
    -- Verify results
    RAISE NOTICE 'Verification: % invoices updated, % with zero total', 
        (SELECT COUNT(*) FROM invoice WHERE total > 0),
        (SELECT COUNT(*) FROM invoice WHERE total = 0);
END $$;

COMMIT;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS generate_invoice_date();
DROP FUNCTION IF EXISTS generate_billing_address();
DROP FUNCTION IF EXISTS generate_billing_city();
DROP FUNCTION IF EXISTS generate_billing_state();
DROP FUNCTION IF EXISTS generate_billing_country();
DROP FUNCTION IF EXISTS generate_billing_postal_code();

-- Reset performance settings
SET synchronous_commit = ON;
--SET wal_level = replica;
SET temp_buffers = '8MB';
SET work_mem = '4MB';

-- Generate statistics
ANALYZE invoice;
ANALYZE invoice_line;

SELECT 'Massive invoices and invoice lines generation completed!' as status,
       (SELECT COUNT(*) FROM invoice) as total_invoices,
       (SELECT COUNT(*) FROM invoice_line) as total_invoice_lines,
       pg_size_pretty(pg_total_relation_size('invoice')) as invoice_table_size,
       pg_size_pretty(pg_total_relation_size('invoice_line')) as invoice_line_table_size;
