// Parametros Transversales y RG
targetScope = 'subscription'
param location string
param resourceGroupName string
param tags object = {}
param vnetppal string
param ambiente string


// Parametros Virtual Machine
param virtualmachineName string
param vmSize string
param vmSubnet string
param sngName string
param nicName string
param vmIP string
@secure()
param adminuserloginvm string
@secure()

//Parametros SQL Server

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
param dbSubnet string



// Modulo de Grupo de recursos
module GrupoRecursosDeploy 'ResourceGroup.bicep' = {
  name: 'DeployGrupoRecursos'
  params: {
    location: location
    tags: tags
    resourceGroupName: resourceGroupName
  }
}

// Modulo de Virtual Machine

module VirtualMachineDeploy 'VirtualMachine.bicep' = {
  name: 'DeployVirtualMachine'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags:tags
    location:location
    virtualmachineName:virtualmachineName
    vmSize:vmSize
    vmSubnet:vmSubnet
    sngName:sngName
    nicName:nicName
    vnetppal:vnetppal
    ambiente:ambiente
    vmIP:vmIP
    adminuserloginvm:adminuserloginvm
    password:password
  }
  dependsOn: [
    GrupoRecursosDeploy
  ]
}

//Modulo Sql Server

module SqlServerDeploy 'SqlServer.bicep' = {
  name: 'DeploySqlServer'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags:tags
    location:location
    sqlserverName:sqlserverName
    sqlserverTier:sqlserverTier
    sqlserverSKU:sqlserverSKU
    PEsqlserverName:PEsqlserverName
    Catalogcollation:Catalogcollation
    dbcollation:dbcollation
    adminuserloginsql:adminuserloginsql
    sqldatabaseName:sqldatabaseName
    vnetppal:vnetppal
    dbSubnet:dbSubnet
    password:password
  }
  dependsOn: [
    GrupoRecursosDeploy
  ]
}
