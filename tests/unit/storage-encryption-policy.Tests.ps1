Describe "Storage Encryption Policy Tests" {
    BeforeAll {
        $policyPath = "$PSScriptRoot\..\..\policies\definitions\storage-encryption-policy.json"
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
        }

        It "Should target storage accounts" {
            $policyContent.if.field | Should Be "type"
            $policyContent.if.equals | Should Be "Microsoft.Storage/storageAccounts"
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
        }
    }
}