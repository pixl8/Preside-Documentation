if [[ $TRAVIS_PULL_REQUEST == "false" ]] ; then
  if [[ $TRAVIS_BRANCH == "master" || $TRAVIS_BRANCH == "develop" ]] ; then

    if [[ $TRAVIS_BRANCH == "master" ]] ; then
      S3_BUCKET="docs.preside.org"
    else
      S3_BUCKET="preside-beta-docs"
    fi
    export S3_BUCKET

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
    s3_website push
    echo "All done :)"
  fi
fi
