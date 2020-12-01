-- Listing 5.1
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL += REPLACE('
        USE [{{DBName}}];
        SELECT  DB_Name(),
                *
        FROM sys.database_query_store_options; ',
    '{{DBName}}', [name])
FROM sys.databases
WHERE is_query_store_on = 1;

EXEC (@SQL);


-- Listing 5.2
SELECT q.query_id,
       qt.query_sql_text,
       qs.plan_handle,
       q.context_settings_id
FROM sys.query_store_query q
    INNER JOIN sys.dm_exec_query_stats qs
        ON q.last_compile_batch_sql_handle = qs.sql_handle
    INNER JOIN sys.query_store_query_text qt
        ON q.query_text_id = qt.query_text_id
    INNER JOIN sys.query_context_settings cs
        ON cs.context_settings_id = q.context_settings_id
WHERE qt.query_sql_text LIKE '%<value>%'
ORDER BY q.query_id


-- Listing 5.3
SELECT *
FROM sys.dm_exec_plan_attributes(<plan_handle>)
WHERE attribute = 'set_options'
GO

-- Listing 5.4
CREATE FUNCTION dbo.fn_QueryStoreSetOptions (@SetOptions as int)
RETURNS VARCHAR(MAX)
AS
BEGIN
    --Variables:
    DECLARE @Result varchar(MAX) = '',
            @SetOptionFound int
            
    DECLARE @SetOptionsList TABLE
    (
        [Value] int,
        [Option] varchar(60)
    )

    INSERT INTO @SetOptionsList
    VALUES
    (1, 'ANSI_PADDING'),
    (2, 'Parallel Plan'),
    (4, 'FORCEPLAN'),
    (8, 'CONCAT_NULL_YIELDS_NULL'),
    (16, 'ANSI_WARNINGS'),
    (32, 'ANSI_NULLS'),
    (64, 'QUOTED_IDENTIFIER'),
    (128, 'ANSI_NULL_DFLT_ON'),
    (256, 'ANSI_NULL_DFLT_OFF'),
    (512, 'NoBrowseTable'),
    (1024, 'TriggerOneRow'),
    (2048, 'ResyncQuery'),
    (4096, 'ARITH_ABORT'),
    (8192, 'NUMERIC_ROUNDABORT'),
    (16384, 'DATEFIRST'),
    (32768, 'DATEFORMAT'),
    (65536, 'LanguageID'),
    (131072, 'UPON'),
    (262144, 'ROWCOUNT')

    SELECT TOP 1
        @SetOptionFound = ISNULL([Value], -1),
        @Result = ISNULL([Option], '') + ' (' + CAST(@SetOptionFound as varchar) + ')' + '; '
    FROM @SetOptionsList
    WHERE [Value] <= @Set_Options
    ORDER BY [Value] DESC

    RETURN @Result + CASE
                         WHEN @SetOptionFound > -1 THEN
                             dbo.fn_QueryStoreSetOptions(@Set_Options - @SetOptionFound)
                         ELSE
                             ''
                     END

END
GO

-- Listing 5.5
SELECT dbo.fn_QueryStoreSetOptions(CAST(set_options as int))
FROM sys.query_context_settings


-- Listing 5.6
SELECT *
FROM sys.query_store_query_text qt
    INNER JOIN sys.query_store_query q ON q.query_text_id = qt.query_text_id
    INNER JOIN sys.objects o on o.object_id = q.object_id
WHERE o.name = '<object_name>'


-- Listing 5.7
SELECT *
FROM sys.query_store_query_text qt
    INNER JOIN sys.query_store_query q ON q.query_text_id = qt.query_text_id
    INNER JOIN sys.objects o on o.object_id = q.object_id
    INNER JOIN sys.query_store_plan p ON p.query_id = q.query_id
    INNER JOIN sys.query_store_wait_stats ws ON ws.plan_id = p.plan_id
WHERE o.name = '<object_name>'


-- Listing 5.8
SELECT TOP 10 sum(rs.count_executions * rs.avg_duration) avg_duration,
    qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    p.plan_id,
    rs.last_execution_time
FROM sys.query_store_query_text AS qt
    INNER JOIN sys.query_store_query AS q ON qt.query_text_id = q.query_text_id
    INNER JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
    INNER JOIN sys.query_store_runtime_stats AS rs ON p.plan_id = rs.plan_id
WHERE rs.last_execution_time > DATEADD(hour, -1, GETUTCDATE())
GROUP BY qt.query_sql_text,
    q.query_id,
    qt.query_text_id,
    p.plan_id,
    rs.last_execution_time
ORDER BY avg_duration DESC;