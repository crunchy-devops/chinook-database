/*******************************************************************************
   Chinook Database - Massive Data Generation Script
   Script: 05_massive_playlists.sql
   Description: Generates thousands of playlists and millions of playlist-track relationships.
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
CREATE OR REPLACE FUNCTION generate_playlist_name() RETURNS TEXT AS $$
DECLARE
    adjectives TEXT[] := ARRAY['Ultimate', 'Best', 'Greatest', 'Top', 'Essential', 'Classic', 'Modern', 'Vintage', 'Epic', 'Legendary'];
    genres TEXT[] := ARRAY['Rock', 'Pop', 'Jazz', 'Classical', 'Electronic', 'Hip Hop', 'Country', 'Blues', 'Metal', 'Indie'];
    moods TEXT[] := ARRAY['Chill', 'Workout', 'Party', 'Study', 'Sleep', 'Road Trip', 'Romantic', 'Happy', 'Sad', 'Energetic'];
    times TEXT[] := ARRAY['Morning', 'Evening', 'Late Night', 'Weekend', 'Summer', 'Winter', 'Spring', 'Fall', 'All Time', 'Today'];
    patterns TEXT[] := ARRAY['% % Mix', '% % Hits', '% % Classics', '% % Essentials', '% % Favorites', 'My % %', 'The Best % %', '% % Collection'];
    pattern TEXT;
    word1 TEXT;
    word2 TEXT;
BEGIN
    pattern := patterns[floor(random() * array_length(patterns, 1)) + 1];
    
    CASE floor(random() * 4)
        WHEN 0 THEN 
            word1 := adjectives[floor(random() * array_length(adjectives, 1)) + 1];
            word2 := genres[floor(random() * array_length(genres, 1)) + 1];
        WHEN 1 THEN 
            word1 := moods[floor(random() * array_length(moods, 1)) + 1];
            word2 := genres[floor(random() * array_length(genres, 1)) + 1];
        WHEN 2 THEN 
            word1 := times[floor(random() * array_length(times, 1)) + 1];
            word2 := moods[floor(random() * array_length(moods, 1)) + 1];
        WHEN 3 THEN 
            word1 := adjectives[floor(random() * array_length(adjectives, 1)) + 1];
            word2 := moods[floor(random() * array_length(moods, 1)) + 1];
    END CASE;
    
    RETURN replace(pattern, '% %', word1 || ' ' || word2);
END;
$$ LANGUAGE plpgsql;

/*******************************************************************************
   Generate Massive Playlists (50,000 playlists)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 1000;
    total_playlists INT := 50000;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    RAISE NOTICE 'Starting generation of % playlists...', total_playlists;
    start_time := clock_timestamp();
    
    FOR i IN 1..(total_playlists / batch_size) LOOP
        INSERT INTO playlist (name)
        SELECT generate_playlist_name()
        FROM generate_series(1, batch_size);
        
        IF i % 10 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Generated % batches (% playlists, % seconds)...', i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining playlists
    IF total_playlists % batch_size > 0 THEN
        INSERT INTO playlist (name)
        SELECT generate_playlist_name()
        FROM generate_series(1, total_playlists % batch_size);
    END IF;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Playlist generation completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
END $$;

COMMIT;

/*******************************************************************************
   Generate Massive Playlist-Track Relationships (10,000,000 relationships) - OPTIMIZED
********************************************************************************/
DO $$
DECLARE
    total_playlist_tracks INT := 10000000;
    batch_size INT := 500000; -- 500k records per batch
    min_playlist_id INT;
    max_playlist_id INT;
    min_track_id INT;
    max_track_id INT;
    total_playlists INT;
    total_tracks INT;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    tracks_per_playlist_min INT := 10;
    avg_tracks_per_playlist NUMERIC;
