#!/bin/bash

set -e

export OUTPUTDIR="coverage"
mkdir -p "$OUTPUTDIR"

rm -f .config/dotnet-tools.json || true

SONAR_ORGANIZATION="$SONAR_ORG"

err() {
	echo -e "\e[1;31mBuild/Tests failed.\e[0m"
	exit 1
}

trap "err" ERR

wait_flag="false"
if [ "$BRANCH_NAME" == "master" ] || [ "$BRANCH_NAME" == "main" ]; then
	wait_flag="true"
fi

sonar_args="/o:$SONAR_ORGANIZATION \
    /k:$SONAR_PROJECT_KEY \
    /d:sonar.host.url=https://sonarcloud.io \
    /d:sonar.token=$SONAR_TOKEN \
    /d:sonar.cs.opencover.reportsPaths=**/$OUTPUTDIR/**/coverage.opencover.xml \
    /d:sonar.exclusions=**/*Migrations/**/* \
    /d:sonar.scm.disabled=true \
    /d:sonar.scm.revision=$GITHUB_SHA \
    /d:sonar.qualitygate.wait=$wait_flag"

if test -f "$GITHUB_WORKSPACE/coverage/hadolint.sonar"; then
	cat "$GITHUB_WORKSPACE/coverage/hadolint.sonar"
	sonar_args="$sonar_args \
    /d:sonar.docker.hadolint.reportPaths=coverage/hadolint.sonar"
fi

eval "dotnet sonarscanner begin $sonar_args /d:sonar.branch.name=$GITVERSION_BRANCHNAME"
dotnet build
pwsh ./.github/workflows/actions-dotnet/test/cover.ps1

set +ue
dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"
exit_code=$?
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
	exit $exit_code
fi
