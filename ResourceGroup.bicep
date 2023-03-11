targetScope = 'subscription'
param location string
param tags object = {}
param resourceGroupName string

resource grupo_recursos 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}
