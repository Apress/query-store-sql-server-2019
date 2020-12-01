SELECT CompanyName,
       AddressType,
       AddressLine1
FROM Customer
    JOIN CustomerAddress
        ON (Customer.CustomerID = CustomerAddress.CustomerID)
    JOIN Address
        ON (CustomerAddress.AddressID = Address.AddressID)
WHERE CompanyName = 'ACME Corporation' -- Listing 1.1
USE MASTER;
GO
;
SELECT DISTINCT
    tb.trace_event_id,
    te.[name] AS 'Event Class',
    em.package_name AS 'Package',
    em.xe_event_name AS 'XEvent Name',
    tca.[name] AS 'Profiler Category'
FROM(sys.trace_events te
    LEFT OUTER JOIN sys.trace_xe_event_map em
        ON te.trace_event_id = em.trace_event_id)
    LEFT OUTER JOIN sys.trace_event_bindings tb
        ON em.trace_event_id = tb.trace_event_id
    INNER JOIN sys.trace_categories tca
        ON tca.category_id = te.category_id
WHERE tb.trace_event_id IS NOT NULL
      AND tca.[name] in ( 'Stored Procedures', 'TSQL', 'Performance' )
ORDER BY tb.trace_event_id;


-- Listing 1.2
SELECT er.session_id,
       er.start_time,
       er.status,
       er.command,
       st.text,
       qp.query_plan AS cached_plan,
       qps.query_plan AS last_actual_exec_plan
FROM sys.dm_exec_requests AS er
    OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) qp
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
    OUTER APPLY sys.dm_exec_query_plan_stats(er.plan_handle) qps
WHERE session_id > 50
      AND status IN ( 'running', 'suspended' );
GO


-- Listing 1.3
EXEC dbo.sp_WhoIsActive @get_plans = 1,
                        @get_full_inner_text = 1,
                        @format_output = 0,
                        @get_task_info = 2,
                        @destination_table = 'DBA.dbo.WhoIsActiveOutput';


-- Listing 1.4
SELECT count(*) AS Total
FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d
        ON h.SalesOrderID = d.SalesOrderID
GO


-- Listing 1.5
SELECT count(*) AS Total
FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d
        ON h.SalesOrderID = d.SalesOrderID
OPTION (USE PLAN N'
<ShowPlanXML xmlns=
"http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="0.5"
Build="9.00.1187.07">
<BatchSequence>
<Batch>
<Statements>
...
</Statements>
</Batch>
</BatchSequence>
</ShowPlanXML>
'      )
GO


-- Listing 1.6
USE [<database_name>];
GO
UPDATE STATISTICS SchemaName.TableName;
GO


-- Listing 1.7
USE [<database_name>];
GO
UPDATE STATISTICS SchemaName.TableName IndexName;
GO


-- Listing 1.8
SELECT cp.plan_handle, st.sql_text
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE sql_text LIKE N'%MyTable%';

-- Listing 1.9
DBCC FREEPROCCACHE (<plan_handle>);