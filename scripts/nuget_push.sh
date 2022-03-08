#!/bin/sh -l

set -eu

cd "$GITHUB_WORKSPACE"

mkdir -p out

if [ "$GITVERSION_NUGETPRERELEASETAG" ]; then
  BRANCH_BUILD_SUFFIX=${GITVERSION_NUGETPRERELEASETAG}-${GITHUB_RUN_NUMBER}
  echo "NuGet Push: Pushing branch version $BRANCH_BUILD_SUFFIX"
  dotnet pack --no-restore -c Release --version-suffix "${BRANCH_BUILD_SUFFIX}" -o /out
else
  echo "NuGet Push: Pushing release version from CSPROJ" 
  dotnet pack --no-restore -c Release -o /out
fi

dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$INPUT_NUGET_PUSH_TOKEN"

rm -rf out
