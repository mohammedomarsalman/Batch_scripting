@echo off
setlocal enabledelayedexpansion

set workspace=%1

rem set "linux_server=%1"
rem set "linux_user=%2"
rem set "password=%3"
rem set "remote_file=%4"


SET "connector_name="

REM Loop through each part of the path, delimited by backslashes
FOR %%A IN ("%workspace:/=" "%") DO SET "connector_name=%%A"

:: Remove leading and trailing quotes if present
set "connector_name=%connector_name:"=%"

REM Output the last folder name
echo Connector name is: %connector_name%

set conn_adp_src=%workspace%/source/usr/connection.adapter/src
set meta_adp_src=%workspace%/source/usr/metadata.adapter/src
set runtime_adp_src=%workspace%/source/usr/runtime.adapter/src
set runtime_pdo_src=%workspace%/source/sdk/runtime.pdo/src


set "local_destination=E:\SonarQube_Report_Generator\UTF\coverage_data"
echo %local_destination%

set conn_adp=%workspace%\source\usr\connection.adapter\target\classes
set meta_adp=%workspace%\source\usr\metadata.adapter\target\classes
set run_adp=%workspace%\source\usr\runtime.adapter\target\classes
set run_pdo=%workspace%\source\sdk\runtime.pdo\target\classes


rem search inside cats and copy jacoco.exec and mergedjacoco.exec
set search_exec=%workspace%\cats

rem Set the file name to search for
set "cctf_filename=jacoco.exec"
set cctf_dest=E:\SonarQube_Report_Generator\CCTF\


rem Initialize variable to store the result
set "cctf_filepath="
set "file_found=false"

rem Searching for jacoco.exec
for /r "%search_exec%" %%f in (*%cctf_filename%) do (
    set "cctf_filepath=%%f"
    echo File found: !cctf_filepath!
	xcopy "!cctf_filepath!" "%cctf_dest%" /y
if %errorlevel% equ 0 (

    	echo File copied successfully from !cctf_filepath! to %cctf_dest%

) else (
    echo Error occurred while copying the file
)
    set "file_found=true"
    rem Break the loop after finding the first occurrence
    goto :found
)

:found
rem Continue with other commands here
if "%file_found%"=="false" (
    echo File %cctf_filename% not found in %search_exec%.
) else (
    echo Moving Forward
)


set "Junit_filename=mergedJacoco.exec"
set junit_dest=E:\SonarQube_Report_Generator\Junit\

rem Initialize variable to store the result
set "Junit_filepath="
set "Junit_file_found=false"

rem Searching for mergedJacoco.exec
for /r "%search_exec%" %%f in (*%Junit_filename%) do (
    set "Junit_filepath=%%f"
    echo File found: !Junit_filepath!
	xcopy "!Junit_filepath!" "%junit_dest%" /y
if %errorlevel% equ 0 (

    	echo File copied successfully from !Junit_filepath! to %junit_dest%

) else (
    echo Error occurred while copying the file
)
    set "Junit_file_found=true"
    rem Break the loop after finding the first occurrence
    goto :Junit_found
)

:Junit_found
rem Continue with other commands here
if "%Junit_file_found%"=="false" (
    echo File %Junit_filename% not found in %search_exec%.
) else (
    echo Moving Forward
)


set utf_rp=%local_destination%\coverage_data
set cctf_rp=%cctf_dest%\jacoco.exec
set junit_rp=%junit_dest%\mergedJacoco.exec


rem Initialize an empty variable to hold file names
set "filelist="

rem Loop through all files in the directory UTF\coverage_data directory
for %%f in ("%utf_rp%\*") do (
    set "file=!file! %%~xf" rem Get the file name with extension
    set "filelist=!filelist! %%f" rem Append the full file path to the variable
)
echo Collected file names:
echo %filelist%
echo.

echo merging all UTF exec files
echo java -jar jacococli.jar merge %filelist% --destfile jacoco_dis_dtm_merged.exec
java -jar jacococli.jar merge %filelist% --destfile E:\SonarQube_Report_Generator\jacoco_dis_dtm_merged.exec

echo Generating UTF report
echo java -jar org.jacoco.cli-0.8.8_INFA-nodeps.jar report E:\SonarQube_Report_Generator\jacoco_dis_dtm_merged.exec --classfiles  %conn_adp% --classfiles %meta_adp% --classfiles %run_adp% --classfiles %run_pdo% --html E:\SonarQube_Report_Generator\UTF\UTF_coverage

java -jar org.jacoco.cli-0.8.8_INFA-nodeps.jar report E:\SonarQube_Report_Generator\jacoco_dis_dtm_merged.exec --classfiles  %conn_adp% --classfiles %meta_adp% --classfiles %run_adp% --classfiles %run_pdo% --html E:\SonarQube_Report_Generator\UTF\UTF_coverage

