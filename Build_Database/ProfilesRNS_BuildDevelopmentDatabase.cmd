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


set DB_NAME=ProfilesRNS_HMS
set DATA_FILE_FOLDER=ProfilesRNS_DevelopmentDataset
set ProfilesRNSBasePath=http://localhost:55956
set RootPath=%~dp0\..\..\ProfilesRNS\Database
set SQL_Version=SQL2017
set automated_testing_path=%~dp0
set zip="C:\Program Files\7-Zip\7z.exe"

echo . Deleteing generated files.
del "%RootPath%\Data\InstallData.xml"
del "%RootPath%\ProfilesRNS_CreateSchema.sql"
del "%RootPath%\Data\MeSH.xml"


echo . Creating ProfilesRNS Install Data
cd "%RootPath%\Data\InstallData"
call CreateInstallDataScript.bat > ..\InstallData.xml
cd %automated_testing_path%


echo . Creating ProfilesRNS Schema
cd "%RootPath%\schema"
call CreateSchemaInstallScript.bat > ..\ProfilesRNS_CreateSchema.sql
cd %automated_testing_path%

echo . Extracting MESH.xml
pushd "%RootPath%\Data
call %zip% e MeSH.xml.zip -y
popd

call ProfilesRNS_Test_Database_Install.cmd %DB_NAME% %DATA_FILE_FOLDER% %ProfilesRNSBasePath% %RootPath% %SQL_Version%

:cleanup
del "%RootPath%\Data\InstallData.xml"
del "%RootPath%\ProfilesRNS_CreateSchema.sql"
del "%RootPath%\Data\MeSH.xml"
del "%RootPath%\%DB_NAME%_ExporterDisambiguation_GetFunding.sql
del "%RootPath%\%DB_NAME%_ProfilesRNS_BibliometricsJob.sql
del "%RootPath%\%DB_NAME%_ProfilesRNS_GeocodeJob.sql
del "%RootPath%\%DB_NAME%_PubMedDisambiguation_getPubMedXML.sql
del "%RootPath%\%DB_NAME%_PubMedDisambiguation_getPubs.sql