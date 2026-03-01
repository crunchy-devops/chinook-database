# Chinook Database Massive Data Generation

This directory contains SQL scripts to generate massive amounts of data for the Chinook database, designed to scale the database to 10-20 GB in size for testing and demonstration purposes.

## Scripts Overview

### Master Script
- **`00_master_massive_data_generation.sql`** - Master script that runs all data generation scripts in the correct order with progress tracking and optimization

### Individual Generation Scripts
1. **`01_massive_artists_albums.sql`** - Generates 50,000+ artists and 200,000+ albums
2. **`02_massive_tracks.sql`** - Generates 2,000,000+ tracks with realistic metadata
3. **`03_massive_customers_employees.sql`** - Generates 100,000+ customers and 50+ employees
4. **`04_massive_invoices.sql`** - Generates 500,000+ invoices and 5,000,000+ invoice lines
5. **`05_massive_playlists.sql`** - Generates 50,000+ playlists and 10,000,000+ playlist-track relationships

## Expected Final Database Size

| Table | Records | Estimated Size |
|-------|---------|----------------|
| Artist | 50,000+ | ~10 MB |
| Album | 200,000+ | ~50 MB |
| Track | 2,000,000+ | ~2-3 GB |
| Customer | 100,000+ | ~50 MB |
| Employee | 50+ | ~1 MB |
| Invoice | 500,000+ | ~200 MB |
| Invoice Line | 5,000,000+ | ~2-3 GB |
| Playlist | 50,000+ | ~10 MB |
| Playlist Track | 10,000,000+ | ~3-5 GB |
| **Total** | **~18M+ records** | **~10-20 GB** |

## Prerequisites

1. PostgreSQL database with Chinook schema (AutoIncrementPKs version)
2. Sufficient disk space (20+ GB recommended)
3. Adequate memory (8+ GB recommended)
4. PostgreSQL configuration optimized for bulk operations

## Usage

### Quick Start (Recommended)
Run the master script which handles everything automatically:

```sql
-- Connect to your chinook database
\c chinook

-- Run the master script
\i massive_data/00_master_massive_data_generation.sql
```

### Manual Execution
Run scripts individually for more control:

```sql
-- Connect to your chinook database
\c chinook

-- Run scripts in order
\i massive_data/01_massive_artists_albums.sql
\i massive_data/02_massive_tracks.sql
\i massive_data/03_massive_customers_employees.sql
\i massive_data/04_massive_invoices.sql
\i massive_data/05_massive_playlists.sql
```

## Performance Considerations

### Database Configuration
For optimal performance, consider these PostgreSQL settings during data generation:

```sql
-- Temporary optimizations for bulk loading
SET synchronous_commit = OFF;
SET wal_level = minimal;
SET maintenance_work_mem = '1GB';
SET checkpoint_completion_target = 0.9;
SET temp_buffers = '512MB';
SET work_mem = '256MB';
SET effective_cache_size = '4GB';
SET random_page_cost = 1.1;
```

### Hardware Requirements
- **CPU**: Multi-core processor recommended
- **Memory**: 8GB+ RAM recommended
- **Storage**: SSD with 20GB+ free space
- **Network**: Not critical for local generation

### Estimated Execution Times
- **Total Time**: 30-120 minutes depending on hardware
- **Step 1 (Artists/Albums)**: 5-15 minutes
- **Step 2 (Tracks)**: 15-45 minutes (longest step)
- **Step 3 (Customers/Employees)**: 5-10 minutes
- **Step 4 (Invoices)**: 20-60 minutes
- **Step 5 (Playlists)**: 10-30 minutes

## Features

### Realistic Data Generation
- **Artists**: Varied names including bands, solo artists, duos, etc.
- **Albums**: Creative titles with realistic patterns
- **Tracks**: Realistic song names, composers, durations, and file sizes
- **Customers**: Diverse demographic data with proper email/phone formats
- **Invoices**: Realistic purchase patterns and dates
- **Playlists**: Themed playlists with appropriate track distributions

### Performance Optimizations
- Batch processing to avoid memory issues
- Periodic commits to prevent long transactions
- Index-friendly data generation
- Optimized PostgreSQL settings during generation
- Progress reporting and logging

### Data Integrity
- Proper foreign key relationships
- Realistic data distributions
- No duplicate primary keys
- Proper data types and constraints

## Monitoring Progress

The master script includes comprehensive logging:
- Real-time progress reporting
- Execution time tracking
- Record count validation
- Table size monitoring
- Error handling and reporting

## Post-Generation

After completion, the script automatically:
- Updates table statistics (`ANALYZE`)
- Rebuilds indexes (`REINDEX`)
- Optimizes table storage (`VACUUM`)
- Resets performance settings to defaults
- Generates comprehensive summary report

## Customization

### Adjusting Data Volume
Modify the `total_*` variables in each script to scale up or down:

```sql
-- Example: Generate more tracks
total_tracks INT := 5000000; -- Increase from 2,000,000
```

### Changing Data Patterns
Modify the arrays in the generation functions to customize:
- Name patterns
- Address formats
- Price ranges
- Date ranges

## Troubleshooting

### Common Issues
1. **Out of Memory**: Reduce batch sizes in scripts
2. **Disk Space**: Ensure sufficient storage is available
3. **Long Execution Times**: Consider running on more powerful hardware
4. **Connection Timeouts**: Increase PostgreSQL timeout settings

### Recovery
If generation fails partway through:
1. Check the `data_generation_log` table for progress
2. Restart from the failed step
3. The master script handles partial recovery automatically

## License

These scripts are generated for extending the Chinook database and follow the same license terms as the original Chinook Database project.
