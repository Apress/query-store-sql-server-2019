-- Listing 3.1
ALTER DATABASE [<Database_Name>] SET QUERY_STORE=ON;


-- Listing 3.2
DECLARE @SQL NVARCHAR(MAX) = N'';

SELECT @SQL += REPLACE(N'ALTER DATABASE [{{DBNAME}}] SET QUERY_STORE=ON ',
    '{{DBName}}', [name])
FROM sys.databases
WHERE state_desc = 'ONLINE'
    AND [name] NOT IN ('master', 'tempdb')
ORDER BY [name];

EXEC (@SQL);


--  Listing 3.3
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( OPERATION_MODE = READ_WRITE );


-- Listing 3.4
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = <Value> ) );


-- Listing 3.5
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( DATA_FLUSH_INTERVAL_SECONDS = <Value> );


-- Listing 3.6
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( MAX_STORAGE_SIZE_MB = <Value> );


-- Listing 3.7
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( INTERVAL_LENGTH_MINUTES = <Value> );


-- Listing 3.8 
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( SIZE_BASED_CLEANUP_MODE = <Value> );


-- Listing 3.9
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( QUERY_STORE_CAPTURE_MODE = [<Value>] );


-- Listing 3.10
ALTER DATABASE [<Database Name>]
SET QUERY_STORE = ON
    (
    QUERY_CAPTURE_MODE = CUSTOM,
    QUERY_CAPTURE_POLICY = (
    STALE_CAPTURE_POLICY_THRESHOLD = 24 HOURS,
    EXECUTION_COUNT = 30,
    TOTAL_COMPILE_CPU_TIME_MS = 1000,
    TOTAL_EXECUTION_CPU_TIME_MS = 100
    )
);


-- Listing 3.11
SELECT query_hash,
COUNT (DISTINCT query_plan_hash) distinct_plans
FROM sys.dm_exec_query_stats
GROUP BY query_hash
ORDER BY distinct_plans DESC;


-- Listing 3.12
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( MAX_PLANS_PER_QUERY = <Value> );


-- Listing 3.13
ALTER DATABASE [<Database Name>] SET QUERY_STORE ( WAIT_STATISTICS_CAPTURE_MODE = <Value> );


-- Listing 3.14
SELECT *
FROM sys.database_query_store_options


-- Listing 3.15
CREATE PROCEDURE dbo.GetName
    @LastName VARCHAR(20)
AS
SET NOCOUNT ON;

SELECT  FirstName,
        LastName
FROM dbo.Customer
WHERE LastName = @LastName;
GO

EXEC dbo.GetName @LastName = 'Boggiano';


-- Listing 3.16
SELECT  FirstName,
        LastName
FROM dbo.Customer
WHERE LastName = 'Boggiano';


-- Listing 3.17
DECLARE @dbid INT = DB_ID('<database>');
DECLARE @object_id INT = OBJECT_ID('<InMemoryProcedure>');

EXEC sys.sp_xtp_control_query_exec_stats
    @new_collection_value = 1,
    @database_id = @dbid,
    @xtp_object_id = @object_id;


-- Listing 3.18
EXEC sys.sp_xtp_control_query_exec_stats
    @new_collection_value = 1;


-- Listing 3.19
ALTER DATABASE [<Database>]
SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON );


-- Listing 3.20
DECLARE @SQL NVARCHAR(MAX) = N''

SELECT @SQL += REPLACE(N'ALTER DATABASE [{{DBNAME}}] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON ',
    '{{DBName}}', [name])
FROM sys.databases
WHERE state_desc = 'ONLINE'
    AND is_query_store_on = 1
ORDER BY [name];

EXEC (@SQL);


-- Listing 3.21
ALTER DATABASE [<Database>]
SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = OFF );


-- Listing 3.22
DECLARE @SQL NVARCHAR(MAX) = N'';

SELECT @SQL += REPLACE(N'ALTER DATABASE [{{DBNAME}}] SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = OFF ',
    '{{DBName}}', [name])
FROM sys.databases
WHERE state_desc = 'ONLINE'
    AND is_query_store_on = 1
ORDER BY [name];

EXEC (@SQL);


-- Listing 3.23
SELECT  DB_NAME() database_name,
        actual_state_desc,
        desired_state_desc
