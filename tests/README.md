# Azure Policy Testing Framework

This directory contains test files for validating Azure policies before deployment.

## Test Structure

- `unit/` - Unit tests for individual policy definitions
- `integration/` - Integration tests for policy assignments and initiatives
- `compliance/` - Compliance validation tests

## Tools Used

- PowerShell Pester for unit testing
- Azure Policy Simulator for validation
- JSON schema validation

## Running Tests

```powershell
# Run all tests
Invoke-Pester

# Run specific test suite
Invoke-Pester -Path ".\unit\storage-tests.ps1"
```