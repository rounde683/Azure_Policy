Describe "DNS Port Restriction Policy Tests" {
    BeforeAll {
        $policyPath = "$PSScriptRoot\..\..\policies\definitions\dns-port-restriction-policy.json"
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

        It "Should target Network Security Groups and Private DNS Zones" {
            $conditions = $policyContent.if.anyOf
            $conditions[0].allOf[0].field | Should Be "type"
            $conditions[0].allOf[0].equals | Should Be "Microsoft.Network/networkSecurityGroups"
            $conditions[1].allOf[0].field | Should Be "type"
            $conditions[1].allOf[0].equals | Should Be "Microsoft.Network/privateDnsZones"
        }

        It "Should validate NSG security rules for port restrictions" {
            $nsgCondition = $policyContent.if.anyOf[0].allOf[1].count
            $nsgCondition.field | Should Match "securityRules"
            $whereClause = $nsgCondition.where.allOf
            $whereClause[0].field | Should Match "access"
            $whereClause[0].equals | Should Be "Allow"
            $whereClause[1].field | Should Match "direction"
            $whereClause[1].equals | Should Be "Inbound"
        }

        It "Should check for unauthorized port access" {
            $nsgCondition = $policyContent.if.anyOf[0].allOf[1].count.where.allOf[2].anyOf
            $nsgCondition[0].field | Should Match "destinationPortRange"
            $nsgCondition[0].notIn -contains "53" | Should Be $true
            $nsgCondition[1].field | Should Match "destinationPortRanges"
        }
    }

    Context "Policy Parameters Validation" {
        It "Should have allowed source IP ranges parameter" {
            $ipRangesParam = $policyContent.parameters.allowedSourceIpRanges
            $ipRangesParam.type | Should Be "Array"
            $ipRangesParam.defaultValue.Count | Should Be 0
        }

        It "Should have authorized zone transfer IPs parameter" {
            $zoneTransferParam = $policyContent.parameters.authorizedZoneTransferIps
            $zoneTransferParam.type | Should Be "Array"
            $zoneTransferParam.defaultValue.Count | Should Be 0
        }

        It "Should have NSG requirement parameter" {
            $nsgParam = $policyContent.parameters.requireNetworkSecurityGroups
            $nsgParam.type | Should Be "Boolean"
            $nsgParam.defaultValue | Should Be $true
        }

        It "Should have descriptive parameter metadata" {
            $ipRangesParam = $policyContent.parameters.allowedSourceIpRanges
            $ipRangesParam.metadata.displayName | Should Not Be $null
            $ipRangesParam.metadata.description | Should Not Be $null
            
            $zoneTransferParam = $policyContent.parameters.authorizedZoneTransferIps
            $zoneTransferParam.metadata.displayName | Should Not Be $null
            $zoneTransferParam.metadata.description | Should Not Be $null
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

        It "Should use anyOf logic for multiple resource types" {
            $policyContent.if.anyOf | Should Not Be $null
            $policyContent.if.anyOf.Count | Should Be 2
        }

        It "Should use count operations for rule validation" {
            $nsgCondition = $policyContent.if.anyOf[0].allOf[1]
            $nsgCondition.count | Should Not Be $null
            $nsgCondition.count.field | Should Match "securityRules"
            $nsgCondition.greater | Should Be 0
        }
    }

    Context "Network Security Group Rules Validation" {
        It "Should check for Allow access rules" {
            $nsgRules = $policyContent.if.anyOf[0].allOf[1].count.where.allOf
            $accessRule = $nsgRules[0]
            $accessRule.field | Should Match "access"
            $accessRule.equals | Should Be "Allow"
        }

        It "Should check for Inbound direction rules" {
            $nsgRules = $policyContent.if.anyOf[0].allOf[1].count.where.allOf
            $directionRule = $nsgRules[1]
            $directionRule.field | Should Match "direction"
            $directionRule.equals | Should Be "Inbound"
        }

        It "Should validate port restrictions" {
            $nsgRules = $policyContent.if.anyOf[0].allOf[1].count.where.allOf
            $portRule = $nsgRules[2].anyOf
            $portRule[0].notIn -contains "53" | Should Be $true
            $portRule[0].notIn -contains "443" | Should Be $true
            $portRule[0].notIn -contains "80" | Should Be $true
        }

        It "Should check for wildcard source addresses" {
            $nsgRules = $policyContent.if.anyOf[0].allOf[1].count.where.allOf
            $sourceRule = $nsgRules[3].anyOf
            $sourceRule[0].field | Should Match "sourceAddressPrefix"
            $sourceRule[0].equals | Should Be "*"
            $sourceRule[1].equals | Should Be "Internet"
        }
    }

    Context "Private DNS Zones Validation" {
        It "Should target private DNS zones" {
            $privateDnsCondition = $policyContent.if.anyOf[1].allOf[0]
            $privateDnsCondition.field | Should Be "type"
            $privateDnsCondition.equals | Should Be "Microsoft.Network/privateDnsZones"
        }

        It "Should check for VNet links and registration" {
            $vnetLinksCondition = $policyContent.if.anyOf[1].allOf[1].anyOf
            $vnetLinksCondition[0].field | Should Match "registrationEnabled"
            $vnetLinksCondition[0].equals | Should Be "true"
        }

        It "Should validate network access restrictions" {
            $accessCondition = $policyContent.if.anyOf[1].allOf[2].not
            $accessCondition.field | Should Match "restrictedAccess"
            $accessCondition.equals | Should Be "true"
        }
    }

    Context "Policy Compliance Scenarios" {
        It "Should deny NSGs allowing unauthorized ports from Internet" {
            $portRule = $policyContent.if.anyOf[0].allOf[1].count.where.allOf[2].anyOf[0]
            $portRule.notIn -contains "53" | Should Be $true
        }

        It "Should deny private DNS zones without access restrictions" {
            $accessRestriction = $policyContent.if.anyOf[1].allOf[2].not
            $accessRestriction.field | Should Match "restrictedAccess"
            $accessRestriction.equals | Should Be "true"
        }

        It "Should have deny as default effect for security" {
            $policyContent.parameters.effect.defaultValue | Should Be "Deny"
        }

        It "Should require NSGs by default" {
            $policyContent.parameters.requireNetworkSecurityGroups.defaultValue | Should Be $true
        }
    }
}