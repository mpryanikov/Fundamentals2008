-- Connection info
SELECT -- use * to explore
  session_id AS spid,
  connect_time,
  last_read,
  last_write,
  most_recent_sql_handle
FROM sys.dm_exec_connections
WHERE session_id IN(52, 57);