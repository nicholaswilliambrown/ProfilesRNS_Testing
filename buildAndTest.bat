@echo off
SETLOCAL EnableDelayedExpansion
rem **************************************************************************************************************
rem **************************************************************************************************************
rem **************************************************************************************************************
rem ***
rem ***
rem ***  This is a testing script for ProfilesRNS
rem ***
rem ***
rem ***  This script is intended to be used as part of a continuous integration system to validate
rem ***  code committed to the ProfilesRNS repository.
rem ***
rem ***
rem ***  This script does the following:
rem ***     1. Downloads ProfilesRNS from github
rem ***     2. Creates a release zip file
rem ***     3. Builds a ProfilesRNS database, loads this with test data, and runs disambiguation, geocoding and profiles jobs
rem ***     4. Installs the ProfilesRNS website and APIs
rem ***     5. Runs Linkchecking software to check for 404 and 500 errors
rem ***     6. Tests the APIs
rem ***
rem ***
rem ***  Configuration:
rem ***     The Config.bat file contains all required configuration settings
rem ***
rem ***     This Script takes two arguments
rem ***         1. ConfigName - This describes which configuration defined in config.bat to use
rem ***         2. Version - this will typically be a timestamp generated by the task scheduler
rem ***
rem ***
rem **************************************************************************************************************
rem **************************************************************************************************************
rem **************************************************************************************************************


rem **************************************
rem *** load configuration settings
rem **************************************
call config.bat %*


rem **************************************
rem *** Build or download release zip
rem **************************************
if %build_release% equ true (
	call API_test\bin\Debug\API_test.exe GET tmp/github_%Version%.zip %GIT_URL%
	call %zip% x tmp/github_%Version%.zip -otmp/github_%Version% -r

	pushd tmp\github_%Version%\ProfilesRNS-master\Release
	call BuildRelease.bat %Version%
	if %errorlevel% neq 0 (
		Echo An error occured while building the release.
		exit /b 1
	)
	popd

	copy tmp\github_%Version%\ProfilesRNS-master\Release\ProfilesRNS-%Version%.zip tmp\ProfilesRNS-%Version%.zip

)
if %build_release% equ false (
	call API_test\bin\Debug\API_test.exe GET tmp/ProfilesRNS-%Version%.zip %RELEASE_URL%
)

call %zip% x tmp/ProfilesRNS-%Version%.zip -otmp/ProfilesRNS-%Version% -r
exit /b 1

rem **************************************
rem *** Build new database
rem **************************************
if %build_database% equ true (
	pushd Build_Database\
	call ProfilesRNS_Test_Database_Install.cmd %DB_NAME% %DATA_FILE_FOLDER% %ProfilesRNSBasePath% %TestingRootPath%tmp\ProfilesRNS-%Version%\ProfilesRNS\Database
	popd
)

