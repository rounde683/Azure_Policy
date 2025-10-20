Describe "DNS Resolver Query Logging Policy Tests" {
    BeforeAll {
        $policyPath = "$PSScriptRoot\..\..\policies\definitions\dns-resolver-query-logging-policy.json"
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

        It "Should target DNS Resolvers" {
            $policyContent.if.allOf[0].field | Should Be "type"
            $policyContent.if.allOf[0].equals | Should Be "Microsoft.Network/dnsResolvers"
        }

        It "Should check for VNet links or inbound endpoints" {
            $vnetCondition = $policyContent.if.allOf[1].anyOf
            $vnetCondition[0].field | Should Match "virtualNetworkLinks.*virtualNetwork.id"
            $vnetCondition[1].field | Should Match "inboundEndpoints"
        }

        It "Should validate query logging configuration" {
            $loggingCondition = $policyContent.if.allOf[2].not.allOf
            $loggingCondition[0].field | Should Match "queryLoggingConfig.enabled"
            $loggingCondition[0].equals | Should Be "true"
            $loggingCondition[1].field | Should Match "queryLoggingConfig.destinations.*storageAccount.resourceId"
        }
    }

    Context "Policy Parameters Validation" {
        It "Should have storage account resource group parameter" {
            $rgParam = $policyContent.parameters.requiredStorageAccountResourceGroup
            $rgParam.type | Should Be "String"
            $rgParam.defaultValue | Should Be ""
        }

        It "Should have storage account prefix parameter" {
            $prefixParam = $policyContent.parameters.allowedStorageAccountPrefix
            $prefixParam.type | Should Be "String"
            $prefixParam.defaultValue | Should Be "dnsquerylog"
        }

        It "Should have descriptive parameter metadata" {
            $rgParam = $policyContent.parameters.requiredStorageAccountResourceGroup
            $rgParam.metadata.displayName | Should Not Be $null
            $rgParam.metadata.description | Should Not Be $null
            
            $prefixParam = $policyContent.parameters.allowedStorageAccountPrefix
            $prefixParam.metadata.displayName | Should Not Be $null
            $prefixParam.metadata.description | Should Not Be $null
        }
    }

    Context "Policy Logic Validation" {
        It "Should use parameterized effect" {
            $policyContent.then.effect | Should Be "[parameters('effect')]"
        }

        It "Should have proper metadata" {
            $policyContent.metadata.displayName | Should Not Be $null
            $policyContent.metadata.description | Should Not Be $null
            $policyContent.metadata.category | Should Be "Network"
            $policyContent.metadata.version | Should Be "1.0.0"
        }

        It "Should use allOf and anyOf logic correctly" {
            $policyContent.if.allOf | Should Not Be $null
            $policyContent.if.allOf.Count | Should Be 3
            $policyContent.if.allOf[1].anyOf | Should Not Be $null
            $policyContent.if.allOf[1].anyOf.Count | Should Be 2
        }

        It "Should use NOT logic for query logging validation" {
            $policyContent.if.allOf[2].not | Should Not Be $null
            $policyContent.if.allOf[2].not.allOf | Should Not Be $null
        }
    }

    Context "Policy Compliance Scenarios" {
        It "Should deny DNS resolver without query logging enabled" {
            # This validates the condition where queryLoggingConfig.enabled is not true
            $loggingCondition = $policyContent.if.allOf[2].not.allOf[0]
            $loggingCondition.field | Should Match "queryLoggingConfig.enabled"
            $loggingCondition.equals | Should Be "true"
        }

        It "Should deny DNS resolver without storage account destination" {
            # This validates the condition where storage account resource ID doesn't exist
            $storageCondition = $policyContent.if.allOf[2].not.allOf[1]
            $storageCondition.field | Should Match "storageAccount.resourceId"
            $storageCondition.exists | Should Be "true"
        }

        It "Should have deny as default effect for security" {
            $policyContent.parameters.effect.defaultValue | Should Be "Deny"
        }

        It "Should target DNS resolvers with VNet associations" {
            # Ensures policy only applies to DNS resolvers that are actually being used
            $vnetCondition = $policyContent.if.allOf[1].anyOf[0]
            $vnetCondition.field | Should Match "virtualNetworkLinks"
            $vnetCondition.exists | Should Be "true"
        }
    }
}