BEGIN
    -- Get current counts and ID ranges
    SELECT COUNT(*) INTO total_playlists FROM playlist;
    SELECT COUNT(*) INTO total_tracks FROM track;
    SELECT MIN(playlist_id), MAX(playlist_id) INTO min_playlist_id, max_playlist_id FROM playlist;
    SELECT MIN(track_id), MAX(track_id) INTO min_track_id, max_track_id FROM track;
    
    avg_tracks_per_playlist := total_playlist_tracks::NUMERIC / total_playlists::NUMERIC;
    
    RAISE NOTICE 'Starting optimized playlist-track generation...';
    RAISE NOTICE 'Playlists: %, Tracks: %, Target relationships: %', total_playlists, total_tracks, total_playlist_tracks;
    RAISE NOTICE 'Average tracks per playlist: %', avg_tracks_per_playlist;
    start_time := clock_timestamp();
    
    -- Clear existing relationships
    DELETE FROM playlist_track;
    
    -- Batch INSERT with random distribution
    FOR i IN 1..CEIL(total_playlist_tracks::NUMERIC / batch_size::NUMERIC) LOOP
        INSERT INTO playlist_track (playlist_id, track_id)
        SELECT 
            -- Random playlist ID with weighted distribution
            min_playlist_id + floor(random() * (max_playlist_id - min_playlist_id + 1)) as playlist_id,
            -- Random track ID
            min_track_id + floor(random() * (max_track_id - min_track_id + 1)) as track_id
        FROM generate_series(1, LEAST(batch_size, total_playlist_tracks - (i-1) * batch_size))
        ON CONFLICT (playlist_id, track_id) DO NOTHING;
        
        -- Commit and report progress
        COMMIT;
        
        IF i % 5 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Batch % completed (% relationships, % seconds)...', 
                i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
        END IF;
    END LOOP;
    
    -- Ensure each playlist has at least some tracks
    INSERT INTO playlist_track (playlist_id, track_id)
    SELECT 
        p.playlist_id,
        min_track_id + floor(random() * (max_track_id - min_track_id + 1))
    FROM playlist p
    CROSS JOIN generate_series(1, tracks_per_playlist_min)
    ON CONFLICT (playlist_id, track_id) DO NOTHING
    WHERE NOT EXISTS (
        SELECT 1 FROM playlist_track pt 
        WHERE pt.playlist_id = p.playlist_id 
        LIMIT 1
    );
    
    COMMIT;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Optimized playlist-track generation completed in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
    
    -- Final verification
    RAISE NOTICE 'Final verification:';
    RAISE NOTICE 'Total playlist-track relationships: %', (SELECT COUNT(*) FROM playlist_track);
    RAISE NOTICE 'Playlists with tracks: %', 
        (SELECT COUNT(DISTINCT playlist_id) FROM playlist_track);
    RAISE NOTICE 'Average tracks per playlist: %', 
        (SELECT ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT playlist_id)::NUMERIC, 2) 
         FROM playlist_track);
END $$;

COMMIT;

/*******************************************************************************
   Generate Additional Random Playlist-Track Relationships (2,000,000 additional)
********************************************************************************/
DO $$
DECLARE
    batch_size INT := 50000;
    total_additional INT := 2000000;
    min_playlist_id INT;
    max_playlist_id INT;
    min_track_id INT;
    max_track_id INT;
    i INT;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Get ID ranges
    SELECT MIN(playlist_id), MAX(playlist_id) INTO min_playlist_id, max_playlist_id FROM playlist;
    SELECT MIN(track_id), MAX(track_id) INTO min_track_id, max_track_id FROM track;
    
    RAISE NOTICE 'Starting generation of % additional playlist-track relationships...', total_additional;
    start_time := clock_timestamp();
    
    FOR i IN 1..(total_additional / batch_size) LOOP
        INSERT INTO playlist_track (playlist_id, track_id)
        SELECT 
            floor(random() * (max_playlist_id - min_playlist_id + 1)) + min_playlist_id,
            floor(random() * (max_track_id - min_track_id + 1)) + min_track_id
        FROM generate_series(1, batch_size)
        ON CONFLICT DO NOTHING; -- Avoid duplicates
        
        IF i % 10 = 0 THEN
            end_time := clock_timestamp();
            RAISE NOTICE 'Generated % batches (% relationships, % seconds)...', i, i * batch_size, EXTRACT(EPOCH FROM (end_time - start_time));
            COMMIT;
        END IF;
    END LOOP;
    
    -- Handle remaining relationships
    IF total_additional % batch_size > 0 THEN
        INSERT INTO playlist_track (playlist_id, track_id)
        SELECT 
            floor(random() * (max_playlist_id - min_playlist_id + 1)) + min_playlist_id,
            floor(random() * (max_track_id - min_track_id + 1)) + min_track_id
        FROM generate_series(1, total_additional % batch_size)
        ON CONFLICT DO NOTHING;
    END IF;
    
    end_time := clock_timestamp();
    RAISE NOTICE 'Additional playlist-track relationships generated in % seconds!', EXTRACT(EPOCH FROM (end_time - start_time));
END $$;

COMMIT;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS generate_playlist_name();

-- Reset performance settings
SET synchronous_commit = ON;
SET wal_level = replica;
SET temp_buffers = '8MB';

-- Generate statistics
ANALYZE playlist;
ANALYZE playlist_track;

SELECT 'Massive playlists and playlist tracks generation completed!' as status,
       (SELECT COUNT(*) FROM playlist) as total_playlists,
       (SELECT COUNT(*) FROM playlist_track) as total_playlist_tracks,
       pg_size_pretty(pg_total_relation_size('playlist')) as playlist_table_size,
       pg_size_pretty(pg_total_relation_size('playlist_track')) as playlist_track_table_size;
