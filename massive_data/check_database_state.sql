/*******************************************************************************
   Chinook Database - Current State Check
   Script: check_database_state.sql
   Description: Checks the current state of all Chinook tables.
   Author: Generated for Chinook database diagnostics
********************************************************************************/

-- Connect to chinook database
-- \c chinook;

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CHINOOK DATABASE CURRENT STATE';
    RAISE NOTICE '========================================';
END $$;

SELECT 
    'TABLE COUNTS' as table_name,
    '' as record_count,
    '' as table_size
UNION ALL
SELECT 
    'artist' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('artist')) as table_size
FROM artist
UNION ALL
SELECT 
    'album' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('album')) as table_size
FROM album
UNION ALL
SELECT 
    'genre' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('genre')) as table_size
FROM genre
UNION ALL
SELECT 
    'media_type' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('media_type')) as table_size
FROM media_type
UNION ALL
SELECT 
    'track' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('track')) as table_size
FROM track
UNION ALL
SELECT 
    'customer' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('customer')) as table_size
FROM customer
UNION ALL
SELECT 
    'employee' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('employee')) as table_size
FROM employee
UNION ALL
SELECT 
    'invoice' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('invoice')) as table_size
FROM invoice
UNION ALL
SELECT 
    'invoice_line' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('invoice_line')) as table_size
FROM invoice_line
UNION ALL
SELECT 
    'playlist' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('playlist')) as table_size
FROM playlist
UNION ALL
SELECT 
    'playlist_track' as table_name,
    COUNT(*)::text as record_count,
    pg_size_pretty(pg_total_relation_size('playlist_track')) as table_size
FROM playlist_track
ORDER BY 
    CASE WHEN table_name = 'TABLE COUNTS' THEN 0 ELSE 1 END,
    table_name;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DATABASE SIZE: %', pg_size_pretty(pg_database_size('chinook'));
    RAISE NOTICE '========================================';
END $$;
