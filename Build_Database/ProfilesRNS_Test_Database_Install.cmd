@echo off

REM
REM
REM  Copyright (c) 2008-2013 by the President and Fellows of Harvard College. All rights reserved.  Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD., and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the National Center for Research Resources and Harvard University.
REM
REM  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
REM      * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
REM      * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
REM      * Neither the name "Harvard" nor the names of its contributors nor the name "Harvard Catalyst" may be used to endorse or promote products derived from this software without specific prior written permission.
REM  
REM  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER (PRESIDENT AND FELLOWS OF HARVARD COLLEGE) AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
REM  
REM  


set DB_NAME=%1
set DATA_FILE_FOLDER=%2
set ProfilesRNSBasePath=%3
set automated_testing_path=%~dp0
rem set RootPath=%~dp0
rem set RootPath=%RootPath:\Automated_Testing\Build_Database\=\Database\%
set RootPath=%4
set SQL_VERSION=%5

echo . Creating new ProfilesRNS database
sqlcmd -S . -d master -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -E -i ProfilesRNS_CreateDatabase.sql 

goto skipschema
echo . Creating ProfilesRNS Schema
del "%RootPath%\ProfilesRNS_CreateSchema.sql"
cd "%RootPath%\schema"
call CreateSchemaInstallScript.bat > ..\ProfilesRNS_CreateSchema.sql
cd %automated_testing_path%
:skipschema
sqlcmd -S . -d "%DB_NAME%" -E -i "%RootPath%\ProfilesRNS_CreateSchema.sql"

echo . Creating ProfilesRNS Accounts
sqlcmd -S . -d "%DB_NAME%" -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -E -i ProfilesRNS_CreateAccount.sql 

echo . Importing Ontology Data

sqlcmd -S . -d "%DB_NAME%" -E -v ProfilesRNSRootPath="%RootPath%" ProfilesRNSBasePath="%ProfilesRNSBasePath%" -i "%RootPath%\ProfilesRNS_DataLoad_Part1.sql"

echo . Dropping various ProfilesRNS jobs
sqlcmd -S . -d "%DB_NAME%" -E -Q "exec msdb.dbo.sp_delete_job @job_name ='%DB_NAME%_PubMedDisambiguation_GetPubs'"
sqlcmd -S . -d "%DB_NAME%" -E -Q "exec msdb.dbo.sp_delete_job @job_name ='%DB_NAME%_PubMedDisambiguation_GetPubMEDXML'"
sqlcmd -S . -d "%DB_NAME%" -E -Q "exec msdb.dbo.sp_delete_job @job_name ='%DB_NAME%_ProfilesRNS_GeoCode'"
sqlcmd -S . -d "%DB_NAME%" -E -Q "exec msdb.dbo.sp_delete_job @job_name ='%DB_NAME%_ExporterDisambiguation_GetFunding'"

REM echo . Dropping various SSIS packages
dtutil /SQL ProfilesGeoCode /DELETE
dtutil /SQL PubMedDisambiguation_GetPubMEDXML /DELETE
dtutil /SQL PubMedDisambiguation_GetPubs /DELETE
dtutil /SQL ExporterDisambiguation_GetFunding /DELETE

echo . Installing PubMedDisambiguation_GetPubs SSIS package
dtutil /FILE "%RootPath%\%SQL_VERSION%\PubMedDisambiguation_GetPubs.dtsx" /DestServer . /COPY SQL;PubMedDisambiguation_GetPubs

echo . Installing PubMedDisambiguation_GetPubMEDXML SSIS package
dtutil /FILE "%RootPath%\%SQL_VERSION%\PubMedDisambiguation_GetPubMEDXML.dtsx" /DestServer . /COPY SQL;PubMedDisambiguation_GetPubMEDXML

echo . Installing ProfilesGeoCode SSIS package
dtutil /FILE "%RootPath%\%SQL_VERSION%\ProfilesGeoCode.dtsx" /DestServer . /COPY SQL;ProfilesGeoCode

echo . Installing ProfilesGeoCode SSIS package
dtutil /FILE "%RootPath%\%SQL_VERSION%\ExporterDisambiguation_GetFunding.dtsx" /DestServer . /COPY SQL;ExporterDisambiguation_GetFunding

echo . Creating ProfilesRNS Disambiguation and GeoCodeing jobs
rem sqlcmd -S . -d %DB_NAME% -E -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -i "PubMedDisambiguation_and_GeoCode.sql"
..\API_test\bin\Debug\API_test.exe REPLACE -i "%RootPath%\%SQL_VERSION%\PubMedDisambiguation_GetPubs.sql" -o "%RootPath%\%DB_NAME%_PubMedDisambiguation_GetPubs.sql" -r "@job_name=N'PubMedDisambiguation_GetPubs'" -w "@job_name=N'%DB_NAME%_PubMedDisambiguation_GetPubs'"
..\API_test\bin\Debug\API_test.exe REPLACE -i "%RootPath%\%SQL_VERSION%\PubMedDisambiguation_GetPubMEDXML.sql" -o "%RootPath%\%DB_NAME%_PubMedDisambiguation_GetPubMEDXML.sql" -r "@job_name=N'PubMedDisambiguation_GetPubMEDXML'" -w "@job_name=N'%DB_NAME%_PubMedDisambiguation_GetPubMEDXML'"
..\API_test\bin\Debug\API_test.exe REPLACE -i "%RootPath%\ProfilesRNS_GeoCodeJob.sql" -o "%RootPath%\%DB_NAME%_ProfilesRNS_GeoCodeJob.sql" -r "@job_name=N'ProfilesRNSGeoCode'" -w "@job_name=N'%DB_NAME%_ProfilesRNS_GeoCode'"

