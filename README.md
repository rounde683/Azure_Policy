# Azure Policy Development Workspace

A comprehensive workspace for creating, testing, and deploying Azure policies with automated CI/CD pipelines.

## 🚀 Quick Start

1. **Setup Development Environment**
   ```powershell
   ./scripts/Setup-DevEnvironment.ps1
   ```

2. **Connect to Azure**
   ```powershell
   Connect-AzAccount
   Set-AzContext -SubscriptionId "your-subscription-id"
   ```

3. **Create Your First Policy**
   - Navigate to `policies/definitions/`
   - Copy and modify an existing policy template
   - Run validation: `./scripts/Test-PolicyDefinitions.ps1`

4. **Run Tests**
   ```powershell
   Invoke-Pester -Path "./tests"
   ```

## 📁 Project Structure

```
Azure_Policy_Workspace/
├── .github/
│   ├── workflows/           # CI/CD pipelines
│   └── copilot-instructions.md
├── policies/
│   ├── definitions/         # Policy definition files
│   ├── assignments/         # Policy assignment configurations
│   └── initiatives/         # Policy initiative (policy sets)
├── tests/
│   ├── unit/               # Unit tests for policies
│   └── integration/        # Integration tests
├── scripts/
│   ├── Deploy-PolicyDefinitions.ps1
│   ├── Test-PolicyDefinitions.ps1
│   └── Setup-DevEnvironment.ps1
├── templates/
│   └── policy-definition.bicep
├── docs/
│   ├── development-guide.md
│   └── configuration.md
└── README.md
```

## 🛠️ Development Workflow

### 1. Policy Creation
- Create policy definitions in `policies/definitions/`
- Follow naming convention: `{category}-{description}-policy.json`
- Include comprehensive metadata

### 2. Testing
- Write unit tests in `tests/unit/`
- Validate syntax: `./scripts/Test-PolicyDefinitions.ps1`
- Run tests: `Invoke-Pester`

### 3. Deployment
- **Development**: Push to `develop` branch
- **Production**: Create PR to `main` branch
- Automated deployment via GitHub Actions

## 📋 Prerequisites

### Software Requirements
- **PowerShell 5.1+** or **PowerShell Core 7+**
- **Azure CLI** - [Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Git** - [Download](https://git-scm.com/downloads)
- **VS Code** (recommended) with extensions:
  - Azure Policy
  - PowerShell
  - Bicep
  - YAML

### PowerShell Modules
```powershell
Install-Module -Name Az
Install-Module -Name Pester
Install-Module -Name PSScriptAnalyzer
```

### Azure Permissions
- **Contributor** role on target subscription/management group
- **Resource Policy Contributor** for policy management

## 🔧 Configuration

### Environment Setup
1. Copy environment templates from `docs/configuration.md`
2. Configure GitHub secrets:
   - `AZURE_CREDENTIALS`: Service principal JSON
   - `AZURE_SUBSCRIPTION_ID`: Target subscription

### Service Principal Creation
```bash
az ad sp create-for-rbac --name "azure-policy-sp" \\
  --role "Resource Policy Contributor" \\
  --scopes "/subscriptions/{subscription-id}" \\
  --sdk-auth
```

## 🧪 Testing

### Local Testing
```powershell
# Validate all policies
./scripts/Test-PolicyDefinitions.ps1

# Run unit tests
Invoke-Pester -Path "./tests/unit"

# Run specific test
Invoke-Pester -Path "./tests/unit/storage-encryption-policy.Tests.ps1"
```

### CI/CD Testing
- Automatic validation on push/PR
- Unit tests execution
- Deployment to development environment
- Production deployment on main branch

## 📚 Documentation

- **[Development Guide](docs/development-guide.md)** - Detailed development workflow
- **[Configuration Guide](docs/configuration.md)** - Environment setup and secrets
- **[Policy Examples](policies/definitions/)** - Sample policy definitions
- **[Test Examples](tests/unit/)** - Sample test cases

## 🚀 Deployment

### Manual Deployment
```powershell
# Deploy to specific subscription
./scripts/Deploy-PolicyDefinitions.ps1 -SubscriptionId "subscription-id"

# Deploy to management group
./scripts/Deploy-PolicyDefinitions.ps1 -SubscriptionId "subscription-id" -ManagementGroupId "mg-id"
```

### Automated Deployment
- **Development**: Automatic deployment on `develop` branch
- **Production**: Automatic deployment on `main` branch
- **Rollback**: Supported via GitHub releases

## 📊 Monitoring and Compliance

### Built-in Monitoring
- Azure Policy Compliance dashboard
- Policy evaluation logs
- Compliance state tracking

### Custom Monitoring
- Azure Monitor integration
- Log Analytics queries
- Custom compliance reports

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/new-policy`
3. **Add** your policy and tests
4. **Run** validation: `./scripts/Test-PolicyDefinitions.ps1`
5. **Commit** changes: `git commit -am 'Add new security policy'`
6. **Push** to branch: `git push origin feature/new-policy`
7. **Create** a Pull Request

## 📝 Policy Development Guidelines

### Policy Definition Best Practices
- Use parameterized effects (`Audit`, `Deny`, `Disabled`)
- Include comprehensive metadata
- Follow Azure resource naming conventions
- Implement proper error handling

### Testing Guidelines
- Test all policy conditions
- Include positive and negative test cases
- Validate parameter handling
- Test policy assignments

### Documentation Requirements
- Document policy purpose and scope
- Include compliance requirements
- Provide usage examples
- Maintain change logs

## 🔍 Troubleshooting

### Common Issues
1. **Policy Not Evaluating**
   - Check assignment scope
   - Verify resource type matching
   - Review policy conditions

2. **Deployment Failures**
   - Validate JSON syntax
   - Check permissions
   - Review parameter values

3. **Test Failures**
   - Update test data
   - Check policy logic
   - Validate test assertions

### Debug Commands
```powershell
# Check policy compliance
Get-AzPolicyState -SubscriptionId "subscription-id"

# View policy assignments
Get-AzPolicyAssignment -Scope "/subscriptions/subscription-id"

# Test policy simulation
Test-AzPolicyDefinition -PolicyDefinition "./policies/definitions/policy.json"
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Azure Policy Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
- **Issues**: Create an issue in this repository
- **Community**: [Azure Governance Community](https://techcommunity.microsoft.com/t5/azure-governance/ct-p/AzureGovernance)

---

**Happy Policy Development! 🎉**