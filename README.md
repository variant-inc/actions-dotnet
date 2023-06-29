# Actions Dotnet

Action for CI workflow for dotnet applications

<!-- action-docs-description -->
## Description

Github Action to perform build, test , scan and generate Image for Dotnet

## Permissions

Add the following permissions to the job

```yaml
permissions:
  id-token: write
  contents: read
```

## Usage

```yaml
    - name: Actions Dotnet
      uses: variant-inc/actions-dotnet@v2
      with:
        ecr_repository: 'demo/example'
        dotnet-version: '6.0.x'
```
<!-- action-docs-description -->

<!-- action-docs-inputs -->
## Inputs

| parameter | description | required | default |
| --- | --- | --- | --- |
| cloud_region | Region where the image will be created. | `false` | us-east-2 |
| dockerfile_dir_path | Directory path to the dockerfile | `false` | . |
| dotnet-version | The dotnet-version input is optional. The default version of Dotnet in PATH varies between runners and can be changed unexpectedly so we recommend always setting Dotnet version explicitly using the dotnet-version input.  | `false` |  |
| ecr_repository | Ecr repository name | `true` |  |
| nuget-version | Nuget version | `false` | latest |
| nuget_push_enabled | Enabled Nuget Push to Package Registry. | `false` | false |
<!-- action-docs-inputs -->

<!-- action-docs-outputs -->

<!-- action-docs-outputs -->

<!-- action-docs-runs -->
## Runs

This action is a `composite` action.
<!-- action-docs-runs -->
