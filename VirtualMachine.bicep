// Parametros Transversales y RG
param location string
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
param password string


var VMname = 'data-${virtualmachineName}-${ambiente}-code'
var networkInterfaceName = 'data-${nicName}-${ambiente}-code'
var networksecuritygroupName = 'data-${sngName}-${ambiente}-code'

//Definición VM 


resource vmDeployVirtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: VMname
  location:location
  tags:tags
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary:true
          }
          id: nicDeploy.id
        }
      ]
    }
    osProfile: {
      computerName: VMname
      adminUsername:adminuserloginvm
      adminPassword:password
    }
  }
}

//Definición NIC Network Interface


resource nicDeploy 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: networkInterfaceName
  location:location
  tags:tags
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipConfigVirtualMachine'
        properties: {
          privateIPAddress: vmIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${vnetppal}/subnets/${vmSubnet}'
          }
          primary:true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgDeploy.id
    }
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
  }
}


//Definición NSG Network Security Group

resource nsgDeploy 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: networksecuritygroupName
  location:location
  tags:tags
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
      {
        name: 'HTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }
      }
      {
        name: 'HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 500
          direction: 'Inbound'
        }
      }
    ]
  }
}
