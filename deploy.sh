#!/bin/sh

echo "Zipping up docs for offline download..."
cd builds/html
zip -q -r presidecms-docs.zip *
cd ../../
echo "Zipped."
echo "Preparing dash artifacts..."
cp -r builds/html builds/artifacts
mkdir builds/artifacts/dash
cp builds/dash/presidecms.xml builds/artifacts/dash/
cd builds/dash
tar -czf ../../builds/artifacts/dash/presidecms.tgz presidecms.docset
cd ../../
echo "Prepared."
echo "Syncing with S3..."
echo "${S3_ACCESS_KEY_ID}"
s3_website push
echo "All done :)"