Describe "Recovery Services Vault Soft Delete Policy Tests" {
    BeforeAll {
        $policyPath = "$PSScriptRoot\..\..\policies\definitions\backup-soft-delete-policy.json"
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

        It "Should target Recovery Services vaults" {
            $policyContent.if.allOf[0].field | Should Be "type"
            $policyContent.if.allOf[0].equals | Should Be "Microsoft.RecoveryServices/vaults"
        }

        It "Should check soft delete settings" {
            $softDeleteCondition = $policyContent.if.allOf[1].anyOf
            $softDeleteCondition[0].field | Should Be "Microsoft.RecoveryServices/vaults/securitySettings.softDeleteSettings.softDeleteState"
            $softDeleteCondition[0].notEquals | Should Be "Enabled"
            $softDeleteCondition[1].field | Should Be "Microsoft.RecoveryServices/vaults/securitySettings.softDeleteSettings.softDeleteState"
            $softDeleteCondition[1].exists | Should Be "false"
        }
    }

    Context "Policy Logic Validation" {
        It "Should use parameterized effect" {
            $policyContent.then.effect | Should Be "[parameters('effect')]"
        }

        It "Should have proper metadata" {
            $policyContent.metadata.displayName | Should Not Be $null
            $policyContent.metadata.description | Should Not Be $null
            $policyContent.metadata.category | Should Be "Backup"
            $policyContent.metadata.version | Should Be "1.0.0"
        }

        It "Should use allOf and anyOf logic correctly" {
            $policyContent.if.allOf | Should Not Be $null
            $policyContent.if.allOf.Count | Should Be 2
            $policyContent.if.allOf[1].anyOf | Should Not Be $null
            $policyContent.if.allOf[1].anyOf.Count | Should Be 2
        }
    }

    Context "Policy Compliance Scenarios" {
        It "Should deny vault without soft delete enabled" {
            # This would be triggered when softDeleteState is not "Enabled"
            $policyContent.if.allOf[1].anyOf[0].notEquals | Should Be "Enabled"
        }

        It "Should deny vault without soft delete settings" {
            # This would be triggered when softDeleteState field doesn't exist
            $policyContent.if.allOf[1].anyOf[1].exists | Should Be "false"
        }

        It "Should have deny as default effect" {
            $policyContent.parameters.effect.defaultValue | Should Be "Deny"
        }
    }
}