-- Listing 6-1. T-SQL to top queries by duration in last 10 days
SELECT TOP 10 qt.query_sql_text,
    q.query_id,
    so.name,
    so.type,
    SUM(rs.count_executions * rs.avg_duration)
    AS 'Total Duration'
FROM sys.query_store_query_text qt
    INNER JOIN sys.query_store_query q  ON qt.query_text_id = q.query_text_id
    INNER JOIN sys.query_store_plan p  ON q.query_id = p.query_id
    INNER JOIN sys.query_store_runtime_stats rs  ON p.plan_id = rs.plan_id
    INNER JOIN sys.query_store_runtime_stats_interval rsi  ON rsi.runtime_stats_interval_id =  rs.runtime_stats_interval_id
    INNER JOIN sysobjects so on so.id = q.object_id
WHERE rsi.start_time >= DATEADD(DAY, -10, GETUTCDATE())
GROUP BY qt.query_sql_text,
    q.query_id,
    so.name,
    so.type
ORDER BY SUM(rs.count_executions * rs.avg_duration_time) DESC;


-- Listing 6-2. Store procedure to clear all the data out of Query Store
USE [<Database>]
GO
EXEC sys.sp_query_store_flush_db;


--Listing 6-3. T-SQL to check for ad-hoc workload
--Total Query Texts
SELECT COUNT(*) AS CountQueryTextRows
FROM sys.query_store_query_text;

--Total Queries
SELECT COUNT(*) AS CountQueryRows
FROM sys.query_store_query;

--Total distinct query hashes (different queries)
SELECT COUNT(DISTINCT query_hash) AS CountDifferentQueryRows
FROM sys.query_store_query;

--Total plans
SELECT COUNT(*) AS CountPlanRows
FROM sys.query_store_plan;

--Total unique query_plan_hash (different plans)
SELECT COUNT(DISTINCT query_plan_hash) AS CountDifferentPlanRows
FROM sys.query_store_plan;


--Listing 6-4. Template for implementing a plan guide for PARAMETERIZATION FORCED
DECLARE @stmt nvarchar(max);
DECLARE @params nvarchar(max);

EXEC sp_get_query_template
    N'<your query text goes here>',
    @stmt OUTPUT,
    @params OUTPUT;

EXEC sp_create_plan_guide
    N'TemplateGuide1',
    @stmt,
    N'TEMPLATE',
    NULL,
    @params,
    N'OPTION (PARAMETERIZATION FORCED)';


-- Listing 6-5. Turn on PARATERIZATION FORCED at database level
ALTER DATABASE [<database name>] SET PARAMETERIZATION FORCED;


--Listing 6-6. Enable optimize for ad-hoc workloads and set capture mode to AUTO for Query Store
EXEC sys.sp_configure N'show advanced options', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'optimize for ad hoc workloads', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO

ALTER DATABASE [<database name>] SET QUERY_STORE CLEAR;

ALTER DATABASE [<database name>] SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE, QUERY_CAPTURE_MODE = AUTO);