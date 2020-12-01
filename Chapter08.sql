-- Listing 8.1 Pg 170
CREATE INDEX ix_ActualCost ON dbo.bigTransactionHistory (ActualCost);
GO

--a simple query for the experiment
CREATE OR ALTER PROCEDURE dbo.ProductByCost (@ActualCost MONEY)
AS
SELECT bth.ActualCost
FROM dbo.bigTransactionHistory AS bth
    JOIN dbo.bigProduct AS p ON p.ProductID = bth.ProductID
WHERE bth.ActualCost = @ActualCost;
GO

--ensuring that Query Store is on and has a clean data set
ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;
ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;
GO

-- Listing 8.2 pg 171
-- 1. Establish a history of query performance
EXEC dbo.ProductByCost @ActualCost = 8.2205;
GO 30

-- 2. Remove the plan from cache
DECLARE @PlanHandle VARBINARY(64);

SELECT @PlanHandle = deps.plan_handle
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.ProductByCost');

IF @PlanHandle IS NOT NULL
BEGIN
    DBCC FREEPROCCACHE(@PlanHandle);
END
GO

-- 3. Execute a query that will result in a different plan
EXEC dbo.ProductByCost @ActualCost = 0.0;
GO

-- 4. Establish a new history of poor performance
EXEC dbo.ProductByCost @ActualCost = 8.2205;
GO 15


--Listng 8.3 pg 172
SELECT ddtr.type,
    ddtr.reason,
    ddtr.last_refresh,
    ddtr.state,
    ddtr.score,
    ddtr.details
FROM sys.dm_db_tuning_recommendations AS ddtr;


--Listing 8.4 pg 176-177
;WITH DbTuneRec
AS (SELECT ddtr.reason,
           ddtr.score,
           pfd.query_id,
           pfd.regressedPlanId,
           pfd.recommendedPlanId,
           JSON_VALUE(ddtr.state, '$.currentValue') AS CurrentState,
           JSON_VALUE(ddtr.state, '$.reason') AS CurrentStateReason,
           JSON_VALUE(ddtr.details, '$.implementationDetails.script') AS ImplementationScript
    FROM sys.dm_db_tuning_recommendations AS ddtr
        CROSS APPLY
        OPENJSON(ddtr.details, '$.planForceDetails')
        WITH
        (
            query_id INT '$.queryId',
            regressedPlanId INT '$.regressedPlanId',
            recommendedPlanId INT '$.recommendedPlanId'
        ) AS pfd
   )
SELECT qsq.query_id,
       dtr.reason,
       dtr.score,
       dtr.CurrentState,
       dtr.CurrentStateReason,
       qsqt.query_sql_text,
       CAST(rp.query_plan AS XML) AS RegressedPlan,
       CAST(sp.query_plan AS XML) AS SuggestedPlan,
       dtr.ImplementationScript
FROM DbTuneRec AS dtr
    JOIN sys.query_store_plan AS rp
        ON rp.query_id = dtr.query_id
           AND rp.plan_id = dtr.regressedPlanId
    JOIN sys.query_store_plan AS sp
        ON sp.query_id = dtr.query_id
           AND sp.plan_id = dtr.recommendedPlanId
    JOIN sys.query_store_query AS qsq
        ON qsq.query_id = rp.query_id
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;


 -- Listing 8.5 pg. 180
 ALTER DATABASE current SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);


 -- Listing 8.6 pg. 180
 ALTER DATABASE current SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = OFF);


-- Listing 8.7 181
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE AdventureWorks SET QUERY_STORE CLEAR;
GO
EXEC dbo.ProductByCost @ActualCost = 8.2205;
GO 30

--remove the plan from cache
DECLARE @PlanHandle VARBINARY(64);

SELECT @PlanHandle = deps.plan_handle
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.ProductByCost');

IF @PlanHandle IS NOT NULL
BEGIN
    DBCC FREEPROCCACHE(@PlanHandle);
END
GO

--execute a query that will result in a different plan
EXEC dbo.ProductByCost @ActualCost = 0.0;
GO

--establish a new history of poor performance
EXEC dbo.ProductByCost @ActualCost = 8.2205;
GO 15


-- Listing 8.8 pg 185
SELECT qsws.wait_category_desc,
    qsws.total_query_wait_time_ms,
    qsws.avg_query_wait_time_ms,
    qsws.stdev_query_wait_time_ms
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp  ON qsp.query_id = qsq.query_id
    JOIN sys.query_store_wait_stats AS qsws  ON qsws.plan_id = qsp.plan_id
    JOIN sys.query_store_runtime_stats_interval AS qsrsi  ON qsrsi.runtime_stats_interval_id = qsws.runtime_stats_interval_id
WHERE qsq.object_id = OBJECT_ID('dbo.ProductByCost');