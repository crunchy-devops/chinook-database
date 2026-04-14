WITH chunks AS (
    SELECT
        ht.schema_name AS hypertable_schema,
        ht.table_name AS hypertable_name,
        ck.table_name AS chunk_name
    FROM _timescaledb_catalog.hypertable ht
             JOIN _timescaledb_catalog.chunk ck
                  ON ht.id = ck.hypertable_id
),

     tables_and_chunks AS (
         select
             CASE WHEN c.hypertable_name IS NOT NULL THEN 'Hypertable' ELSE 'Table' END AS table_type,
             COALESCE(c.hypertable_schema, t.table_schema) AS table_schema,
             COALESCE(c.hypertable_name, t.table_name) AS table_name,
             pg_table_size('"'||t.table_schema||'"."'||t.table_name||'"') AS table_or_chunk_table_size,
             pg_indexes_size('"'||t.table_schema||'"."'||t.table_name||'"') AS table_or_chunk_indexes_size,
             pg_total_relation_size('"'||t.table_schema||'"."'||t.table_name||'"') AS table_or_chunk_total_size
         from information_schema.tables t
                  LEFT JOIN chunks c
                            ON c.chunk_name = t.table_name
     )

SELECT
    table_type,
    table_schema,
    table_name,
    pg_size_pretty(SUM(table_or_chunk_table_size)) AS table_size,
    pg_size_pretty(SUM(table_or_chunk_indexes_size)) AS indexes_size,
    pg_size_pretty(SUM(table_or_chunk_total_size)) AS total_size
FROM tables_and_chunks
WHERE table_schema NOT IN ('pg_catalog', 'information_schema', '_timescaledb_catalog', 'timescaledb_information')
GROUP BY table_type, table_schema, table_name
ORDER BY SUM(table_or_chunk_total_size) DESC;