FROM sys.database_query_store_options
WHERE desired_state_desc <> actual_state_desc


-- Listing 3.24
DECLARE @SQL NVARCHAR(MAX) = N'';

SELECT @SQL += REPLACE(REPLACE(N'USE [{{DBName}}];
        SELECT
            "{{DBName}}" database_name,
            actual_state_desc,
            desired_state_desc
        FROM {{DBName}}.sys.database_query_store_options
        WHERE desired_state_desc <> actual_state_desc '
    ,'{{DBName}}', [name])
    ,'"', "")
FROM sys.databases
WHERE is_query_store_on = 1
ORDER BY [name];

EXEC (@SQL);


-- Listing 3.25
DECLARE @SQL AS NVARCHAR(MAX) = N'';

SELECT @SQL += REPLACE(N'USE [{{DBName}}]

--Try Changing to READ_WRITE
IF EXISTS (SELECT * FROM sys.database_query_store_options WHERE actual_state=3)
BEGIN
    BEGIN TRY
        ALTER DATABASE [{{DBName}}] SET QUERY_STORE = OFF
        ALTER DATABASE [{{DBName}}] SET QUERY_STORE = READ_WRITE
    END TRY
    BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END

--Run sys.sp_query_store_consistency_check
IF EXISTS (SELECT * FROM sys.database_query_store_options WHERE actual_state=3)
BEGIN
    BEGIN TRY
        EXEC [{{DBName}}].sys.sp_query_store_consistency_check
        ALTER DATABASE [{{DBName}}] SET QUERY_STORE = ON
        ALTER DATABASE [{{DBName}}] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END

--Run purge Query Store
IF EXISTS (SELECT * FROM sys.database_query_store_options WHERE actual_state=3)
BEGIN
    BEGIN TRY
        ALTER DATABASE [{{DBName}}] SET QUERY_STORE CLEAR
        ALTER DATABASE [{{DBName}}] SET QUERY_STORE (OPERATION_MODE = READ_WRITE)
    END TRY
    BEGIN CATCH
        SELECT
            ERROR_NUMBER() AS ErrorNumber
            ,ERROR_SEVERITY() AS ErrorSeverity
            ,ERROR_STATE() AS ErrorState
            ,ERROR_PROCEDURE() AS ErrorProcedure
            ,ERROR_LINE() AS ErrorLine
            ,ERROR_MESSAGE() AS ErrorMessage
    END CATCH;
END
'
,'{{DBName}}', [name])
FROM sys.databases
WHERE is_query_store_on = 1;
EXEC (@SQL);


-- Listing 3.26
USE [<Database>];
GO
SELECT  current_storage_size_mb,
        max_storage_size_mb,
FROM sys.database_query_store_options
WHERE CAST(CAST(current_storage_size_mb AS DECIMAL(21, 2)) / CAST(max_storage_size_mb AS DECIMAL(21, 2)) * 100 AS DECIMAL(4, 2)) >= 90
    AND size_based_cleanup_mode_desc = 'OFF';


-- Listing 3.27
ALTER DATABASE [<Database Name>] SET QUERY_STORE CLEAR ALL;


-- Liting 3.28
USE [<Database>];
GO
EXEC sys.sp_query_store_flush_db;


-- Listing 3.29
SELECT  plan_id,
        force_failure_count,
        last_force_failure_reason
FROM sys.query_store_plan


-- Listing 3.30
CREATE EVENT SESSION [QueryStore_Forcing_Plan_Failure]
ON SERVER
ADD EVENT qds.query_store_plan_forcing_failed
ADD TARGET package0.ring_buffer WITH
(
    MAX_MEMORY=4096 KB,
    EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY=30 SECONDS,
    MAX_EVENT_SIZE=0 KB,
    MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,
    STARTUP_STATE=ON
);


-- Lisiting 3.31
USE [<Database>];
EXECUTE sys.sp_query_store_remove_plan @plan_id = <plan_id>;


-- Lisintg 3.32
USE [<Database>];
EXECUTE sys.sp_query_store_remove_query @query_id = <query_id>;


-- Lisintg 3.33
USE [<Database>];
GO
EXECUTE sys.sp_query_store_reset_exec_stats @plan_id = <plan_id>;