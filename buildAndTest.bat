@echo off



set RootPath=%~dp0
set zip="C:\Program Files\7-Zip\7z.exe"
SETLOCAL EnableDelayedExpansion

for /f "skip=1 tokens=1-6 delims= " %%a in ('wmic path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') do (
	IF NOT "%%~f"=="" (
		set /a FormattedDate=10000 * %%f + 100 * %%d + %%a
		set FormattedDate=!FormattedDate:~-6,2!!FormattedDate:~-4,2!!FormattedDate:~-2,2!
	)
)
set Version=%FormattedDate%


goto start

call API_test\bin\Debug\API_test.exe GET tmp/github.zip https://github.com/ProfilesRNS/ProfilesRNS/archive/master.zip
call %zip% x tmp/github.zip -otmp/github -r


pushd tmp\github\ProfilesRNS-master\Release
call BuildRelease.bat %Version%
popd

copy tmp\github\ProfilesRNS-master\Release\ProfilesRNS-%Version%.zip tmp\ProfilesRNS-%Version%.zip
call %zip% x tmp/ProfilesRNS-%Version%.zip -otmp/ProfilesRNS-%Version% -r
call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\Profiles\Profiles\Profiles.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=C:\inetpub\wwwroot\Profiles" /t:PublishToFileSystem
call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\ProfilesBetaAPI\Connects.Profiles.Service\Connects.Profiles.Service.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=C:\inetpub\wwwroot\ProfilesBetaAPI" /t:PublishToFileSystem
call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\ProfilesSearchAPI\ProfilesSearchAPI.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=C:\inetpub\wwwroot\ProfilesSearchAPI" /t:PublishToFileSystem
call C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild "tmp\ProfilesRNS-%Version%\ProfilesRNS\Website\SourceCode\ProfilesSPARQLAPI\ProfilesSPARQLAPI.csproj" "/p:Platform=AnyCPU;Configuration=Release;PublishDestination=C:\inetpub\wwwroot\ProfilesSPARQLAPI" /t:PublishToFileSystem

copy test_configuration_files\Profiles_Test3_Web.config C:\inetpub\wwwroot\Profiles\web.config
call API_test\bin\Debug\API_test.exe LINKS -b http://profilestest/profiles -d ProfilesRNS_Test3
call API_test\bin\Debug\API_test.exe GET tmp/index.html http://profilestest/index.html
call "c:\Program Files (x86)\LinkChecker\linkchecker.exe" http://profilestest/index.html -r2
if %errorlevel% neq 0 goto error

copy test_configuration_files\ProfilesSearchAPI_Web.config C:\inetpub\wwwroot\ProfilesSearchAPI\web.config
call API_test\bin\Debug\API_test.exe TESTPRNS -u http://profilestest/ProfilesSearchAPI/ProfilesSearchAPI.svc/Search -d ProfilesRNS_Test3
if %errorlevel% neq 0 goto error
:start
copy test_configuration_files\ProfilesSearchAPI_Web.config C:\inetpub\wwwroot\ProfilesSearchAPI\web.config
call API_test\bin\Debug\API_test.exe TESTSPARQL -u http://profilestest/ProfilesSPARQLAPI/ProfilesSPARQLAPI.svc/Search -d ProfilesRNS_Test3
if %errorlevel% neq 0 goto error

exit /b 0
:error
echo An error occured while running the Build and Test script
exit /b 1