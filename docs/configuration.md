# Azure Policy Configuration

This file contains environment-specific configuration for Azure Policy deployment.

## Development Environment
```json
{
  "subscriptionId": "dev-subscription-id",
  "managementGroupId": "dev-mg",
  "resourceGroupName": "rg-policies-dev",
  "location": "East US",
  "policyAssignmentScope": "/subscriptions/dev-subscription-id"
}
```

## Production Environment
```json
{
  "subscriptionId": "prod-subscription-id",
  "managementGroupId": "prod-mg",
  "resourceGroupName": "rg-policies-prod",
  "location": "East US",
  "policyAssignmentScope": "/subscriptions/prod-subscription-id"
}
```

## Required Secrets

Configure these secrets in your GitHub repository:

- `AZURE_CREDENTIALS`: Service principal credentials in JSON format
- `AZURE_SUBSCRIPTION_ID`: Target Azure subscription ID

### Creating Service Principal

```bash
az ad sp create-for-rbac --name "azure-policy-sp" --role contributor --scopes /subscriptions/{subscription-id} --sdk-auth
```