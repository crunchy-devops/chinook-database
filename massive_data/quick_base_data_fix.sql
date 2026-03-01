/*******************************************************************************
   Chinook Database - Quick Base Data Fix
   Script: quick_base_data_fix.sql
   Description: Quickly loads essential base data for empty tables.
   Author: Generated for Chinook database quick fix
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

DO $$
BEGIN
    RAISE NOTICE 'Loading essential base data...';
END $$;

-- Load Genres (if empty)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM genre LIMIT 1) THEN
        INSERT INTO genre (name) VALUES
            ('Rock'), ('Jazz'), ('Metal'), ('Alternative & Punk'), ('Rock And Roll'),
            ('Blues'), ('Latin'), ('Reggae'), ('Pop'), ('Soundtrack'), ('Bossa Nova'),
            ('Easy Listening'), ('Heavy Metal'), ('R&B/Soul'), ('Electronica/Dance'),
            ('World'), ('Hip Hop/Rap'), ('Science Fiction'), ('TV Shows'), ('Sci Fi & Fantasy'),
            ('Drama'), ('Comedy'), ('Alternative'), ('Classical'), ('Opera');
        RAISE NOTICE 'Loaded % genres', (SELECT COUNT(*) FROM genre);
    ELSE
        RAISE NOTICE 'Genres already exist: %', (SELECT COUNT(*) FROM genre);
    END IF;
END $$;

-- Load Media Types (if empty)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM media_type LIMIT 1) THEN
        INSERT INTO media_type (name) VALUES
            ('MPEG audio file'), ('Protected AAC audio file'), ('Protected MPEG-4 video file'),
            ('Purchased AAC audio file'), ('AAC audio file');
        RAISE NOTICE 'Loaded % media types', (SELECT COUNT(*) FROM media_type);
    ELSE
        RAISE NOTICE 'Media types already exist: %', (SELECT COUNT(*) FROM media_type);
    END IF;
END $$;

-- Load Sample Playlists (if empty)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM playlist LIMIT 1) THEN
        INSERT INTO playlist (name) VALUES
            ('Music'), ('Movies'), ('TV Shows'), ('90''s Music'), ('Audiobooks'),
            ('Classical'), ('Classical 101 - The Basics'), ('Heavy Metal Classic'), ('On-The-Go');
        RAISE NOTICE 'Loaded % playlists', (SELECT COUNT(*) FROM playlist);
    ELSE
        RAISE NOTICE 'Playlists already exist: %', (SELECT COUNT(*) FROM playlist);
    END IF;
END $$;

COMMIT;

-- Generate statistics
ANALYZE genre;
ANALYZE media_type;
ANALYZE playlist;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Base data fix completed!';
    RAISE NOTICE 'Genres: % | Media Types: % | Playlists: %', 
        (SELECT COUNT(*) FROM genre),
        (SELECT COUNT(*) FROM media_type),
        (SELECT COUNT(*) FROM playlist);
END $$;
