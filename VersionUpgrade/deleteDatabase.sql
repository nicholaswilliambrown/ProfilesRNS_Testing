if exists (select * from sysdatabases where [name] = '$(YourProfilesDatabaseName)')
begin
	ALTER DATABASE [$(YourProfilesDatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [$(YourProfilesDatabaseName)]
end
go