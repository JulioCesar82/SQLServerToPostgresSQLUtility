﻿declare @databaseName varchar(100)

set @databaseName = {DBName}

declare @TableToInclude table (TableName varchar(200))
{TableNames}

--sp_helptext 'dbo.GetMigrationString'
select 'create schema ' + name + '; ALTER SCHEMA public OWNER TO postgres;'
from sys.schemas
where name not like 'db[_]%'
	and name <> 'sys'
	and name <> 'INFORMATION_SCHEMA'

