targetScope = 'subscription'

@description('The effect for the storage soft delete policy')
@allowed(['Audit', 'Deny', 'Disabled'])
param policyEffect string = 'Deny'

@description('The minimum number of days to retain soft deleted blobs and containers')
@minValue(1)
@maxValue(365)
param minimumRetentionDays int = 30

@description('Whether soft delete should be required for containers in addition to blobs')
param requiredForContainers bool = true

// Policy Definition
resource storageSoftDeletePolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'storage-soft-delete-policy'
  properties: {
    displayName: 'Storage accounts should have soft delete enabled for blobs and containers'
    description: 'This policy ensures that Azure Storage accounts have soft delete enabled for both blobs and containers to protect against accidental or malicious deletion. Soft delete allows recovery of deleted data within a specified retention period, providing an additional layer of data protection.'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Storage'
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
      minimumRetentionDays: {
        type: 'Integer'
        metadata: {
          displayName: 'Minimum Retention Days'
          description: 'The minimum number of days to retain soft deleted blobs and containers'
        }
        defaultValue: 7
      }
      requiredForContainers: {
        type: 'Boolean'
        metadata: {
          displayName: 'Require Soft Delete for Containers'
          description: 'Whether soft delete should be required for containers in addition to blobs'
        }
        defaultValue: true
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.enabled'
                notEquals: 'true'
              }
              {
                field: 'Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.enabled'
                exists: false
              }
              {
                field: 'Microsoft.Storage/storageAccounts/blobServices/containerDeleteRetentionPolicy.enabled'
                notEquals: 'true'
              }
              {
                field: 'Microsoft.Storage/storageAccounts/blobServices/containerDeleteRetentionPolicy.enabled'
                exists: false
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.days'
                    exists: true
                  }
                  {
                    field: 'Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.days'
                    less: '[parameters(\'minimumRetentionDays\')]'
                  }
                ]
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
resource storageSoftDeleteAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'storage-soft-delete-assignment'
  properties: {
    displayName: 'Enforce Storage Account Soft Delete'
    description: 'Assignment for storage account soft delete policy to ensure all storage accounts have soft delete enabled for blobs and containers'
    policyDefinitionId: storageSoftDeletePolicy.id
    parameters: {
      effect: {
        value: policyEffect
      }
      minimumRetentionDays: {
        value: minimumRetentionDays
      }
      requiredForContainers: {
        value: requiredForContainers
      }
    }
    enforcementMode: 'Default'
  }
}

output policyDefinitionId string = storageSoftDeletePolicy.id
output policyAssignmentId string = storageSoftDeleteAssignment.id
output policyDefinitionName string = storageSoftDeletePolicy.name
