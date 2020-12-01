-- Listing 9.1
SELECT dows.wait_type,
    dows.waiting_tasks_count,
    dows.wait_time_ms,
    dows.max_wait_time_ms,
    dows.signal_wait_time_ms
FROM sys.dm_os_wait_stats AS dows
WHERE dows.wait_type LIKE 'qds_%';


-- Listing 9.2
SELECT dxo.name,
    dxo.description
FROM sys.dm_xe_packages AS dxp
    JOIN sys.dm_xe_objects AS dxo ON dxp.guid = dxo.package_guid
WHERE dxp.name = 'qds'
AND dxo.object_type = 'event';


-- Listing 9.3
CREATE EVENT SESSION QueryStoreBehavior
ON SERVER
    ADD EVENT qds.query_store_background_task_persist_finished,
    ADD EVENT qds.query_store_background_task_persist_started,
    ADD EVENT qds.query_store_capture_policy_evaluate,
    ADD EVENT qds.query_store_capture_policy_start_capture,
    ADD EVENT qds.query_store_database_out_of_disk_space,
    ADD EVENT qds.query_store_db_cleared,
    ADD EVENT qds.query_store_db_diagnostics,
    ADD EVENT qds.query_store_db_settings_changed,
    ADD EVENT qds.query_store_plan_removal,
    ADD EVENT qds.query_store_size_retention_cleanup_finished,
    ADD EVENT qds.query_store_size_retention_cleanup_started
    ADD TARGET package0.event_file
(SET filename = N'C:\ExEvents\QueryStorePlanForcing.xel', max_rollover_files = (3))
WITH (TRACK_CAUSALITY = ON);


-- Listing 9.4
ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;


-- Listing 9.5
EXEC dbo.AddressByCity @City = N'London';


-- Listing 9.6
DECLARE @PlanID INT;

SELECT TOP 1
    @PlanID = qsp.plan_id
FROM sys.query_store_query AS qsq
JOIN sys.query_store_plan AS qsp
ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');

EXEC sys.sp_query_store_remove_plan @plan_id = @PlanID;