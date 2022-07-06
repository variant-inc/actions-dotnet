#!/bin/bash

set -e

export OUTPUTDIR="coverage"
mkdir -p "$OUTPUTDIR"

SONAR_ORGANIZATION="$SONAR_ORG"

sonar_logout() {
  set +ue
  exit_code=$?
  dotnet-sonarscanner end /d:sonar.login="$SONAR_TOKEN"
  if [ "$exit_code" -eq 0 ]; then
    echo -e "\e[1;32m ________________________________________________________________\e[0m"
    echo -e "\e[1;32m Quality Gate Passed.\e[0m"
    echo -e "\e[1;32m ________________________________________________________________\e[0m"
  elif [ "$exit_code" -gt 0 ]; then
    set -e
    echo -e "\e[1;31m ________________________________________________________________\e[0m"
    echo -e "\e[1;31m ________________________________________________________________\e[0m"
    echo ""
    echo ""
    echo -e "\e[1;31m Sonar Quality Gate failed in $SONAR_PROJECT_KEY.\e[0m"
    echo ""
    echo ""
    echo -e "\e[1;31m ________________________________________________________________\e[0m"
    echo -e "\e[1;31m ________________________________________________________________\e[0m"
    exit 1 
  fi
}

trap "sonar_logout" EXIT

wait_flag="false"
if [ "$BRANCH_NAME" == "master" ] || [ "$BRANCH_NAME" == "main" ]; then
  wait_flag="true"
fi

sonar_args="/o:$SONAR_ORGANIZATION \
    /k:$SONAR_PROJECT_KEY \
    /d:sonar.host.url=https://sonarcloud.io \
    /d:sonar.login=$SONAR_TOKEN \
    /d:sonar.cs.opencover.reportsPaths=**/$OUTPUTDIR/**/coverage.opencover.xml \
    /d:sonar.exclusions=**/*Migrations/**/* \
    /d:sonar.scm.disabled=true \
    /d:sonar.scm.revision=$GITHUB_SHA \
    /d:sonar.qualitygate.wait=$wait_flag"

if [ "$PULL_REQUEST_KEY" = null ]; then
  echo "Pull request key is null"
  eval "dotnet-sonarscanner $sonar_args /d:sonar.branch.name=$BRANCH_NAME"
else
  eval "dotnet-sonarscanner $sonar_args /d:sonar.pullrequest.key=$PULL_REQUEST_KEY"
fi

dotnet build
pwsh /scripts/cover.ps1