rem **************************************
rem *** Copy files to wwwroot from 
rem *** binary folders and quicktest
rem **************************************
if %test_binary% equ true (
	del /S /F /Q %wwwroot%\%ProfilesPath%
	echo d | xcopy /s tmp\ProfilesRNS-%Version%\ProfilesRNS\Binary\Profiles\ %wwwroot%\%ProfilesPath%\
	
	copy %test_configuration_files%\Profiles_Test3_Web.config C:\inetpub\wwwroot\%ProfilesPath%\web.config
	call API_test\bin\Debug\API_test.exe QUICKLINKS -b %ProfilesRNSBasePath% -d %DB_NAME%
	if %errorlevel% neq 0 goto error
	call API_test\bin\Debug\API_test.exe GET tmp/index.html %IISRootUrl%/index.html
	call "c:\Program Files (x86)\LinkChecker\linkchecker.exe" %IISRootUrl%/index.html -r0 --timeout=240 --threads=-1
	if %errorlevel% neq 0 (
		Echo An error occured while Linkchecking.
		exit /b 1
	)

	del /S /F /Q %wwwroot%\%ProfilesBetaAPIPath%
	echo d | xcopy /s tmp\ProfilesRNS-%Version%\ProfilesRNS\Binary\ProfilesBetaAPI\ %wwwroot%\%ProfilesBetaAPIPath%\
	copy %test_configuration_files%\ProfilesBetaAPI_Web.config C:\inetpub\wwwroot\%ProfilesBetaAPIPath%\web.config
	call API_test\bin\Debug\API_test.exe TESTBETA -u %IISRootUrl%/%ProfilesBetaAPIPath%/ProfileService.svc/ProfileSearch -d %DB_NAME%
	if %errorlevel% neq 0 (
		Echo An error occured while testing ProfilesBetaAPI.
		exit /b 1
	)


	del /S /F /Q %wwwroot%\%ProfilesSearchAPIPath%
	echo d | xcopy /s tmp\ProfilesRNS-%Version%\ProfilesRNS\Binary\ProfilesSearchAPI\ %wwwroot%\%ProfilesSearchAPIPath%\
	copy %test_configuration_files%\ProfilesSearchAPI_Web.config C:\inetpub\wwwroot\%ProfilesSearchAPIPath%\web.config
	call API_test\bin\Debug\API_test.exe TESTPRNS -u %IISRootUrl%/%ProfilesSearchAPIPath%/ProfilesSearchAPI.svc/Search -d %DB_NAME%
	if %errorlevel% neq 0 (
		Echo An error occured while testing ProfilesSearchAPI .
		exit /b 1
	)
	
	del /S /F /Q %wwwroot%\%ProfilesSPARQLAPIPath%
	echo d | xcopy /s tmp\ProfilesRNS-%Version%\ProfilesRNS\Binary\ProfilesSPARQLAPI\ %wwwroot%\%ProfilesSPARQLAPIPath%\
	copy %test_configuration_files%\ProfilesSPARQLAPI_Web.config C:\inetpub\wwwroot\%ProfilesSPARQLAPIPath%\web.config
	call API_test\bin\Debug\API_test.exe TESTSPARQL -u %IISRootUrl%/%ProfilesSPARQLAPIPath%/ProfilesSPARQLAPI.svc/Search -d %DB_NAME%
	if %errorlevel% neq 0 (
		Echo An error occured while testing ProfilesSPARQLAPI.
		exit /b 1
	)
)

rem **************************************
rem *** Publish files to wwwroot from 
rem *** source code folders and quicktest
rem **************************************
if %test_source% equ true (
	del /S /F /Q %wwwroot%\%ProfilesPath%
	call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\Profiles\Profiles\Profiles.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=%wwwroot%\%ProfilesPath%" /t:PublishToFileSystem
	if %errorlevel% neq 0 (
		Echo An error occured while compiling ProfilesRNS Application.
		exit /b 1
	)
	
	copy %test_configuration_files%\Profiles_Test3_Web.config C:\inetpub\wwwroot\%ProfilesPath%\web.config
	call API_test\bin\Debug\API_test.exe QUICKLINKS -b %ProfilesRNSBasePath% -d %DB_NAME%
	if %errorlevel% neq 0 goto error
	call API_test\bin\Debug\API_test.exe GET tmp/index.html %IISRootUrl%/index.html
	call "c:\Program Files (x86)\LinkChecker\linkchecker.exe" %IISRootUrl%/index.html -r0 --timeout=240 --threads=-1
	if %errorlevel% neq 0 (
		Echo An error occured while Linkchecking.
		exit /b 1
	)

	del /S /F /Q %wwwroot%\%ProfilesBetaAPIPath%
	call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\ProfilesBetaAPI\Connects.Profiles.Service\Connects.Profiles.Service.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=%wwwroot%\%ProfilesBetaAPIPath%" /t:PublishToFileSystem
	if %errorlevel% neq 0 (
		Echo An error occured while compiling ProfilesBetaAPI.
		exit /b 1
	)
	
	copy %test_configuration_files%\ProfilesBetaAPI_Web.config C:\inetpub\wwwroot\%ProfilesBetaAPIPath%\web.config
	call API_test\bin\Debug\API_test.exe TESTBETA -u %IISRootUrl%/%ProfilesBetaAPIPath%/ProfileService.svc/ProfileSearch -d %DB_NAME%
	if %errorlevel% neq 0 (
		Echo An error occured while testing ProfilesBetaAPI.
		exit /b 1
	)


	del /S /F /Q %wwwroot%\%ProfilesSearchAPIPath%
	call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\ProfilesSearchAPI\ProfilesSearchAPI.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=%wwwroot%\%ProfilesSearchAPIPath%" /t:PublishToFileSystem
	if %errorlevel% neq 0 (
		Echo An error occured while compiling ProfilesSearchAPI.
		exit /b 1
	)

	copy %test_configuration_files%\ProfilesSearchAPI_Web.config C:\inetpub\wwwroot\%ProfilesSearchAPIPath%\web.config
	call API_test\bin\Debug\API_test.exe TESTPRNS -u %IISRootUrl%/%ProfilesSearchAPIPath%/ProfilesSearchAPI.svc/Search -d %DB_NAME%
	if %errorlevel% neq 0 (
		Echo An error occured while testing ProfilesSearchAPI .
		exit /b 1
	)
	
	del /S /F /Q %wwwroot%\%ProfilesSPARQLAPIPath%
	call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\ProfilesSPARQLAPI\ProfilesSPARQLAPI.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=%wwwroot%\%ProfilesSPARQLAPIPath%" /t:PublishToFileSystem
	if %errorlevel% neq 0 (
		Echo An error occured while compiling ProfilesSPARQLAPI.
		exit /b 1
	)
	
	copy %test_configuration_files%\ProfilesSPARQLAPI_Web.config C:\inetpub\wwwroot\%ProfilesSPARQLAPIPath%\web.config
	call API_test\bin\Debug\API_test.exe TESTSPARQL -u %IISRootUrl%/%ProfilesSPARQLAPIPath%/ProfilesSPARQLAPI.svc/Search -d %DB_NAME%
	if %errorlevel% neq 0 (
		Echo An error occured while testing ProfilesSPARQLAPI.
		exit /b 1
	)
)