REM CCTF+Junit+UTF 
echo Generating CCTF+Junit+UTF report
echo java -jar org.jacoco.cli-0.8.8_INFA-nodeps.jar report %cctf_rp% %junit_rp% E:\SonarQube_Report_Generator\jacoco_dis_dtm_merged.exec --classfiles %conn_adp% --classfiles %meta_adp% --classfiles %run_adp% --classfiles %run_pdo% --html mergedCoverage --xml %workspace%\xmlReport.xml --sourcefiles=%conn_adp_src%  --sourcefiles=%meta_adp_src%  --sourcefiles=%runtime_adp_src% --sourcefiles=runtime_pdo_src

java -jar org.jacoco.cli-0.8.8_INFA-nodeps.jar report %cctf_rp% %junit_rp% E:\SonarQube_Report_Generator\jacoco_dis_dtm_merged.exec --classfiles %conn_adp% --classfiles %meta_adp% --classfiles %run_adp% --classfiles %run_pdo% --html mergedCoverage --xml %workspace%\xmlReport.xml --sourcefiles=%conn_adp_src%  --sourcefiles=%meta_adp_src%  --sourcefiles=%runtime_adp_src% --sourcefiles=%runtime_pdo_src%

rem copy reports as a back up to any folder

REM Get the current date and time
REM Format the date as YYYY-MM-DD and time as HH-MM
FOR /F "tokens=2 delims==" %%a IN ('"wmic os get localdatetime /value"') DO SET datetime=%%a

SET "Year=%datetime:~0,4%"
SET "Month=%datetime:~4,2%"
SET "Day=%datetime:~6,2%"
SET "Hour=%datetime:~8,2%"
SET "Minute=%datetime:~10,2%"

REM Initialize a variable to store the last folder name
SET "Connectorname="

REM Loop through each part of the path, delimited by backslashes
FOR %%A IN ("%workspace:/=" "%") DO SET "Connectorname=%%A"
set "Connectorname=%Connectorname:"=%"

REM Output the last folder name
echo Connector name is: %Connectorname%

REM Format the date and time for the folder name
SET "FolderName=%Connectorname%-%Year%-%Month%-%Day%_%Hour%-%Minute%"

REM Set the shared location path (modify as needed)
SET "SharedLocation=\\SharedLocation\CCTF_Junit_UTF_Reports"

REM Create the new folder with date and time
SET "NewFolder=%SharedLocation%\%FolderName%"
mkdir "%NewFolder%"

REM Copy only subfolders from the current directory to the new folder
FOR /D %%d IN ("UTF") DO (
    REM Check if it is a directory
    IF EXIST "%%d\" (
        REM Copy the subfolder and its contents to the new folder
        xcopy "%%d" "%NewFolder%\%%d\" /E /I /H /Y > nul 2>&1
    )
)

xcopy "%workspace%/xmlReport.xml" "%NewFolder%\" /Y > nul 2>&1

echo %workspace%\xmlReport.xml copied successfully

set "cctf_coverage=CCTFcoverage"
for /r "%workspace%" %%i in (.) do (
    if /i "%%~nxi"=="%cctf_coverage%" (
        echo CCTFcoverage found: %%i
        echo Copying folder to %NewFolder%
        xcopy "%%i" "%NewFolder%\%cctf_coverage%" /e /i /h /y > nul 2>&1
        echo CCTFcoverage Folder copied successfully!
    )
)

set "junit_coverage=JUNITcoverage"
for /r "%workspace%" %%i in (.) do (
    if /i "%%~nxi"=="%junit_coverage%" (
        echo JUNITcoverage found: %%i
        echo Copying folder to %NewFolder%
        xcopy "%%i" "%NewFolder%\%junit_coverage%" /e /i /h /y > nul 2>&1
        echo JUNITcoverage Folder copied successfully!

    )
)

echo Folders and their contents have been copied to %NewFolder%.


echo uploading to S3 Bucket

call E:/SonarQube_Report_Generator/aws_config.bat
echo aws s3 cp %NewFolder% s3:/path-to-s3/sonarcube_report%FolderName% --recursive

aws s3 cp %NewFolder% s3:/path-to-s3/sonarcube_report%FolderName% --recursive
echo Files successfully uploaded to S3 Bucket


rem Define a list of folders to clear (add more folders as needed)
set FOLDER_LIST="E:\SonarQube_Report_Generator\CCTF" "E:\SonarQube_Report_Generator\UTF" "E:\SonarQube_Report_Generator\Junit" "E:\SonarQube_Report_Generator\mergedCoverage"

rem Loop through each folder in the folder list
for %%F in (%FOLDER_LIST%) do (
    rem Check if the folder exists
    if exist "%%F" (
        echo Deleting all files and subfolders in %%F...
        
        rem Delete all files in the folder and subfolders
        del /q /f /s "%%F\*.*"

        rem Delete all subdirectories in the folder
        for /d %%i in ("%%F\*") do rd /s /q "%%i"
        
        echo All files and subfolders in %%F have been deleted.
    ) else (
        echo The folder does not exist: %%F
    )
)

del /f E:\SonarQube_Report_Generator\jacoco_dis_dtm_merged.exec

endlocal
pause
