﻿declare @databaseName varchar(100)
declare @folderPath varchar(100)= {Path}
set @databaseName = {DBName}


IF OBJECT_ID('dbo.tempQueries', 'U') IS NOT NULL 
  DROP TABLE dbo.tempQueries; 

IF OBJECT_ID('dbo.tempQueriesCopy', 'U') IS NOT NULL 
  DROP TABLE dbo.tempQueriesCopy; 

--Export query prepration
select ROW_NUMBER() over (
		order by (
				select 1
				)
		) rownum
	,'select * FROM ' + @databaseName + '.' + '[' + SCHEMA_NAME(schema_id) + '].[' + t.name + ']' as col1
	,'select ' + STUFF((
			select ',' + case 
					when DATA_TYPE = 'datetime'
						or DATA_TYPE = 'datetime2'
						then 'CASE WHEN ' + COLUMN_NAME + ' IS NULL THEN ''null'' ELSE convert(nvarchar(28), ' + COLUMN_NAME + ', 121) end'
					when DATA_TYPE = 'varchar'
						or DATA_TYPE = 'nvarchar' 
						or DATA_TYPE = 'text' 
						or DATA_TYPE = 'xml'
						then 'CASE WHEN ' + COLUMN_NAME + ' IS NULL THEN ''null'' WHEN cast(' + COLUMN_NAME + ' as nvarchar(max)) = '''' THEN '' '' ELSE REPLACE(cast(' + COLUMN_NAME + ' as nvarchar(max)), CHAR(10),'''') end'
					when DATA_TYPE = 'binary'
						or DATA_TYPE = 'varbinary'
						or DATA_TYPE = 'image'
						or DATA_TYPE = 'timestamp'
						or DATA_TYPE = 'hierarchyid'
						then 'CASE WHEN ' + COLUMN_NAME + ' IS NULL THEN ''null'' ELSE substring(master.dbo.fn_varbintohexstr(' + COLUMN_NAME + '), 3, len(master.dbo.fn_varbintohexstr(' + COLUMN_NAME + '))) end'
					else 'CASE WHEN ' + COLUMN_NAME + ' IS NULL THEN ''null'' WHEN cast(' + COLUMN_NAME + ' as nvarchar(max)) = '''' THEN '' '' ELSE REPLACE(cast(' + COLUMN_NAME + ' as nvarchar(max)), CHAR(10),'''') end'

					end
			from INFORMATION_SCHEMA.COLUMNS
			where TABLE_NAME = t.name
				and TABLE_SCHEMA = schema_name(schema_id)
			order by table_schema
				,table_name
				,ordinal_position
			for xml PATH('')
			), 1, 1, '') + ' FROM ' + @databaseName + '.' + '[' + SCHEMA_NAME(schema_id) + '].[' + t.name + ']' as col2
	,SCHEMA_NAME(schema_id) + '."' + t.name + '"' as col3
into tempQueries
from sys.tables t
where schema_name(schema_id)+'.'+name in(select tablename from include_table_list)
or (select count(1) from include_table_list)=0

select * into  tempQueriesCopy from tempQueries