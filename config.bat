@echo off
set ConfigName=%1
set Version=%2
set ReleaseCandidate=%3

set TestingRootPath=%~dp0
set zip="C:\Program Files\7-Zip\7z.exe"
set IISRootUrl=http://profilestest/
set wwwroot=C:\inetpub\wwwroot

rem set up defaults (do nothing)
rem Build or download release zip
set download_release=false
set build_local=false
set build_from_github=false
set RELEASE_URL=null
set GIT_URL=null
set post_zip_file=false
set post_zip_file_folder=null
set post_zip_file_index=null
	
rem tests
set linkcheck=false
set test_source=false
set test_binary=false
	
rem Test Data
set build_database=false
set test_data=null
set DATA_FILE_FOLDER=null
	
rem Environment
set SQL_VERSION=null
set DB_NAME=null
set ProfilesPath=null
set ProfilesBetaAPIPath=null
set ProfilesSearchAPIPath=null
set ProfilesSPARQLAPIPath=null
set test_configuration_files=null

if %ConfigName% equ full_test_500_nwb (
	rem Build or download release zip
	set build_from_github=true
	set GIT_URL=https://github.com/nicholaswilliambrown/ProfilesRNS/archive/master.zip
	
	rem tests
	set linkcheck=true
	set test_source=true
	set test_binary=true
	
	rem Test Data
	set build_database=true
	set test_data=ProfilesRNS_Test3
	set DATA_FILE_FOLDER=ProfilesRNS_Test3
	
	rem Environment
	set SQL_VERSION=SQL2012
	set DB_NAME=ProfilesRNS_nwb
	set ProfilesPath=NWB_Profiles
	set ProfilesBetaAPIPath=NWB_ProfilesBetaAPI
	set ProfilesSearchAPIPath=NWB_ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=NWB_ProfilesSPARQLAPI
	set test_configuration_files=NWB_test_configuration_files
)

if %ConfigName% equ full_test_20_nwb (
	rem Build or download release zip
	set build_from_github=true
	set GIT_URL=https://github.com/nicholaswilliambrown/ProfilesRNS/archive/master.zip
	
	rem tests
	set linkcheck=true
	set test_source=true
	set test_binary=true
	
	rem Test Data
	set build_database=true
	set test_data=ProfilesRNS_TestData_20
	set DATA_FILE_FOLDER=ProfilesRNS_TestData_20
	
	rem Environment
	set SQL_VERSION=SQL2012
	set DB_NAME=ProfilesRNS_nwb
	set ProfilesPath=NWB_Profiles
	set ProfilesBetaAPIPath=NWB_ProfilesBetaAPI
	set ProfilesSearchAPIPath=NWB_ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=NWB_ProfilesSPARQLAPI
	set test_configuration_files=NWB_test_configuration_files
)

if %ConfigName% equ build_zip_nwb (
	set build_from_github=true
	set GIT_URL=https://github.com/nicholaswilliambrown/ProfilesRNS/archive/master.zip
	set post_zip_file=true
	set post_zip_file_folder=\\itwvwebip02\WebApps\ProfilesReleaseZips
	set post_zip_file_index=Latest_Zip_nwb.txt
)


set ProfilesRNSBasePath=%IISRootUrl%%ProfilesPath%