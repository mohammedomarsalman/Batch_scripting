@echo off
setlocal enabledelayedexpansion

set workspace=%1
REM Loop through each part of the path, delimited by backslashes
FOR %%A IN ("%workspace:/=" "%") DO SET "connector_name=%%A"

:: Remove leading and trailing quotes if present
set "connector_name=%connector_name:"=%"

echo Connector name is: %connector_name%

call E:/SonarQube_Report_Generator/aws_config.bat %workspace%
echo aws s3 cp s3://path_to_s3/sonarcube_reports/%connector_name%/UTF E:/SonarQube_Report_Generator/UTF --recursive

aws s3 cp s3://path_to_s3/sonarcube_reports/%connector_name%/UTF E:/SonarQube_Report_Generator/UTF --recursive

cd /d E:/SonarQube_Report_Generator


set "connector_package_version=E:\SonarQube_Report_Generator\connector_package_version.txt"
set "P4_path="

:: Set the file path
set "file=E:\SonarQube_Report_Generator\UTF\PackageVersion.txt"

echo %file%

:: Check if the file exists
if not exist "%file%" (
    echo File not found!
    exit /b
)

:: Read the first line from the file
for /f "usebackq delims=" %%A in ("%file%") do (
    set "line=%%A"
    goto process_line
)

:process_line
:: Check if the first line is empty
if "%line%"=="" (
    :: Read the second line
    for /f "usebackq skip=1 delims=" %%B in ("%file%") do (
        set "line=%%B"
        goto extract_digits
    )
)

:extract_digits
:: Extract last 3 digits
for /f "tokens=2 delims=." %%C in ("!line!") do (
    set "last_digits=%%C"
)

:: Get the last 3 digits
set "last3=!last_digits:~-3!"

echo Last 3 digits: !last3!

set "before_path="
set "after_path="
set "updated_path="

for /f "usebackq delims=" %%a in ("%connector_package_version%") do (
	echo %%a | findstr /i "%connector_name%-" >nul
if not errorlevel 1 (
echo P4 path for %connector_name% found %%a
set P4_path=%%a

)
 
rem set "before_path=!P4_path:~0,-3!"

:: Rebuild the string with the new digits
rem set "updated_path=!before_path!!last3!"

)

:: Find the position of the last dot and extract everything before it
:: Loop backwards from the end of the string

for /l %%i in (0,1,255) do (
    set "char=!P4_path:~-%%i,1!"
    if "!char!"=="." (
        set "before_path=!P4_path:~0,-%%i!"
        goto done
    )
)

:done
:: Output the result
echo Before last dot: !before_path!
set "updated_path=!before_path!.!last3!"


set "remove_sync=p4 sync "
set "final_path=!updated_path:%remove_sync%=!"

:: Output the updated string
echo Final P4 Path : !final_path!
p4 -u username -p password -c workspace_name sync -f !final_path!



