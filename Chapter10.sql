-- Listing 10.11
EXEC sp_BlitzQueryStore @DatabaseName = 'AdventureWorks'


-- Listing 10.12
EXEC sp_BlitzQueryStore @DatabaseName = 'AdventureWorks', 
						@StartDate = '20170526', 
						@EndDate = '20170527'

-- Listing 10.13
EXEC sp_BlitzQueryStore @DatabaseName = 'AdventureWorks',
						@Top = 1, 
						@StoredProcName = 'MyStoredProcedure'
						

-- Listing 10.14
EXEC sp_BlitzQueryStore @DatabaseName = 'AdventureWorks',
						@Top = 1, 
						@Failed = 1


-- Listing 10.15
EXEC sp_BlitzQueryStore @DatabaseName = 'AdventureWorks',
						@PlanIdFilter = 3356
						
					
-- Listing 10.16
EXEC sp_BlitzQueryStore @DatabaseName = 'AdventureWorks',
						@QueryIdFilter = 2958
						
						
