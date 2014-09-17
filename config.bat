@echo off
set ConfigName=%1
set Version=%2

set TestingRootPath=%~dp0
set zip="C:\Program Files\7-Zip\7z.exe"
set IISRootUrl=http://profilestest/
set wwwroot=C:\inetpub\wwwroot


if %ConfigName% equ full_test_500_nwb (
	set build_release=true
	set build_database=true
	set test_data=ProfilesRNS_Test3
	set DB_NAME=ProfilesRNS_Test3
	set DATA_FILE_FOLDER=ProfilesRNS_Test4
	set GIT_URL=https://github.com/ProfilesRNS/ProfilesRNS/archive/master.zip
	set ProfilesPath=Profiles
	set ProfilesBetaAPIPath=ProfilesBetaAPI
	set ProfilesSearchAPIPath=ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=ProfilesSPARQLAPI
	set test_configuration_files=test_configuration_files
)

if %ConfigName% equ full_test_20_nwb (
	set build_release=true
	set build_database=true
	set test_data=ProfilesRNS_Test4
	set DATA_FILE_FOLDER=ProfilesRNS_Test4
	set DB_NAME=ProfilesRNS_nwb
	set GIT_URL=https://github.com/nicholaswilliambrown/ProfilesRNS/archive/master.zip
	set Version=%Version%nwb
	set ProfilesPath=NWB_Profiles
	set ProfilesBetaAPIPath=NWB_ProfilesBetaAPI
	set ProfilesSearchAPIPath=NWB_ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=NWB_ProfilesSPARQLAPI
	set test_configuration_files=NWB_test_configuration_files
)

if %ConfigName% equ build_database_20 (


	rem Build or download release zip
	set download_release=true
	set build_release=false
	set build_local=false
	set build_from_github=false
	set RELEASE_URL=%3
	set GIT_URL=https://github.com/nicholaswilliambrown/ProfilesRNS/archive/master.zip
	
	rem tests
	set build_database=true
	set linkcheck=false
	set test_source=false
	set test_binary=false
	
	rem Test Data
	set test_data=ProfilesRNS_TestData_20
	set DATA_FILE_FOLDER=ProfilesRNS_TestData_20
	
	rem Environment
	set DB_NAME=ProfilesRNS
	set ProfilesPath=Profiles
	set ProfilesBetaAPIPath=ProfilesBetaAPI
	set ProfilesSearchAPIPath=ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=ProfilesSPARQLAPI
	set test_configuration_files=test_configuration_files
)


if %ConfigName% equ release_test_20 (
	rem Download location
	set RELEASE_URL=%3

	rem tests
	set build_release=false
	set build_database=false
	set linkcheck=false
	set test_source=false
	set test_binary=false
	
	rem Test Data
	set test_data=ProfilesRNS_TestData_20
	set DATA_FILE_FOLDER=ProfilesRNS_TestData_40
	
	rem Environment
	set DB_NAME=ProfilesRNS_nwb
	set ProfilesPath=NWB_Profiles
	set ProfilesBetaAPIPath=NWB_ProfilesBetaAPI
	set ProfilesSearchAPIPath=NWB_ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=NWB_ProfilesSPARQLAPI
	set test_configuration_files=NWB_test_configuration_files
)


if %ConfigName% equ build_local (
	rem Download location
	set RELEASE_URL=%3

	rem tests
	set build_local=true
	set build_from_github=false
	set build_database=false
	set linkcheck=false
	set test_source=false
	set test_binary=true
	
	rem Test Data
	set test_data=ProfilesRNS_TestData_20
	set DATA_FILE_FOLDER=ProfilesRNS_TestData_40
	
	rem Environment
	set DB_NAME=ProfilesRNS_nwb
	set ProfilesPath=NWB_Profiles
	set ProfilesBetaAPIPath=NWB_ProfilesBetaAPI
	set ProfilesSearchAPIPath=NWB_ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=NWB_ProfilesSPARQLAPI
	set test_configuration_files=NWB_test_configuration_files
)

set ProfilesRNSBasePath=%IISRootUrl%%ProfilesPath%