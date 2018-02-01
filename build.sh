#!/bin/bash

cd `dirname $0`
CWD="`pwd`"

echo "Installing dependencies (e.g. Preside)..."
box install force=true save=false

echo "Building documentation with Lucee :)"

box $CWD/build.cfm
if [ -f .exitcode ]; then
  exitcode=$(<.exitcode)
  rm -f .exitcode
  echo "Exiting build, documentation build failed."
  exit $exitcode
fi

echo "Building complete."
