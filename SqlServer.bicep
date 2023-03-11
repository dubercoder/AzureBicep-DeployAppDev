// Parametros Transversales y RG
param location string
param dbSubnet string
param tags object = {}
param vnetppal string
param sqlserverName string
param sqlserverTier string
param sqlserverSKU string
param PEsqlserverName string

param Catalogcollation string
param dbcollation string
@secure()
param adminuserloginsql string
@secure()
param password string
param sqldatabaseName string



resource sqlserverdata 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name:sqlserverName
  location:location
  tags:tags
  properties: {
    administratorLogin:adminuserloginsql
    administratorLoginPassword:password
    version: '12.0'
    minimalTlsVersion:'1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}


resource sqldatabase 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  parent:sqlserverdata
  name:sqldatabaseName
  location:location
  tags:tags
  sku: {
    name: sqlserverSKU
    tier: sqlserverTier
    capacity: 10
  }
  properties: {
    collation:dbcollation
    maxSizeBytes:10737418240
    catalogCollation:Catalogcollation
    zoneRedundant:false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    isLedgerOn: false
  }
}

//Private endPoint
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: PEsqlserverName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: PEsqlserverName
        properties: {
          privateLinkServiceId: sqlserverdata.id
          groupIds: [
            'SqlServer'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: '${vnetppal}/subnets/${dbSubnet}'
    }
  }
}

