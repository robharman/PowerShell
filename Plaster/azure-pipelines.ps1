<%
@"
trigger:
  branches:
    include:
      - main
      - dev
  paths:
    include:
      - $PLASTER_PARAM_ModuleName

name: 'Private_$PLASTER_PARAM_ModuleName'
variables:
  major: 1
  minor: 0
  patch: 2
  `${{if eq(variables['Build.SourceBranchName'], 'dev')}}:
    ModuleVersion: `$(major).`$(minor).`$(patch).`$(Build.BuildID)
  `${{if eq(variables['Build.Reason'], 'PullRequest')}}:
    ModuleVersion: `$(major).`$(minor).`$(patch).`$(Build.BuildID)
  `${{if eq(variables['Build.SourceBranchName'], 'main')}}:
    ModuleVersion: `$(major).`$(minor).`$(patch).0
    DeployRun: True
  modulename: '$PLASTER_PARAM_ModuleName'
  moduleShortName: '$PLASTER_PARAM_ModuleShortName'
  moduledescription: '$PLASTER_PARAM_ModuleDescription'
  toDo: ''

pool: home

stages:
- stage: Build
  jobs:
  - job: Build
    steps:
    - task: AzureKeyVault@2
      displayName: 'Import KeyVault Secrets'
      inputs:
        azureSubscription: `$(AzureSubscriptionID)
        KeyVaultName: `$(KeyVaultName)
        SecretsFilter: '*'
        RunAsPreJob: true
    - task: PowerShell@2
      condition: eq(variables['DeployRun'], 'True')
      displayName: 'Run signed-build script'
      inputs:
        Arguments: -SignFiles
        filePath: '`$(System.DefaultWorkingDirectory)/`$(ModuleName)/build/build.ps1'
    - task: PowerShell@2
      condition: eq(variables['DeployRun'], 'False')
      displayName: 'Run unsigned-build script'
      inputs:
        filePath: '`$(System.DefaultWorkingDirectory)/`$(ModuleName)/build/build.ps1'
    - task: NuGetCommand@2
      displayName: 'Create NuGet Package'
      inputs:
        command: 'pack'
        packagesToPack: '`$(System.DefaultWorkingDirectory)/`$(ModuleName)/`$(ModuleShortName)/`$(ModuleName).nuspec'
        versioningScheme: byEnvVar
        versionEnvVar: ModuleVersion
        buildProperties: 'VERSIONHERE=`$(ModuleVersion)'
        packDestination: '`$(Build.ArtifactStagingDirectory)'
    - task: PublishBuildArtifacts@1
      displayName: 'Publish NuGet Package'
      inputs:
        PathtoPublish: '`$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'NuGetPackage'
        publishLocation: 'Container'
    - task: CopyFiles@1
      displayName: 'Copy Module build files'
      inputs:
          sourceFolder: `$(System.DefaultWorkingDirectory)/`$(ModuleName)/`$(ModuleShortName)
          contents: '**\*!(*.nuspec)'
          CleanTargetFolder: true
          targetFolder: '`$(Build.ArtifactStagingDirectory)'
    - task: PublishBuildArtifacts@1
      displayName: 'Publish Module PS1 files'
      inputs:
        PathtoPublish: '`$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'PSFiles'
        publishLocation: 'Container'

- stage: Test
  jobs:
  - job: Test
    steps:
    - task: Pester@10
      displayName: 'Run unit tests'
      inputs:
        scriptFolder: "`$(System.DefaultWorkingDirectory)/`$(ModuleName)/Tests/*.Tests.ps1"
        resultsFile: "`$(System.DefaultWorkingDirectory)/`$(ModuleName)/Tests/`$(ModuleName).Tests.XML"
        usePSCore: true
        run32Bit: False
    - task: PublishTestResults@2
      inputs:
        testResultsFormat: "NUnit"
        testResultsFiles: "`$(System.DefaultWorkingDirectory)/`$(ModuleName)/Tests/`$(ModuleName).Tests.XML"
        failTaskOnFailedTests: true

- stage: Deploy
  condition: eq(variables['DeployRun'], 'True')
  jobs:
  - job: Deploy
    steps:
      - task: AzureKeyVault@2
        displayName: 'Import KeyVault Secrets'
        inputs:
          azureSubscription: `$(AzureSubscriptionID)
          KeyVaultName: `$(KeyVaultName)
          SecretsFilter: '*'
          RunAsPreJob: false
      - task: DownloadPipelineArtifact@2
        inputs:
          buildType: 'current'
          artifactName: 'NuGetPackage'
          itemPattern: '**'
          targetPath: '`$(Pipeline.Workspace)/`$(Build.BuildID)/NuGet'
      - task: NuGetCommand@2
        displayName: 'Publish NuPkg to DevOps feed'
        inputs:
          command: 'push'
          packagesToPush: '`$(Pipeline.Workspace)/`$(Build.BuildID)/NuGet/*.nupkg'
          nuGetFeedType: 'internal'
          publishVstsFeed: `$(vstsFeed)
      - task: DownloadPipelineArtifact@2
        inputs:
          buildType: 'current'
          artifactName: 'PSFiles'
          itemPattern: |
            !(*.nupkg|*.nuspec)
            **\**
          targetPath: '`$(Pipeline.Workspace)/`$(Build.BuildID)/Module'
      - task: CopyFiles@2
        displayName: 'Publish Module'
        inputs:
          sourceFolder: '`$(Pipeline.Workspace)/`$(Build.BuildID)/Module'
          contents: '**'
          cleanTargetFolder: true
          targetFolder: '`$(moduleTargetFolder)\'
      - task: GitHubRelease@1
        condition: eq(variables['Build.SourceBranchName'], 'main')
        inputs:
          gitHubConnection: `$(gitHubConnection)
          repositoryName: `$(repositoryName)
          assets: `$(System.DefaultWorkingDirectory)/`$(ModuleName)/`$(ModuleShortName)/**/*.ps*

- stage: Clean
  jobs:
  - job: Clean
    steps:
      - task: AzureKeyVault@2
        displayName: 'Import KeyVault Secrets'
        inputs:
          azureSubscription: `$(AzureSubscriptionID)
          KeyVaultName: `$(KeyVaultName)
          SecretsFilter: '*'
          RunAsPreJob: true
      - task: DeleteFiles@1
        displayName: 'Remove NuSpec file from module directory.'
        inputs:
          contents: |
            '`$(moduleTargetFolder)*.nuspec'
            '`$(moduleTargetFolder)*.npkg'
      - task: DeleteFiles@1
        displayName: 'Delete successful deployment artifacts'
        inputs:
          contents: '`$(Pipeline.Workspace)/`$(Build.BuildID)/**'
"@
%>