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

if %ConfigName% equ release_test_20 (
	set build_release=false
	set build_database=false
	set RELEASE_URL=%3
	set test_data=ProfilesRNS_Test4
	set DATA_FILE_FOLDER=ProfilesRNS_Test4
	set DB_NAME=ProfilesRNS_nwb2
	set GIT_URL=https://github.com/nicholaswilliambrown/ProfilesRNS/archive/master.zip
	set ProfilesPath=NWB_Profiles
	set ProfilesBetaAPIPath=NWB_ProfilesBetaAPI
	set ProfilesSearchAPIPath=NWB_ProfilesSearchAPI
	set ProfilesSPARQLAPIPath=NWB_ProfilesSPARQLAPI
	set test_configuration_files=NWB_test_configuration_files
)

if %test_data% equ ProfilesRNS_Test3 (
	set DATA_FILE_FOLDER=ProfilesRNS_Test3
)
if %test_data% equ ProfilesRNS_Test4 (
	set DATA_FILE_FOLDER=ProfilesRNS_Test4
)