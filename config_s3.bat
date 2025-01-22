@echo off


set "workspace=%1"
echo Configuring AWS CLI with provided keys...

set aws_cli=path to AWSCLIV2

cd /d "%aws_cli%"

echo %aws_cli%

:: Set AWS Profile Name
rem set AWS_PROFILE=default

:: Hardcoded AWS Access Key ID
set AWS_ACCESS_KEY_ID=abc

:: Hardcoded AWS Secret Access Key
set AWS_SECRET_ACCESS_KEY=def

:: Hardcoded AWS Region
set AWS_DEFAULT_REGION=region

:: Hardcoded AWS Output Format
set AWS_OUTPUT_FORMAT=text

:: Set AWS CLI configuration for the provided profile
aws configure set aws_access_key_id %AWS_ACCESS_KEY_ID%
aws configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY%
aws configure set region %AWS_DEFAULT_REGION%
aws configure set output %AWS_OUTPUT_FORMAT%

echo AWS CLI has been configured with the provided credentials.

