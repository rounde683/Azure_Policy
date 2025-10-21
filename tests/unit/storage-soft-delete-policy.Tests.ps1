Describe "Storage Soft Delete Policy Tests" {
    BeforeAll {
        $policyPath = "$PSScriptRoot\..\..\policies\definitions\storage-soft-delete-policy.json"
        $policyContent = Get-Content $policyPath | ConvertFrom-Json
    }

    Context "Policy Structure Validation" {
        It "Should have required fields" {
            $policyContent | Should Not Be $null
            $policyContent.if | Should Not Be $null
            $policyContent.then | Should Not Be $null
            $policyContent.parameters | Should Not Be $null
            $policyContent.metadata | Should Not Be $null
        }

        It "Should have valid effect parameter" {
            $effectParam = $policyContent.parameters.effect
            $effectParam.type | Should Be "String"
            $effectParam.allowedValues -contains "Audit" | Should Be $true
            $effectParam.allowedValues -contains "Deny" | Should Be $true
            $effectParam.allowedValues -contains "Disabled" | Should Be $true
            $effectParam.defaultValue | Should Be "Deny"
        }

        It "Should target storage accounts" {
            $policyContent.if.allOf[0].field | Should Be "type"
            $policyContent.if.allOf[0].equals | Should Be "Microsoft.Storage/storageAccounts"
        }

        It "Should check blob soft delete settings" {
            $blobConditions = $policyContent.if.allOf[1].anyOf
            $blobConditions[0].field | Should Be "Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.enabled"
            $blobConditions[0].notEquals | Should Be "true"
        }

        It "Should check container soft delete settings" {
            $containerConditions = $policyContent.if.allOf[1].anyOf
            $containerConditions[2].field | Should Be "Microsoft.Storage/storageAccounts/blobServices/containerDeleteRetentionPolicy.enabled"
            $containerConditions[2].notEquals | Should Be "true"
        }
    }

    Context "Policy Parameters Validation" {
        It "Should have minimum retention days parameter" {
            $retentionParam = $policyContent.parameters.minimumRetentionDays
            $retentionParam.type | Should Be "Integer"
            $retentionParam.defaultValue | Should Be 7
            $retentionParam.minValue | Should Be 1
            $retentionParam.maxValue | Should Be 365
        }

        It "Should have container requirement parameter" {
            $containerParam = $policyContent.parameters.requiredForContainers
            $containerParam.type | Should Be "Boolean"
            $containerParam.defaultValue | Should Be $true
        }

        It "Should have descriptive parameter metadata" {
            $effectParam = $policyContent.parameters.effect
            $effectParam.metadata.displayName | Should Not Be $null
            $effectParam.metadata.description | Should Not Be $null
            
            $retentionParam = $policyContent.parameters.minimumRetentionDays
            $retentionParam.metadata.displayName | Should Not Be $null
            $retentionParam.metadata.description | Should Not Be $null
        }
    }

    Context "Policy Logic Validation" {
        It "Should use parameterized effect" {
            $policyContent.then.effect | Should Be "[parameters('effect')]"
        }

        It "Should have proper metadata" {
            $policyContent.metadata.displayName | Should Not Be $null
            $policyContent.metadata.description | Should Not Be $null
            $policyContent.metadata.category | Should Be "Storage"
            $policyContent.metadata.version | Should Be "1.0.0"
        }

        It "Should use allOf and anyOf logic correctly" {
            $policyContent.if.allOf | Should Not Be $null
            $policyContent.if.allOf.Count | Should Be 2
            $policyContent.if.allOf[1].anyOf | Should Not Be $null
            $policyContent.if.allOf[1].anyOf.Count | Should Be 5
        }

        It "Should validate retention period" {
            $retentionCondition = $policyContent.if.allOf[1].anyOf[4]
            $retentionCondition.allOf[1].field | Should Be "Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.days"
            $retentionCondition.allOf[1].less | Should Be "[parameters('minimumRetentionDays')]"
        }
    }

    Context "Policy Compliance Scenarios" {
        It "Should deny storage account without blob soft delete enabled" {
            $blobCondition = $policyContent.if.allOf[1].anyOf[0]
            $blobCondition.field | Should Be "Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.enabled"
            $blobCondition.notEquals | Should Be "true"
        }

        It "Should deny storage account without blob soft delete configured" {
            $blobExistsCondition = $policyContent.if.allOf[1].anyOf[1]
            $blobExistsCondition.field | Should Be "Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.enabled"
            $blobExistsCondition.exists | Should Be "false"
        }

        It "Should deny storage account without container soft delete enabled" {
            $containerCondition = $policyContent.if.allOf[1].anyOf[2]
            $containerCondition.field | Should Be "Microsoft.Storage/storageAccounts/blobServices/containerDeleteRetentionPolicy.enabled"
            $containerCondition.notEquals | Should Be "true"
        }

        It "Should deny storage account with insufficient retention period" {
            $retentionCondition = $policyContent.if.allOf[1].anyOf[4].allOf[1]
            $retentionCondition.field | Should Be "Microsoft.Storage/storageAccounts/blobServices/deleteRetentionPolicy.days"
            $retentionCondition.less | Should Be "[parameters('minimumRetentionDays')]"
        }

        It "Should have deny as default effect for data protection" {
            $policyContent.parameters.effect.defaultValue | Should Be "Deny"
        }

        It "Should enforce minimum 7 day retention by default" {
            $policyContent.parameters.minimumRetentionDays.defaultValue | Should Be 7
        }
    }
}