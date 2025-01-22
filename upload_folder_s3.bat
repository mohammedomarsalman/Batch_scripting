echo uploading to S3 Bucket

call config_s3.bat
echo aws s3 cp %NewFolder% s3://path-to-bucket/%FolderName% --recursive

aws s3 cp %NewFolder% s3://path-to-bucket/%FolderName% --recursive
echo Files successfully uploaded to S3 Bucket
