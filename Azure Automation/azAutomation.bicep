param name string = 'aa-shared-prod'
param moduleName string = 'dbatools'
param location string = 'westeurope'

var fullName = '${name}/${moduleName}'

resource installModule 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = {
  name: fullName
  location: location
  tags: {
    env: 'TEST'
  }
  properties: {
    contentLink: {
      // contentHash: {
      //   algorithm: 'string'
      //   value: 'string'
      // }
      uri: 'https://www.powershellgallery.com/api/v2/package/${moduleName}'
      version: '2.5.2'
    }
  }
}

output provisioningState string = installModule.properties.provisioningState
output moduleName string = installModule.name
