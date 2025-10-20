targetScope = 'subscription'

@description('The effect for the DNS resolver query logging policy')
@allowed(['Audit', 'Deny', 'Disabled'])
param policyEffect string = 'Deny'

@description('Resource group where DNS query logging storage accounts should be located')
param requiredStorageAccountResourceGroup string = 'rg-dns-logging'

@description('Required prefix for DNS query logging storage account names')
param allowedStorageAccountPrefix string = 'dnsquerylog'

// Policy Definition
resource dnsResolverQueryLoggingPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'dns-resolver-query-logging-policy'
  properties: {
    displayName: 'DNS Resolver Query logging must be enabled and stored in Azure Storage'
    description: 'This policy ensures that Azure DNS Resolvers have query logging enabled and configured to store logs in Azure Storage accounts. DNS query logging provides visibility into DNS resolution activities and helps with security monitoring, troubleshooting, and compliance requirements.'
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
      requiredStorageAccountResourceGroup: {
        type: 'String'
        metadata: {
          displayName: 'Required Storage Account Resource Group'
          description: 'The resource group where the storage account for DNS query logging should be located'
        }
        defaultValue: ''
      }
      allowedStorageAccountPrefix: {
        type: 'String'
        metadata: {
          displayName: 'Allowed Storage Account Name Prefix'
          description: 'Prefix that storage accounts must have for DNS query logging'
        }
        defaultValue: 'dnsquerylog'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/dnsResolvers'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Network/dnsResolvers/virtualNetworkLinks[*].virtualNetwork.id'
                exists: true
              }
              {
                field: 'Microsoft.Network/dnsResolvers/inboundEndpoints[*]'
                exists: true
              }
            ]
          }
          {
            not: {
              allOf: [
                {
                  field: 'Microsoft.Network/dnsResolvers/queryLoggingConfig.enabled'
                  equals: true
                }
                {
                  field: 'Microsoft.Network/dnsResolvers/queryLoggingConfig.destinations[*].storageAccount.resourceId'
                  exists: true
                }
              ]
            }
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
resource dnsResolverQueryLoggingAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'dns-resolver-query-logging-assignment'
  properties: {
    displayName: 'Enforce DNS Resolver Query Logging to Storage'
    description: 'Assignment for DNS Resolver query logging policy to ensure all DNS resolvers have query logging enabled and stored in Azure Storage'
    policyDefinitionId: dnsResolverQueryLoggingPolicy.id
    parameters: {
      effect: {
        value: policyEffect
      }
      requiredStorageAccountResourceGroup: {
        value: requiredStorageAccountResourceGroup
      }
      allowedStorageAccountPrefix: {
        value: allowedStorageAccountPrefix
      }
    }
    enforcementMode: 'Default'
  }
}

output policyDefinitionId string = dnsResolverQueryLoggingPolicy.id
output policyAssignmentId string = dnsResolverQueryLoggingAssignment.id
output policyDefinitionName string = dnsResolverQueryLoggingPolicy.name
