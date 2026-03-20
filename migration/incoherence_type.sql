SELECT
    c1.relname AS table_A,
    a1.attname AS colonne,
    format_type(a1.atttypid, a1.atttypmod) AS type_table_A,
    c2.relname AS table_B,
    format_type(a2.atttypid, a2.atttypmod) AS type_table_B,
    -- Génération du script de mise en conformité
    'ALTER TABLE ' || c2.relname || ' ALTER COLUMN ' || a2.attname ||
    ' TYPE ' || format_type(a1.atttypid, a1.atttypmod) || ';' AS script_correction
FROM
    pg_attribute a1
        JOIN pg_class c1 ON a1.attrelid = c1.oid
        JOIN pg_namespace n1 ON c1.relnamespace = n1.oid
        JOIN pg_attribute a2 ON a1.attname = a2.attname -- Même nom de colonne
        JOIN pg_class c2 ON a2.attrelid = c2.oid
        JOIN pg_namespace n2 ON c2.relnamespace = n2.oid
WHERE
    n1.nspname = 'public'
  AND n2.nspname = 'public'
  AND c1.relkind = 'r' -- Tables uniquement
  AND c2.relkind = 'r'
  AND a1.attnum > 0 AND NOT a1.attisdropped
  AND a2.attnum > 0 AND NOT a2.attisdropped
  AND a1.attname LIKE '%_id' -- On cible les clés (standard Chinook)
  AND c1.relname < c2.relname -- Évite les doublons
  AND a1.atttypid <> a2.atttypid; -- Filtre uniquement les types différents

-- top 10 des requetes les plus longues
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- index non utilisé
SELECT schemaname, relname, indexrelname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY schemaname, relname;

-- Forcer la mise à jour des stats sur toutes les tables
ANALYZE VERBOSE;

-- Ajuster la précision des stats pour les colonnes très sélectives
ALTER TABLE invoice ALTER COLUMN purchase_date SET STATISTICS 500;

-- relation level stats
SELECT relname, relpages, reltuples, relallvisible
FROM pg_class
WHERE relname = 'invoice';

-- column-level stats
SELECT attname, null_frac, avg_width, n_distinct,
       most_common_vals, most_common_freqs, histogram_bounds, correlation
FROM pg_stats
WHERE tablename = 'invoice' AND attname = 'purchase_date';