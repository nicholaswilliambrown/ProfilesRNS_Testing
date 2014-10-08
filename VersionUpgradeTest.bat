@echo off
SETLOCAL EnableDelayedExpansion

rem **************************************
rem *** load configuration settings
rem **************************************
call config.bat %*

set DB_NAME=ProfilesRNS_nwb
set UPGRADE_DB_NAME=Profiles_2_0_0
set UPGRADE_DB_BACKUP_PATH=C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\Profiles_2_0_0.bak
set UPGRADE_FILES_PATH=C:\Users\nwb4\Documents\Profiles Opensource\nicholaswilliambrown\ProfilesRNS\Database\VersionUpgrade\
set ProfilesRNSRootPath=C:\Users\nwb4\Documents\Profiles Opensource\nicholaswilliambrown\ProfilesRNS\Database


echo . Deleting old ProfilesRNS upgrade database if it exists.
sqlcmd -S . -d master -v YourProfilesServerName="." YourProfilesDatabaseName="%UPGRADE_DB_NAME%" -E -i VersionUpgrade\deleteDatabase.sql

echo . Restoring ProfilesRNS upgrade database .
sqlcmd -S . -d master -E -Q "RESTORE DATABASE [%UPGRADE_DB_NAME%] FROM DISK='%UPGRADE_DB_BACKUP_PATH%'"

echo . Running schema upgrade script.
sqlcmd -S . -d %UPGRADE_DB_NAME% -E -i "%UPGRADE_FILES_PATH%ProfilesRNS_Upgrade_Schema.sql"

echo . Testing schema upgrade.
sqlcmd -S . -d %DB_NAME% -v YourProfilesServerName="." UpgradeDatabaseName="%UPGRADE_DB_NAME%" -E -i VersionUpgrade\schemaChanges.sql

echo . Running data upgrade script.
sqlcmd -S . -d %UPGRADE_DB_NAME% -v ProfilesRNSRootPath="%ProfilesRNSRootPath%" -E -i "%UPGRADE_FILES_PATH%ProfilesRNS_Upgrade_Data.sql"

echo . Testing schema upgrade.
sqlcmd -S . -d %DB_NAME% -v YourProfilesServerName="." UpgradeDatabaseName="%UPGRADE_DB_NAME%" -E -i VersionUpgrade\InstallDataChanges.sql

if !errorlevel! neq 0 (
	Echo An error occured while testing data upgrade.
	exit /b 1
)