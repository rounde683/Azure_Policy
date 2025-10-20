# Azure Policy Development Guide

## Overview

This guide covers the development workflow for creating, testing, and deploying Azure policies in this workspace.

## Policy Development Workflow

### 1. Create Policy Definition

1. Navigate to `policies/definitions/`
2. Create a new JSON file with your policy definition
3. Follow the naming convention: `{category}-{description}-policy.json`

Example structure:
```json
{
  "if": {
    "field": "type",
    "equals": "Microsoft.Resource/resourceType"
  },
  "then": {
    "effect": "[parameters('effect')]"
  },
  "parameters": {
    "effect": {
      "type": "String",
      "allowedValues": ["Audit", "Deny", "Disabled"],
      "defaultValue": "Audit"
    }
  },
  "metadata": {
    "displayName": "Policy Display Name",
    "description": "Policy description",
    "category": "Category"
  }
}
```

### 2. Write Tests

1. Create unit tests in `tests/unit/`
2. Follow the naming convention: `{policy-name}.Tests.ps1`
3. Test policy structure, logic, and compliance scenarios

### 3. Local Testing

```powershell
# Validate policy syntax
./scripts/Test-PolicyDefinitions.ps1

# Run unit tests
Invoke-Pester -Path "./tests/unit"
```

### 4. Create Policy Assignment

1. Create assignment files in `policies/assignments/`
2. Define scope, parameters, and compliance settings
3. Use environment-specific parameter files

### 5. Deploy via CI/CD

- Push to `develop` branch for development deployment
- Create PR to `main` for production deployment
- Monitor deployment status in GitHub Actions

## Best Practices

### Policy Definition

- Use parameterized effects for flexibility
- Include comprehensive metadata
- Follow Azure Policy naming conventions
- Implement proper error handling

### Testing

- Test all policy conditions
- Validate parameter handling
- Include negative test cases
- Test assignment configurations

### Documentation

- Document policy purpose and scope
- Include compliance requirements
- Provide examples and use cases
- Maintain change logs

## Tools and Extensions

### Required VS Code Extensions

- Azure Policy
- PowerShell
- JSON
- YAML

### PowerShell Modules

```powershell
Install-Module -Name Az
Install-Module -Name Pester
```

## Compliance Monitoring

### Built-in Monitoring

- Use Azure Policy Compliance dashboard
- Configure alerts for non-compliance
- Regular compliance reporting

### Custom Monitoring

- Create Log Analytics queries
- Set up Azure Monitor alerts
- Implement custom dashboards

## Troubleshooting

### Common Issues

1. **Policy Not Evaluating**
   - Check policy assignment scope
   - Verify resource type matching
   - Review policy conditions

2. **Assignment Failures**
   - Validate parameter values
   - Check permissions
   - Review policy definition ID

3. **Compliance Issues**
   - Review policy evaluation logs
   - Check resource compliance state
   - Verify remediation tasks

### Debugging Tips

- Use Azure Activity Log
- Enable policy evaluation logs
- Test with resource simulation
- Review compliance details