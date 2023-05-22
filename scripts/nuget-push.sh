#!/bin/sh -l

set -eu

mkdir -p out
dotnet pack -c Release -o /out  --version-suffix "$IMAGE_VERSION"
dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$GITHUB_TOKEN"

rm -rf out
