SELECT
    query,
    calls,
    round(total_exec_time::numeric, 2) as total_time_ms,
    round((total_exec_time / calls)::numeric, 2) as avg_time_ms,
    round(rows / calls) as avg_rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
