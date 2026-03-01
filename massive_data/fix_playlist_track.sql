/*******************************************************************************
   Chinook Database - Playlist Track Fix
   Script: fix_playlist_track.sql
   Description: Populates playlist_track table with sample data.
   Author: Generated for Chinook database quick fix
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

DO $$
DECLARE
    min_playlist_id INT;
    max_playlist_id INT;
    min_track_id INT;
    max_track_id INT;
    playlist_count INT;
    track_count INT;
    relationships_to_create INT;
    i INT;
BEGIN
    -- Check current state
    SELECT COUNT(*) INTO playlist_count FROM playlist;
    SELECT COUNT(*) INTO track_count FROM track;
    
    RAISE NOTICE 'Current state: % playlists, % tracks', playlist_count, track_count;
    
    -- Get ID ranges
    SELECT MIN(playlist_id), MAX(playlist_id) INTO min_playlist_id, max_playlist_id FROM playlist;
    SELECT MIN(track_id), MAX(track_id) INTO min_track_id, max_track_id FROM track;
    
    -- If no playlists or tracks, create some sample data first
    IF playlist_count = 0 THEN
        RAISE NOTICE 'Creating sample playlists...';
        INSERT INTO playlist (name) VALUES
            ('Music'), ('Movies'), ('TV Shows'), ('90''s Music'), ('Audiobooks'),
            ('Classical'), ('Rock Classics'), ('Pop Hits'), ('Jazz Essentials'), ('Hip Hop');
        
        SELECT MIN(playlist_id), MAX(playlist_id) INTO min_playlist_id, max_playlist_id FROM playlist;
        playlist_count := 10;
    END IF;
    
    IF track_count = 0 THEN
        RAISE NOTICE 'Creating sample tracks...';
        -- First ensure we have artists and albums
        IF NOT EXISTS (SELECT 1 FROM artist LIMIT 1) THEN
            INSERT INTO artist (name) VALUES ('Sample Artist');
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM album LIMIT 1) THEN
            INSERT INTO album (title, artist_id) VALUES ('Sample Album', 1);
        END IF;
        
        -- Ensure we have genres and media types
        IF NOT EXISTS (SELECT 1 FROM genre LIMIT 1) THEN
            INSERT INTO genre (name) VALUES ('Rock');
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM media_type LIMIT 1) THEN
            INSERT INTO media_type (name) VALUES ('MPEG audio file');
        END IF;
        
        INSERT INTO track (name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price) VALUES
            ('Sample Track 1', 1, 1, 1, 'Sample Composer', 180000, 5000000, 0.99),
            ('Sample Track 2', 1, 1, 1, 'Sample Composer', 200000, 6000000, 0.99),
            ('Sample Track 3', 1, 1, 1, 'Sample Composer', 220000, 7000000, 0.99),
            ('Sample Track 4', 1, 1, 1, 'Sample Composer', 190000, 5500000, 0.99),
            ('Sample Track 5', 1, 1, 1, 'Sample Composer', 210000, 6500000, 0.99);
        
        SELECT MIN(track_id), MAX(track_id) INTO min_track_id, max_track_id FROM track;
        track_count := 5;
    END IF;
    
    -- Get final ID ranges
    SELECT MIN(playlist_id), MAX(playlist_id) INTO min_playlist_id, max_playlist_id FROM playlist;
    SELECT MIN(track_id), MAX(track_id) INTO min_track_id, max_track_id FROM track;
    
    RAISE NOTICE 'ID ranges - Playlists: % to %, Tracks: % to %', 
        min_playlist_id, max_playlist_id, min_track_id, max_track_id;
    
    -- Create playlist-track relationships
    relationships_to_create := LEAST(1000, playlist_count * track_count); -- Create up to 1000 relationships
    
    RAISE NOTICE 'Creating % playlist-track relationships...', relationships_to_create;
    
    -- Clear existing relationships if any
    DELETE FROM playlist_track;
    
    -- Create relationships ensuring each playlist gets some tracks
    FOR current_playlist_id IN min_playlist_id..max_playlist_id LOOP
        -- Add 5-15 random tracks to each playlist
        FOR i IN 1..(5 + floor(random() * 11)) LOOP
            INSERT INTO playlist_track (playlist_id, track_id)
            VALUES (
                current_playlist_id,
                min_track_id + floor(random() * (max_track_id - min_track_id + 1))
            )
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;
    
    COMMIT;
    
    RAISE NOTICE 'Playlist-track fix completed!';
    RAISE NOTICE 'Total playlist-track relationships: %', (SELECT COUNT(*) FROM playlist_track);
END $$;

-- Generate statistics
ANALYZE playlist_track;

-- Show final state
SELECT 
    'FINAL STATE' as status,
    (SELECT COUNT(*) FROM playlist)::text as playlists,
    (SELECT COUNT(*) FROM track)::text as tracks,
    (SELECT COUNT(*) FROM playlist_track)::text as playlist_tracks;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Playlist Track Fix Summary:';
    RAISE NOTICE 'Playlists: %', (SELECT COUNT(*) FROM playlist);
    RAISE NOTICE 'Tracks: %', (SELECT COUNT(*) FROM track);
    RAISE NOTICE 'Playlist-Track Relationships: %', (SELECT COUNT(*) FROM playlist_track);
    RAISE NOTICE '';
END $$;
