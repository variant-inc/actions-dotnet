# Actions - Dotnet

Setting up continuous integration

- [Actions - Dotnet](#actions---dotnet)
  - [Prerequisites](#prerequisites)
    - [1. Setup github action workflow](#1-setup-github-action-workflow)
    - [2. Add actions setup](#2-add-actions-setup)
    - [3. Add the dotnet action](#3-add-the-dotnet-action)
    - [4. Add octopus action](#4-add-octopus-action)
  - [Using Dotnet Action](#using-dotnet-action)
    - [Adding dotnet action to workflow](#adding-dotnet-action-to-workflow)
    - [Input Parameters](#input-parameters)
  - [What it does](#what-it-does)
  
## Prerequisites

### 1. Setup github action workflow

1. On GitHub, navigate to the main page of the repository.
2. Under your repository name, click Actions.
3. Find the template that matches the language and tooling you want to use, then click Set up this workflow. Either start with blank workflow or choose any integration workflows.

### 2. Add actions setup

1. Add a code checkout step this will be needed to add code to the github workspace.

```yaml
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0
```

1. This is to add some global environment variables that are used as part of the dotnet action. It will output `image_version`.

```yaml
    - name: Setup
      uses: variant-inc/actions-setup@v1
```

Refer [actions setup](https://github.com/variant-inc/actions-setup/blob/master/README.md) for documentation.

### 3. Add the dotnet action

1. This step is to invoke dotnet action with release version by passing environment variables and input parameters. Input parameters section provides more insight of optional and required parameters.

```yaml

    - name: Lazy action steps
      id: lazy-action
      uses: variant-inc/actions-dotnet@v1
      env:
        NUGET_TOKEN: ${{ secrets.PKG_READ }}
        AWS_DEFAULT_REGION: us-east-2
        AWS_REGION: us-east-2
        GITHUB_USER: variant-inc
      with:
        src_file_dir_path: '.'
        dockerfile_dir_path: '.'
        ecr_repository: naveen-demo-app/demo-repo
        nuget_push_enabled: 'true'
        sonar_scan_in_docker: 'false'
        nuget_push_token: ${{ secrets.GITHUB_TOKEN }}
        nuget_pull_token: ${{ secrets.PKG_READ }}

```

### 4. Add octopus action

1. Adding octopus action will add ability to setup continuos delivery to octopus. This action can be invoked by action name and release version.

```yaml

    - name: Lazy Action Octopus
      uses: variant-inc/actions-octopus@v1
      with:
        default_branch: ${{ env.MASTER_BRANCH }}
        deploy_scripts_path: deploy
        project_name: ${{ env.PROJECT_NAME }}
        version: ${{ steps.lazy-setup.outputs.image-version }}
        space_name: ${{ env.OCTOPUS_SPACE_NAME }}

```

Refer [octopus action](https://github.com/variant-inc/actions-octopus/blob/master/README.md) for documentation.

## Using Dotnet Action

You can set up continuous integration for your project using an actions workflow action.
After you set up CI, you can customize the workflow to meet your needs. By passing the right input parameters with the dotnet action.

### Adding dotnet action to workflow

Sample snippet to add actions to your workflow code.
See [action.yml](action.yml) for the full documentation for this action's inputs and outputs.

```yaml
jobs:
  build_test_scan:
    runs-on: eks
    name: CI Pipeline
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 0

    - name: Setup
      uses: variant-inc/actions-setup@v1

    - name: Lazy action steps
      id: lazy-action
      uses: variant-inc/actions-dotnet@v1
      env:
        NUGET_TOKEN: ${{ secrets.PKG_READ }}
        AWS_DEFAULT_REGION: us-east-2
        GITHUB_USER: variant-inc
      with:
        src_file_dir_path: '.'
        dockerfile_dir_path: '.'
        ecr_repository: naveen-demo-app/demo-repo
        nuget_push_enabled: 'true'
        sonar_scan_in_docker: 'false'
        nuget_push_token: ${{ secrets.GITHUB_TOKEN }}
        nuget_pull_token: ${{ secrets.PKG_READ }}

    - name: Lazy Action Octopus
      uses: variant-inc/actions-octopus@v1
      with:
        default_branch: ${{ env.MASTER_BRANCH }}
        deploy_scripts_path: deploy
        project_name: ${{ env.PROJECT_NAME }}
        version: ${{ steps.lazy-setup.outputs.image-version }}
        space_name: ${{ env.OCTOPUS_SPACE_NAME }}

```

### Input Parameters

| Parameter                     | Default         | Description                                                                  | Required |
| ----------------------------- | --------------- | ---------------------------------------------------------------------------- | -------- |
| `src_file_dir_path`           | `.`             | Directory path to the solution file                                          | true     |
| `dockerfile_dir_path`         | `.`             | Directory path to the dockerfile                                             | true     |
| `ecr_repository`              |                 | ECR Repository name                                                          | true     |
| `sonar_scan_in_docker`        | "false"         | Is sonar scan running as part of Dockerfile                                  | false    |
| `sonar_scan_in_docker_target` | "sonarscan-env" | sonar scan in docker target.                                                 | false    |
| `nuget_push_enabled`          | "false"         | Enabled Nuget Push to Package Registry.                                      | false    |
| `nuget_pull_token`            |                 | GitHub token with repo read permissions for pulling NuGet packages Token     | true     |
| `nuget_push_token`            |                 | GitHub token with package write permissions for pushing NuGet packages Token | false    |

## What it does

Github action dotnet is a CI utility which does build , test , sonar scan , build and push image to ECR , does the trivy vulnerabilities scan and publish package to github registry .This action runs some of the mandatory CI steps and also has ability to skip some of the steps that are not required.

In detail Information

Refer [Confluence link](https://usxtech.atlassian.net/wiki/spaces/CLOUD/pages/1346404365/Lazy+Github+Action+Dotnet)
