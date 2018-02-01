#!/bin/bash

cd `dirname $0`
CWD="`pwd`"

EDIT_SOURCE_LINK=https://github.com/pixl8/Preside-Documentation/blob/master{path}
DASH_BUILD_NUMBER=1.0.0
DASH_DOWNLOAD_URL=http://docs.preside.org/dash/presidecms.tgz

if [[ $TRAVIS_BRANCH == "develop" ]] ; then
	EDIT_SOURCE_LINK=https://github.com/pixl8/Preside-Documentation/blob/develop{path}
	DASH_DOWNLOAD_URL=http://beta-docs.preside.org/dash/presidecms.tgz
fi

export EDIT_SOURCE_LINK
export DASH_BUILD_NUMBER
export DASH_DOWNLOAD_URL

echo "Building documentation with Lucee :)"

box $CWD/build.cfm
if [ -f .exitcode ]; then
  exitcode=$(<.exitcode)
  rm -f .exitcode
  echo "Exiting build, documentation build failed."
  exit $exitcode
fi

echo "Building complete."
