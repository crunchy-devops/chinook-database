CREATE TABLE sensor_data (
                             time TIMESTAMPTZ NOT NULL,
                             sensor_id TEXT NOT NULL,
                             temperature DOUBLE PRECISION,
                             humidity DOUBLE PRECISION,
                             pressure DOUBLE PRECISION
) WITH (
      tsdb.hypertable
      );
SELECT * FROM timescaledb_information.hypertables WHERE hypertable_name = 'sensor_data';
-- create index
CREATE INDEX idx_device_time ON sensor_data (sensor_id, time DESC)

SELECT COUNT(*) FROM sensor_data;