REM use this section to skip link checking if you want to save time
rem goto skipLinkChecking
copy %test_configuration_files%\Profiles_Test3_Web.config C:\inetpub\wwwroot\%ProfilesPath%\web.config
call API_test\bin\Debug\API_test.exe LINKS -b %ProfilesRNSBasePath% -d %DB_NAME%
if %errorlevel% neq 0 goto error
call API_test\bin\Debug\API_test.exe GET tmp/index.html %IISRootUrl%/index.html
call "c:\Program Files (x86)\LinkChecker\linkchecker.exe" %IISRootUrl%/index.html -r1 --timeout=240 --threads=-1
if %errorlevel% neq 0 (
	Echo An error occured while Linkchecking.
	exit /b 1
)

copy %test_configuration_files%\Profiles_Test3_Web.config C:\inetpub\wwwroot\%ProfilesPath%\web.config
call API_test\bin\Debug\API_test.exe QUICKLINKS -b %ProfilesRNSBasePath% -d %DB_NAME%
if %errorlevel% neq 0 goto error
call API_test\bin\Debug\API_test.exe GET tmp/index.html %IISRootUrl%/index.html
call "c:\Program Files (x86)\LinkChecker\linkchecker.exe" %IISRootUrl%/index.html -r2 --timeout=240 --threads=-1
if %errorlevel% neq 0 (
	Echo An error occured while Linkchecking.
	exit /b 1
)



:skipLinkChecking



:start
copy %test_configuration_files%\ProfilesBetaAPI_Web.config C:\inetpub\wwwroot\%ProfilesBetaAPIPath%\web.config
call API_test\bin\Debug\API_test.exe TESTBETA -u %IISRootUrl%/%ProfilesBetaAPIPath%/ProfileService.svc/ProfileSearch -d %DB_NAME%
if %errorlevel% neq 0 (
	Echo An error occured while testing ProfilesBetaAPI.
	exit /b 1
)
goto end
net stop Tomcat7
rmdir /s /q c:\Shindig\apache-tomcat-7.0.53\webapps\shindigorng\
copy tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\ORNG\shindigorng.war C:\Shindig\apache-tomcat-7.0.53\webapps\shindigorng.war
copy %test_configuration_files%\shindigorng.properties C:\Shindig\apache-tomcat-7.0.53\shindigconf\shindigorng.properties
net start Tomcat7
:end

exit /b 0
:error
echo An error occured while running the Build and Test script
exit /b 1