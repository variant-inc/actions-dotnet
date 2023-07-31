$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

Trap
{
  Write-Error $_.InvocationInfo.ScriptName -ErrorAction Continue
  $line = "$($_.InvocationInfo.ScriptLineNumber): $($_.InvocationInfo.Line)"
  Write-Error $line -ErrorAction Continue
  Write-Error $_
}

function CommandAliasFunction
{
  Write-Information ""
  Write-Information "$args"
  $cmd, $args = $args
  & "$cmd" $args
  if ($LASTEXITCODE)
  {
    throw "Exception Occured"
  }
  Write-Information ""
}

Set-Alias -Name ce -Value CommandAliasFunction -Scope script

$tests = $(dotnet sln $solutionFileDir list) | Select-Object -Skip 2 | Where-Object { $_ -match "^test" }
$tests | ForEach-Object {
  $file = [System.IO.DirectoryInfo]"$_"
  $parent = $($file.parent.fullname)
  ce dotnet add $parent package coverlet.msbuild
  ce dotnet add $parent package coverlet.collector
}

$OUTPUTDIR = "coverage"

ce dotnet test `
  /p:CollectCoverage=true `
  /p:CoverletOutput=${env:OUTPUTDIR}/coverage.opencover.xml `
  /p:CoverletOutputFormat=opencover `
  /p:CoverletSkipAutoProps=true `
  /p:Exclude=[*]*Migrations.* `
  --filter "FullyQualifiedName!~ntegration"
