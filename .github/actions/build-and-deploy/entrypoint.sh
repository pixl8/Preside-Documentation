#!/bin/sh

cd ${GITHUB_WORKSPACE}

chmod +x *.sh

box install save=false force=true || exit 1
box start serverConfigFile=server.json || exit 1
./generateDocs.sh || exit 1
./build.sh || exit 1
box stop serverConfigFile=server.json || exit 1
./deploy.sh || exit 1