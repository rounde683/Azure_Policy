targetScope = 'subscription'

@description('The effect for the backup soft delete policy')
@allowed(['Audit', 'Deny', 'Disabled'])
param policyEffect string = 'Deny'

// Policy Definition
resource backupSoftDeletePolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'backup-soft-delete-policy'
  properties: {
    displayName: 'Recovery Services vaults should have soft delete enabled'
    description: 'This policy ensures that Azure Recovery Services vaults have soft delete enabled to protect backup data from accidental or malicious deletion. Soft delete provides additional protection by retaining deleted backup data for a specified period.'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Backup'
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
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.RecoveryServices/vaults'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.RecoveryServices/vaults/securitySettings.softDeleteSettings.softDeleteState'
                notEquals: 'Enabled'
              }
              {
                field: 'Microsoft.RecoveryServices/vaults/securitySettings.softDeleteSettings.softDeleteState'
                exists: false
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
resource backupSoftDeleteAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'backup-soft-delete-assignment'
  properties: {
    displayName: 'Enforce Recovery Services vault soft delete'
    description: 'Assignment for Recovery Services vault soft delete policy'
    policyDefinitionId: backupSoftDeletePolicy.id
    parameters: {
      effect: {
        value: policyEffect
      }
    }
    enforcementMode: 'Default'
  }
}

output policyDefinitionId string = backupSoftDeletePolicy.id
output policyAssignmentId string = backupSoftDeleteAssignment.id
output policyDefinitionName string = backupSoftDeletePolicy.name
