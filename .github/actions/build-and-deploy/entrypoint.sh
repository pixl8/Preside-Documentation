#!/bin/sh

cd ${GITHUB_WORKSPACE}

chmod +x *.sh

export S3_BUCKET=$INPUT_S3_BUCKET
export S3_ACCESS_KEY_ID=$INPUT_S3_ACCESS_KEY_ID
export S3_SECRET_KEY=$INPUT_S3_SECRET_KEY

box install save=false force=true || exit 1
box start serverConfigFile=server.json || exit 1
./generateDocs.sh || exit 1
./build.sh || exit 1
box stop serverConfigFile=server.json || exit 1
./deploy.sh || exit 1