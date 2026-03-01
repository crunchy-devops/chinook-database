/*******************************************************************************
   Chinook Database - Massive Data Generation Script
   Script: 01_massive_artists_albums.sql
   Description: Generates thousands of artists and albums for the Chinook database.
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
CREATE OR REPLACE FUNCTION generate_random_name(prefix TEXT, max_length INT) RETURNS TEXT AS $$
DECLARE
    first_names TEXT[] := ARRAY['John', 'Jane', 'Michael', 'Sarah', 'David', 'Emma', 'Robert', 'Lisa', 'James', 'Jennifer', 'William', 'Maria', 'Richard', 'Patricia', 'Charles', 'Linda', 'Joseph', 'Barbara', 'Thomas', 'Susan'];
    last_names TEXT[] := ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'];
    adjectives TEXT[] := ARRAY['Electric', 'Acoustic', 'Digital', 'Analog', 'Modern', 'Classic', 'Vintage', 'Progressive', 'Alternative', 'Indie', 'Experimental', 'Electronic', 'Symphonic', 'Jazz', 'Blues', 'Rock', 'Pop', 'Folk', 'Country', 'Metal'];
    nouns TEXT[] := ARRAY['Dreams', 'Echoes', 'Waves', 'Shadows', 'Lights', 'Voices', 'Sounds', 'Melodies', 'Harmonies', 'Rhythms', 'Beats', 'Pulses', 'Vibrations', 'Resonance', 'Frequencies', 'Tones', 'Notes', 'Chords', 'Scales', 'Keys'];
    result TEXT;
BEGIN
    result := prefix || ' ' || first_names[floor(random() * array_length(first_names, 1)) + 1] || ' ' || last_names[floor(random() * array_length(last_names, 1)) + 1];
    IF length(result) > max_length THEN
        result := substring(result, 1, max_length);
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_album_title() RETURNS TEXT AS $$
DECLARE
    adjectives TEXT[] := ARRAY['Midnight', 'Sunrise', 'Sunset', 'Twilight', 'Dawn', 'Dusk', 'Nocturnal', 'Eternal', 'Infinite', 'Sacred', 'Forbidden', 'Lost', 'Found', 'Broken', 'Healing', 'Dancing', 'Crying', 'Laughing', 'Dreaming', 'Awakening'];
    nouns TEXT[] := ARRAY['Memories', 'Dreams', 'Echoes', 'Whispers', 'Shadows', 'Lights', 'Voices', 'Songs', 'Stories', 'Legends', 'Myths', 'Tales', 'Secrets', 'Mysteries', 'Adventures', 'Journeys', 'Paths', 'Roads', 'Bridges', 'Gates'];
    suffixes TEXT[] := ARRAY['', 'Volume 1', 'Volume 2', 'Part I', 'Part II', 'Revisited', 'Remastered', 'Deluxe Edition', 'Special Edition', 'Anniversary Edition'];
BEGIN
    RETURN adjectives[floor(random() * array_length(adjectives, 1)) + 1] || ' ' || nouns[floor(random() * array_length(nouns, 1)) + 1] || ' ' || suffixes[floor(random() * array_length(suffixes, 1)) + 1];
END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Generate Massive Artists (50,000 artists)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 1000;
    total_artists INT := 50000;
    artist_types TEXT[] := ARRAY['Band', 'Solo Artist', 'Duo', 'Trio', 'Quartet', 'Quintet', 'Orchestra', 'Ensemble', 'Choir', 'Collective'];
    i INT;
BEGIN
    RAISE NOTICE 'Starting generation of % artists...', total_artists;
    
    FOR i IN 1..(total_artists / batch_size) LOOP
        INSERT INTO artist (name)
        SELECT generate_random_name(artist_types[floor(random() * array_length(artist_types, 1)) + 1], 120)
        FROM generate_series(1, batch_size);
        
        IF i % 10 = 0 THEN
            RAISE NOTICE 'Generated % batches (% artists)...', i, i * batch_size;
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining artists
    IF total_artists % batch_size > 0 THEN
        INSERT INTO artist (name)
        SELECT generate_random_name(artist_types[floor(random() * array_length(artist_types, 1)) + 1], 120)
        FROM generate_series(1, total_artists % batch_size);
    END IF;
    
    RAISE NOTICE 'Artist generation completed!';
END $$;

COMMIT;

/*******************************************************************************
   Generate Massive Albums (200,000 albums)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 2000;
    total_albums INT := 200000;
    min_artist_id INT;
    max_artist_id INT;
    i INT;
BEGIN
    -- Get artist ID range
    SELECT MIN(artist_id), MAX(artist_id) INTO min_artist_id, max_artist_id FROM artist;
    
    RAISE NOTICE 'Starting generation of % albums...', total_albums;
    
    FOR i IN 1..(total_albums / batch_size) LOOP
        INSERT INTO album (title, artist_id)
        SELECT generate_album_title(), 
               floor(random() * (max_artist_id - min_artist_id + 1)) + min_artist_id
        FROM generate_series(1, batch_size);
        
        IF i % 10 = 0 THEN
            RAISE NOTICE 'Generated % batches (% albums)...', i, i * batch_size;
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining albums
    IF total_albums % batch_size > 0 THEN
        INSERT INTO album (title, artist_id)
        SELECT generate_album_title(), 
               floor(random() * (max_artist_id - min_artist_id + 1)) + min_artist_id
        FROM generate_series(1, total_albums % batch_size);
    END IF;
    
    RAISE NOTICE 'Album generation completed!';
END $$;

COMMIT;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS generate_random_name(TEXT, INT);
DROP FUNCTION IF EXISTS generate_album_title();

-- Reset performance settings
SET synchronous_commit = ON;
SET wal_level = replica;

-- Generate statistics
ANALYZE artist;
ANALYZE album;

SELECT 'Massive artists and albums generation completed!' as status,
       (SELECT COUNT(*) FROM artist) as total_artists,
       (SELECT COUNT(*) FROM album) as total_albums;
