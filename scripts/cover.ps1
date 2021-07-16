$ErrorActionPreference = "Stop"

(dotnet sln $solutionFileDir list) | Select-Object -Skip 2 | Where-Object { $_ -match "test" } | ForEach-Object {
  $file = [System.IO.DirectoryInfo]"$_"
  $parent = $($file.parent.fullname)
  $name = $file.name.Substring(0, $file.name.LastIndexOf('.'))
  $testdll = (Get-ChildItem $parent -Recurse -Include "$name.dll")[0].fullname
  coverlet $testdll --target "dotnet" --targetargs 'test --collect:"XPlat Code Coverage" --no-build' -o "${env:OUTPUTDIR}/$($file.parent.name)/" --format opencover
}
