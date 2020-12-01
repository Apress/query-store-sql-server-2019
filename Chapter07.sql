-- Listing 7.1 pg. 151
CREATE OR ALTER PROC [dbo].[AddressByCity] @City NVARCHAR(30)
AS
SELECT a.AddressID,
    a.AddressLine1,
    a.AddressLine2,
    a.City,
    sp.Name AS StateProvinceName,
    a.PostalCode
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp  ON a.StateProvinceID = sp.StateProvinceID
WHERE a.City = @City;
GO


-- Listing 7.2 pg. 152
EXEC dbo.AddressByCity @City = N'London';

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

EXEC dbo.AddressByCity @City = N'Mentor';


-- Listing 7.3 pg. 153
--Establish baseline behavior
EXEC dbo.AddressByCity @City = N'London';
GO 100

--Remove the plan from cache
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

--Compile a new plan
EXEC dbo.AddressByCity @City = N'Mentor';
GO

--Execute the code to show query regression
EXEC dbo.AddressByCity @City = N'London';
GO 100


-- Listing 7.4 pg. 165
EXEC sys.sp_query_store_force_plan 262,273;


-- Listing 7.5 pg.165
EXEC sys.sp_query_store_unforce_plan 262,273;


-- Listing 7.6 pg 165-166
SELECT qsq.query_id,
    qsp.plan_id,
    qsp.is_forced_plan
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp  ON qsp.query_id = qsq.query_id
WHERE qsq.query_id = 262;