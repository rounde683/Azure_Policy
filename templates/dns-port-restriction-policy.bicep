targetScope = 'subscription'

@description('The effect for the DNS port restriction policy')
@allowed(['Audit', 'Deny', 'Disabled'])
param policyEffect string = 'Deny'

@description('List of IP ranges allowed to access DNS on port 53')
param allowedSourceIpRanges array = [
  '10.0.0.0/8'
  '172.16.0.0/12'
  '192.168.0.0/16'
]

@description('List of IP addresses authorized for DNS zone transfers')
param authorizedZoneTransferIps array = []

@description('Whether NSGs are required to enforce port 53 restrictions')
param requireNetworkSecurityGroups bool = true

// Policy Definition
resource dnsPortRestrictionPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'dns-port-restriction-policy'
  properties: {
    displayName: 'DNS servers must only allow traffic on port 53 UDP and TCP'
    description: 'This policy ensures that Azure DNS servers only allow traffic on port 53 UDP and TCP for DNS resolution and authorized zone transfers. All other traffic is denied by default. The policy validates network access policies, security group rules, and ensures proper traffic restrictions are in place.'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Network'
      version: '1.0.0'
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Deny'
      }
      allowedSourceIpRanges: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Source IP Ranges'
          description: 'List of IP ranges allowed to access DNS on port 53'
        }
        defaultValue: []
      }
      authorizedZoneTransferIps: {
        type: 'Array'
        metadata: {
          displayName: 'Authorized Zone Transfer IPs'
          description: 'List of IP addresses authorized for DNS zone transfers'
        }
        defaultValue: []
      }
      requireNetworkSecurityGroups: {
        type: 'Boolean'
        metadata: {
          displayName: 'Require Network Security Groups'
          description: 'Whether NSGs are required to enforce port 53 restrictions'
        }
        defaultValue: true
      }
    }
    policyRule: {
      if: {
        anyOf: [
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/networkSecurityGroups'
              }
              {
                count: {
                  field: 'Microsoft.Network/networkSecurityGroups/securityRules[*]'
                  where: {
                    allOf: [
                      {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules[*].access'
                        equals: 'Allow'
                      }
                      {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules[*].direction'
                        equals: 'Inbound'
                      }
                      {
                        anyOf: [
                          {
                            field: 'Microsoft.Network/networkSecurityGroups/securityRules[*].destinationPortRange'
                            notIn: ['53', '53/tcp', '53/udp', '443', '80']
                          }
                          {
                            field: 'Microsoft.Network/networkSecurityGroups/securityRules[*].destinationPortRanges[*]'
                            notIn: ['53', '53/tcp', '53/udp', '443', '80']
                          }
                        ]
                      }
                      {
                        anyOf: [
                          {
                            field: 'Microsoft.Network/networkSecurityGroups/securityRules[*].sourceAddressPrefix'
                            equals: '*'
                          }
                          {
                            field: 'Microsoft.Network/networkSecurityGroups/securityRules[*].sourceAddressPrefix'
                            equals: 'Internet'
                          }
                        ]
                      }
                    ]
                  }
                }
                greater: 0
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.Network/privateDnsZones'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks[*].registrationEnabled'
                    equals: true
                  }
                  {
                    count: {
                      field: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks[*]'
                      where: {
                        field: 'Microsoft.Network/privateDnsZones/virtualNetworkLinks[*].virtualNetwork.id'
                        exists: true
                      }
                    }
                    greater: 0
                  }
                ]
              }
              {
                not: {
                  field: 'Microsoft.Network/privateDnsZones/networkAccessPolicy.restrictedAccess'
                  equals: true
                }
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

// Policy Assignment
resource dnsPortRestrictionAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'dns-port-restriction-assignment'
  properties: {
    displayName: 'Enforce DNS Port 53 Traffic Restrictions'
    description: 'Assignment for DNS port restriction policy to ensure DNS servers only allow traffic on port 53 UDP and TCP for DNS resolution and authorized zone transfers'
    policyDefinitionId: dnsPortRestrictionPolicy.id
    parameters: {
      effect: {
        value: policyEffect
      }
      allowedSourceIpRanges: {
        value: allowedSourceIpRanges
      }
      authorizedZoneTransferIps: {
        value: authorizedZoneTransferIps
      }
      requireNetworkSecurityGroups: {
        value: requireNetworkSecurityGroups
      }
    }
    enforcementMode: 'Default'
  }
}

output policyDefinitionId string = dnsPortRestrictionPolicy.id
output policyAssignmentId string = dnsPortRestrictionAssignment.id
output policyDefinitionName string = dnsPortRestrictionPolicy.name
