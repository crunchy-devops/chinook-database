/*******************************************************************************
   Chinook Database - Massive Data Generation Script
   Script: 02_massive_tracks.sql
   Description: Generates millions of tracks for the Chinook database.
   DB Server: PostgreSQL
   Author: Generated for extending Chinook database with massive dataset
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

-- Enable performance optimizations
SET synchronous_commit = OFF;
SET wal_level = minimal;
SET maintenance_work_mem = '512MB';
SET checkpoint_completion_target = 0.9;
SET temp_buffers = '256MB';

-- Create temporary functions for data generation
CREATE OR REPLACE FUNCTION generate_track_name() RETURNS TEXT AS $$
DECLARE
    adjectives TEXT[] := ARRAY['Electric', 'Acoustic', 'Digital', 'Analog', 'Modern', 'Classic', 'Vintage', 'Progressive', 'Alternative', 'Indie', 'Experimental', 'Electronic', 'Symphonic', 'Jazz', 'Blues', 'Rock', 'Pop', 'Folk', 'Country', 'Metal'];
    nouns TEXT[] := ARRAY['Dream', 'Echo', 'Wave', 'Shadow', 'Light', 'Voice', 'Sound', 'Melody', 'Harmony', 'Rhythm', 'Beat', 'Pulse', 'Vibration', 'Resonance', 'Frequency', 'Tone', 'Note', 'Chord', 'Scale', 'Key'];
    verbs TEXT[] := ARRAY['Dancing', 'Crying', 'Laughing', 'Dreaming', 'Awakening', 'Sleeping', 'Running', 'Walking', 'Flying', 'Falling', 'Rising', 'Breaking', 'Healing', 'Living', 'Dying', 'Loving', 'Hating', 'Waiting', 'Searching', 'Finding'];
    numbers TEXT[] := ARRAY['One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve'];
    patterns TEXT[] := ARRAY['% %', '% % %', '% % % %', 'The % %', '% of %', '% and %', '% in %', '% for %'];
    pattern TEXT;
    words TEXT[];
    result TEXT;
BEGIN
    pattern := patterns[floor(random() * array_length(patterns, 1)) + 1];
    
    CASE floor(random() * 4)
        WHEN 0 THEN words := ARRAY[adjectives[floor(random() * array_length(adjectives, 1)) + 1], nouns[floor(random() * array_length(nouns, 1)) + 1]];
        WHEN 1 THEN words := ARRAY[verbs[floor(random() * array_length(verbs, 1)) + 1], nouns[floor(random() * array_length(nouns, 1)) + 1]];
        WHEN 2 THEN words := ARRAY[adjectives[floor(random() * array_length(adjectives, 1)) + 1], verbs[floor(random() * array_length(verbs, 1)) + 1]];
        WHEN 3 THEN words := ARRAY[numbers[floor(random() * array_length(numbers, 1)) + 1], nouns[floor(random() * array_length(nouns, 1)) + 1]];
    END CASE;
    
    IF random() > 0.7 THEN
        words := words || numbers[floor(random() * array_length(numbers, 1)) + 1];
    END IF;
    
    result := array_to_string(words, ' ');
    
    IF length(result) > 200 THEN
        result := substring(result, 1, 200);
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_composer() RETURNS TEXT AS $$
DECLARE
    first_names TEXT[] := ARRAY['John', 'Jane', 'Michael', 'Sarah', 'David', 'Emma', 'Robert', 'Lisa', 'James', 'Jennifer', 'William', 'Maria', 'Richard', 'Patricia', 'Charles', 'Linda', 'Joseph', 'Barbara', 'Thomas', 'Susan'];
    last_names TEXT[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'];
    suffixes TEXT[] := ARRAY['Jr.', 'Sr.', 'II', 'III', 'IV', 'V'];
    result TEXT;
BEGIN
    result := first_names[floor(random() * array_length(first_names, 1)) + 1] || ' ' || last_names[floor(random() * array_length(last_names, 1)) + 1];
    
    IF random() > 0.8 THEN
        result := result || ' ' || suffixes[floor(random() * array_length(suffixes, 1)) + 1];
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Generate Massive Tracks (2,000,000 tracks)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 5000;
    total_tracks INT := 2000000;
    min_album_id INT;
    max_album_id INT;
    min_media_type_id INT;
    max_media_type_id INT;
    min_genre_id INT;
    max_genre_id INT;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Get ID ranges
    SELECT MIN(album_id), MAX(album_id) INTO min_album_id, max_album_id FROM album;
    SELECT MIN(media_type_id), MAX(media_type_id) INTO min_media_type_id, max_media_type_id FROM media_type;
    SELECT MIN(genre_id), MAX(genre_id) INTO min_genre_id, max_genre_id FROM genre;
    
    RAISE NOTICE 'Starting generation of % tracks...', total_tracks;
    start_time := clock_timestamp();
    
    FOR i IN 1..(total_tracks / batch_size) LOOP
        INSERT INTO track (name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price)
        SELECT 
            generate_track_name(),
            floor(random() * (max_album_id - min_album_id + 1)) + min_album_id,
            floor(random() * (max_media_type_id - min_media_type_id + 1)) + min_media_type_id,
            floor(random() * (max_genre_id - min_genre_id + 1)) + min_genre_id,
            CASE WHEN random() > 0.3 THEN generate_composer() ELSE NULL END,
            floor(random() * 300000) + 120000, -- 2-7 minutes in milliseconds
            floor(random() * 10000000) + 3000000, -- 3MB-13MB
            round((random() * 1.5 + 0.5)::numeric, 2) -- $0.50 to $2.00
        FROM generate_series(1, batch_size);
        
        IF i % 20 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Generated % batches (% tracks, % seconds)...', i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining tracks
    IF total_tracks % batch_size > 0 THEN
        INSERT INTO track (name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price)
        SELECT 
            generate_track_name(),
            floor(random() * (max_album_id - min_album_id + 1)) + min_album_id,
            floor(random() * (max_media_type_id - min_media_type_id + 1)) + min_media_type_id,
            floor(random() * (max_genre_id - min_genre_id + 1)) + min_genre_id,
            CASE WHEN random() > 0.3 THEN generate_composer() ELSE NULL END,
            floor(random() * 300000) + 120000,
            floor(random() * 10000000) + 3000000,
            round((random() * 1.5 + 0.5)::numeric, 2)
        FROM generate_series(1, total_tracks % batch_size);
    END IF;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Track generation completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
END $$;

COMMIT;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS generate_track_name();
DROP FUNCTION IF EXISTS generate_composer();

-- Reset performance settings
SET synchronous_commit = ON;
SET wal_level = replica;
SET temp_buffers = '8MB';

-- Generate statistics
ANALYZE track;

SELECT 'Massive tracks generation completed!' as status,
       (SELECT COUNT(*) FROM track) as total_tracks,
       pg_size_pretty(pg_total_relation_size('track')) as track_table_size;
