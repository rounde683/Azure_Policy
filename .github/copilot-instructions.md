# Azure Policy Development Workspace

This workspace is designed for creating, testing, and deploying Azure policies. It includes:

## Project Structure
- `/policies/` - Azure policy definitions and assignments
- `/tests/` - Policy testing frameworks and test cases  
- `/scripts/` - Deployment and management scripts
- `/templates/` - Bicep/ARM templates for policy deployment
- `/docs/` - Documentation and governance guidelines
- `.github/workflows/` - CI/CD pipelines for automated testing and deployment

## Development Guidelines
- Use Azure CLI and PowerShell for policy management
- Follow Azure Policy best practices and naming conventions
- Test policies in development subscriptions before production deployment
- Use parameter files for environment-specific configurations
- Document policy purpose, scope, and compliance requirements

## Required Tools
- Azure CLI
- PowerShell Az modules
- Azure Policy extension for VS Code
- Bicep extension for infrastructure templates

## Workflow
1. Create policy definitions in `/policies/`
2. Write tests in `/tests/`
3. Use scripts in `/scripts/` for deployment
4. Deploy via CI/CD pipelines in `.github/workflows/`