..\API_test\bin\Debug\API_test.exe REPLACE -i "%RootPath%\ExporterDisambiguation_GetFunding.sql" -o "%RootPath%\%DB_NAME%_ExporterDisambiguation_GetFunding.sql" -r "@job_name=N'ExporterDisambiguation_GetFunding'" -w "@job_name=N'%DB_NAME%_ExporterDisambiguation_GetFunding'"

sqlcmd -S . -d %DB_NAME% -E -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -i "%RootPath%\%DB_NAME%_PubMedDisambiguation_GetPubs.sql"
sqlcmd -S . -d %DB_NAME% -E -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -i "%RootPath%\%DB_NAME%_PubMedDisambiguation_GetPubMEDXML.sql"
sqlcmd -S . -d %DB_NAME% -E -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -i "%RootPath%\%DB_NAME%_ProfilesRNS_GeoCodeJob.sql"
sqlcmd -S . -d %DB_NAME% -E -v YourProfilesServerName="." YourProfilesDatabaseName="%DB_NAME%" -i "%RootPath%\%DB_NAME%_ExporterDisambiguation_GetFunding.sql"


echo . Loading test data.
sqlcmd -S . -d %DB_NAME% -E -i %DATA_FILE_FOLDER%\data.sql

sqlcmd -S . -d %DB_NAME% -E -Q "EXEC [Profile.Import].[LoadProfilesData]"

echo . Running jobs
sqlcmd -S . -d %DB_NAME% -E -i "%RootPath%\ProfilesRNS_DataLoad_Part3.sql"

echo . Running custom SQL
sqlcmd -S . -d %DB_NAME% -E -i %DATA_FILE_FOLDER%\CustomSQL.sql

rem sqlcmd -S . -d %DB_NAME% -E -Q "exec msdb.dbo.sp_start_job @job_name ='%DB_NAME%_PubMedDisambiguation_and_GeoCode'"

echo . Running Disambigaution
sqlcmd -S . -d %DB_NAME% -E -Q "exec msdb.dbo.sp_start_job @job_name ='%DB_NAME%_PubMedDisambiguation_GetPubs'"
sqlcmd -S . -d master -E -v JobName="%DB_NAME%_PubMedDisambiguation_GetPubs" -i WaitForJob.sql

echo . Downloading publication XML
sqlcmd -S . -d %DB_NAME% -E -Q "exec msdb.dbo.sp_start_job @job_name ='%DB_NAME%_PubMedDisambiguation_GetPubMEDXML'"
sqlcmd -S . -d master -E -v JobName="%DB_NAME%_PubMedDisambiguation_GetPubMEDXML" -i WaitForJob.sql

echo . Running Geocode Job
sqlcmd -S . -d %DB_NAME% -E -Q "exec msdb.dbo.sp_start_job @job_name ='%DB_NAME%_ProfilesRNS_GeoCode'"
sqlcmd -S . -d master -E -v JobName="%DB_NAME%_ProfilesRNS_GeoCode" -i WaitForJob.sql

echo . Running Funding Disambiguation Job
sqlcmd -S . -d %DB_NAME% -E -Q "exec msdb.dbo.sp_start_job @job_name ='%DB_NAME%_ExporterDisambiguation_GetFunding'"
sqlcmd -S . -d master -E -v JobName="%DB_NAME%_ExporterDisambiguation_GetFunding" -i WaitForJob.sql

Echo . JobGroup 7
sqlcmd -S . -d %DB_NAME% -E -Q "EXEC [Framework.].[RunJobGroup] @JobGroup = 7"

Echo . JobGroup 8
sqlcmd -S . -d %DB_NAME% -E -Q "EXEC [Framework.].[RunJobGroup] @JobGroup = 8"

Echo . JobGroup 9
sqlcmd -S . -d %DB_NAME% -E -Q "EXEC [Framework.].[RunJobGroup] @JobGroup = 9"

Echo . JobGroup 3
sqlcmd -S . -d %DB_NAME% -E -Q "EXEC [Framework.].[RunJobGroup] @JobGroup = 3"

rem echo . Loading ORNG components
rem sqlcmd -S . -d %DB_NAME% -E -i "%RootPath%\ORNG\ORNG_CreateSchema.sql"
rem sqlcmd -S . -d %DB_NAME% -E -i "%RootPath%\ORNG\NewStuff.sql"
rem sqlcmd -S . -d %DB_NAME% -E -i "%RootPath%\ORNG\RDF_GetStoreNode.sql"
rem sqlcmd -S . -d %DB_NAME% -E -v ProfilesRNSRootPath="%RootPath%" -i "%RootPath%\ORNG\ORNG_DataLoad.sql"
rem sqlcmd -S . -d %DB_NAME% -E -i "%RootPath%\ORNG\ORNG_ExampleGadgets.sql"



