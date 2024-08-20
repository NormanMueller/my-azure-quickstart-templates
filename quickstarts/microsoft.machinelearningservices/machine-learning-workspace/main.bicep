@description('Specifies the name of the deployment.')
param name string = 'aipd_218'

@description('Specifies the name of the environment.')
param environment string = ''

@description('Specifies the location of the Azure Machine Learning workspace and dependent resources.')
param location string = 'germanywestcentral'

var tenantId = subscription().tenantId
var storageAccountName = 'st${name}${environment}'
var keyVaultName = 'kv-${name}-${environment}'
var applicationInsightsName = 'appi-${name}-${environment}'
// var containerRegistryName = 'cr${name}${environment}'
var workspaceName = 'ws-${name}${environment}'
var storageAccountId = storageAccount.id
var keyVaultId = vault.id
var applicationInsightId = applicationInsight.id
// var containerRegistryId = registry.id

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: true
  }
}

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

/*
resource registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  sku: {
    name: 'Standard'
  }
  name: containerRegistryName
  location: location
  properties: {
    adminUserEnabled: false
  }
}
*/

resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-10-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  name: workspaceName
  location: location
  properties: {
    friendlyName: workspaceName
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightId
    // containerRegistry: containerRegistryId
  }
}
