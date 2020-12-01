-- Listing 10.1
Install-Module dbatools


-- Listing 10.2
Get-DbaDbQueryStoreOption -SqlInstance MyServer


-- Listing 10.3
Get-DbaDbQueryStoreOption -SqlInstance MyServer -Database AdventureWorks


-- Listing 10.4
Get-DbaDbQueryStoreOption -SqlInstance MyServer | Format-Table -AutoSize -Wrap


-- Listing 10.5
Get-DbaDbQueryStoreOption -SqlInstance MyServer | Where-Object {$_.ActualState -eq "ReadWrite"}


-- Listing 10.6
Set-DbaDbQueryStoreOption -SqlInstance MyServer -State ReadWrite -FlushInterval 900 -CollectionInterval 60 -MaxSize 2048 -CaptureMode AUTO -CleanupMode Auto -StaleQueryThreshold 30


-- Listing 10.7 
Set-DbaDbQueryStoreOption -SqlInstance MyServer -Database AdventureWorks -MaxSize 4096 -CollectionInterval 15 


-- Listing 10.8
Copy-DbaDbQueryStoreOption -Source MyServerA -SourceDatabase AdventureWorks -Destination MyServerB -AllDatabases


-- Listing 10.9
Copy-DbaDbQueryStoreOption -Source MyServerA -SourceDatabase AdventureWorks -Destination MyServerB -DestinationDatabase AdventuresWorksDW


-- Listing 10.10
Install-DbaFirstResponderKit -Server MyServer -Database master


