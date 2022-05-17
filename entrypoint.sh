#!/bin/bash

function finish {
  set -x
  chown -R 1000:1000 "$GITHUB_WORKSPACE"/*
  git clean -fdx
  set +x
}
trap finish EXIT
set -eo


echo "Start: Setting Prerequisites"
cd "$GITHUB_WORKSPACE"
cd "$INPUT_SRC_FILE_DIR_PATH"
echo "Current directory: $(pwd)"

git config --global --add safe.directory /github/workspace

echo "Cloning into actions-collection..."
git clone -b feature/CLOUD-1738-skip-sonar-analysis https://github.com/variant-inc/actions-collection.git ./actions-collection

echo "---Start: Pretest script"
chmod +x ./actions-collection/scripts/pre_test.sh
./actions-collection/scripts/pre_test.sh

export AWS_WEB_IDENTITY_TOKEN_FILE="/token"
echo "$AWS_WEB_IDENTITY_TOKEN" >>"$AWS_WEB_IDENTITY_TOKEN_FILE"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:=us-east-1}"

export BRANCH_NAME="$GITVERSION_BRANCHNAME"
echo "Print Branch name: $BRANCH_NAME"

export GITHUB_USER="$GITHUB_REPOSITORY_OWNER"
export GITHUB_TOKEN="$GITHUB_PACKAGES_TOKEN"

echo "End: Setting Prerequisites"

echo "Start: Enable sonar"
pwsh ./actions-collection/scripts/enable_sonar.ps1
echo "End: Enable sonar"

echo "Start: Check sonar run"
skip_sonar_run=$(pwsh ./actions-collection/scripts/skip_sonar_run.ps1)
echo "Skip sonar run: $skip_sonar_run"
echo "End: Check sonar run"


if [ "$skip_sonar_run" != 'True' ]; then
  echo "Start: Sonar Scan"
  sh -c "/scripts/coverage_scan.sh"
  echo "End: Sonar Scan"
else
  echo "End: Skipping sonar run"
fi

# echo "Container Push: $INPUT_CONTAINER_PUSH_ENABLED"
# if [ "$INPUT_CONTAINER_PUSH_ENABLED" = 'true' ]; then
#   echo "Start: Checking ECR Repo"
#   ./actions-collection/scripts/ecr_create.sh "$INPUT_ECR_REPOSITORY"
#   echo "End: Checking ECR Repo"
#   echo "Start: Publish Image to ECR"
#   ./actions-collection/scripts/publish.sh
#   echo "End: Publish Image to ECR"
# fi


# echo "Nuget Publish: $INPUT_NUGET_PUSH_ENABLED"
# if [ "$INPUT_NUGET_PUSH_ENABLED" = 'true' ]; then
#   echo "Start: Publish Nuget Package"
#   /scripts/nuget_push.sh
#   echo "End: Publish Nuget Package"
# fi

echo "Start: Clean up"
git clean -fdx
echo "End: Clean up"