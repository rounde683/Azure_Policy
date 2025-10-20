targetScope = 'subscription'

@description('The name of the policy definition')
param policyName string

@description('The display name of the policy')
param policyDisplayName string

@description('The description of the policy')
param policyDescription string

@description('The policy rule as an object')
param policyRule object

@description('The policy parameters as an object')
param policyParameters object = {}

@description('The policy metadata as an object')
param policyMetadata object = {}

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    parameters: policyParameters
    policyRule: policyRule
    metadata: policyMetadata
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
