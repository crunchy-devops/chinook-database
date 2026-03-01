/*******************************************************************************
   Chinook Database - Base Data Setup Script
   Script: 00_setup_base_data.sql
   Description: Loads the base Chinook data required for massive data generation.
   DB Server: PostgreSQL
   Author: Generated for Chinook database massive data generation
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

-- Enable performance optimizations
SET synchronous_commit = OFF;
SET maintenance_work_mem = '256MB';

/*******************************************************************************
   Load Base Genres (if not already loaded)
********************************************************************************/
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM genre LIMIT 1) THEN
        RAISE NOTICE 'Loading base genres...';
        INSERT INTO genre (name) VALUES
            ('Rock'),
            ('Jazz'),
            ('Metal'),
            ('Alternative & Punk'),
            ('Rock And Roll'),
            ('Blues'),
            ('Latin'),
            ('Reggae'),
            ('Pop'),
            ('Soundtrack'),
            ('Bossa Nova'),
            ('Easy Listening'),
            ('Heavy Metal'),
            ('R&B/Soul'),
            ('Electronica/Dance'),
            ('World'),
            ('Hip Hop/Rap'),
            ('Science Fiction'),
            ('TV Shows'),
            ('Sci Fi & Fantasy'),
            ('Drama'),
            ('Comedy'),
            ('Alternative'),
            ('Classical'),
            ('Opera');
        RAISE NOTICE 'Base genres loaded: % records', (SELECT COUNT(*) FROM genre);
    ELSE
        RAISE NOTICE 'Genres already exist: % records', (SELECT COUNT(*) FROM genre);
    END IF;
END $$;

COMMIT;

/*******************************************************************************
   Load Base Media Types (if not already loaded)
********************************************************************************/
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM media_type LIMIT 1) THEN
        RAISE NOTICE 'Loading base media types...';
        INSERT INTO media_type (name) VALUES
            ('MPEG audio file'),
            ('Protected AAC audio file'),
            ('Protected MPEG-4 video file'),
            ('Purchased AAC audio file'),
            ('AAC audio file');
        RAISE NOTICE 'Base media types loaded: % records', (SELECT COUNT(*) FROM media_type);
    ELSE
        RAISE NOTICE 'Media types already exist: % records', (SELECT COUNT(*) FROM media_type);
    END IF;
END $$;

COMMIT;

/*******************************************************************************
   Load Base Playlists (if not already loaded)
********************************************************************************/
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM playlist LIMIT 1) THEN
        RAISE NOTICE 'Loading base playlists...';
        INSERT INTO playlist (name) VALUES
            ('Music'),
            ('Movies'),
            ('TV Shows'),
            ('90''s Music'),
            ('Audiobooks'),
            ('Classical'),
            ('Classical 101 - The Basics'),
            ('Heavy Metal Classic'),
            ('On-The-Go');
        RAISE NOTICE 'Base playlists loaded: % records', (SELECT COUNT(*) FROM playlist);
    ELSE
        RAISE NOTICE 'Playlists already exist: % records', (SELECT COUNT(*) FROM playlist);
    END IF;
END $$;

COMMIT;

/*******************************************************************************
   Load Sample Base Data (small sample for testing)
********************************************************************************/
DO $$
BEGIN
    -- Load a few sample artists if none exist
    IF NOT EXISTS (SELECT 1 FROM artist LIMIT 1) THEN
        RAISE NOTICE 'Loading sample artists...';
        INSERT INTO artist (name) VALUES
            ('AC/DC'),
            ('Accept'),
            ('Aerosmith'),
            ('Alanis Morissette'),
            ('Alice In Chains'),
            ('Antônio Carlos Jobim'),
            ('Apocalyptica'),
            ('Audioslave'),
            ('BackBeat'),
            ('Billy Cobham');
        RAISE NOTICE 'Sample artists loaded: % records', (SELECT COUNT(*) FROM artist);
    END IF;

    -- Load a few sample albums if none exist
    IF NOT EXISTS (SELECT 1 FROM album LIMIT 1) THEN
        RAISE NOTICE 'Loading sample albums...';
        INSERT INTO album (title, artist_id) VALUES
            ('For Those About To Rock We Salute You', 1),
            ('Balls to the Wall', 2),
            ('Restless and Wild', 2),
            ('Let There Be Rock', 1),
            ('Big Ones', 3),
            ('Jagged Little Pill', 4),
            ('Facelift', 5),
            ('Warner 25 Anos', 6),
            ('Plays Metallica By Four Cellos', 7),
            ('Audioslave', 8);
        RAISE NOTICE 'Sample albums loaded: % records', (SELECT COUNT(*) FROM album);
    END IF;

    -- Load a few sample tracks if none exist
    IF NOT EXISTS (SELECT 1 FROM track LIMIT 1) THEN
        RAISE NOTICE 'Loading sample tracks...';
        INSERT INTO track (name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price) VALUES
            ('For Those About To Rock (We Salute You)', 1, 1, 1, 'Angus Young, Malcolm Young, Brian Johnson', 343719, 11170334, 0.99),
            ('Balls to the Wall', 2, 2, 1, 'U. Dirkschneider, W. Hoffmann', 342562, 5510424, 0.99),
            ('Fast As a Shark', 3, 2, 1, 'F. Baltes, S. Kaufman, U. Dirkscneider', 230619, 3990994, 0.99),
            ('Restless and Wild', 3, 2, 1, 'F. Baltes, S. Kaufmann, U. Dirkschneider', 252051, 8308874, 0.99),
            ('Princess of the Dawn', 3, 2, 1, 'Deaffy, R. Dirkscneider', 375418, 12229424, 0.99);
        RAISE NOTICE 'Sample tracks loaded: % records', (SELECT COUNT(*) FROM track);
    END IF;
END $$;

COMMIT;

-- Generate statistics
ANALYZE genre;
ANALYZE media_type;
ANALYZE playlist;
ANALYZE artist;
ANALYZE album;
ANALYZE track;

-- Reset performance settings
SET synchronous_commit = ON;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Base data setup completed!';
    RAISE NOTICE 'Genres: %', (SELECT COUNT(*) FROM genre);
    RAISE NOTICE 'Media Types: %', (SELECT COUNT(*) FROM media_type);
    RAISE NOTICE 'Playlists: %', (SELECT COUNT(*) FROM playlist);
    RAISE NOTICE 'Artists: %', (SELECT COUNT(*) FROM artist);
    RAISE NOTICE 'Albums: %', (SELECT COUNT(*) FROM album);
    RAISE NOTICE 'Tracks: %', (SELECT COUNT(*) FROM track);
END $$;
