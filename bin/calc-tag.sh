#!/bin/bash
# This script is to be included and will calculate the following vars
# CALC_TAG     the tag to be used in docker, based on (Jenkins) TAG_NAME or BRANCH_NAME
# if BRANCH_NAME is not provided by Jenkins it will be queried from git

: ${TAG_START:=release-}

# determine the docker image tag, based on TAG_NAME or BRANCH_NAME
if [[ ${TAG_NAME:-} == ${TAG_START}* ]]; then
  echo ${TAG_NAME##${TAG_START}}
elif [[ ! -z ${TAG_NAME:-}  ]]; then
    echo images for this target should only be built for tags starting with ${TAG_START}
    exit 1
else
  if [[ -z ${BRANCH_NAME:-} ]]; then
    # get the name of the current branch if it is not set by Jenkins
    BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
  fi
  echo latest-${BRANCH_NAME##*/}  # cleanup branchname removing anything before last slash
fi
