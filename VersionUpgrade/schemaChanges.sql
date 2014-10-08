-- This checks a bunch of stuff, but it ignores primary key constraints, and freetext indexes.
;with new as (
	select s.name as schemaName, o.name as objectName, type_desc as objectType, m.definition as def from sys.schemas s
	join sys.objects o
	on s.schema_id = o.schema_id
	join sys.sql_modules m
	on o.object_id = m.object_id
	where type_desc in ('VIEW', 'SQL_TABLE_VALUED_FUNCTION',
						'SQL_STORED_PROCEDURE', 'FOREIGN_KEY_CONSTRAINT',
						'USER_TABLE', 'SQL_SCALAR_FUNCTION')
), old as (
	select s.name as schemaName, o.name as objectName, type_desc as objectType, m.definition as def from $(UpgradeDatabaseName).sys.schemas s
	join $(UpgradeDatabaseName).sys.objects o
	on s.schema_id = o.schema_id
	join $(UpgradeDatabaseName).sys.sql_modules m
	on o.object_id = m.object_id
	where type_desc in ('VIEW', 'SQL_TABLE_VALUED_FUNCTION',
						'SQL_STORED_PROCEDURE', 'FOREIGN_KEY_CONSTRAINT',
						'USER_TABLE', 'SQL_SCALAR_FUNCTION')
) select new.objectName, old.objectName from new 
full outer join old
	on new.schemaName = old.schemaName
	and new.objectName = old.objectName
	and new.objectType = old.objectType
where old.schemaName is null or new.schemaName is null
or replace(replace(old.def,char(13),''),char(10),'') <> replace(replace(new.def,char(13),''),char(10),'')


