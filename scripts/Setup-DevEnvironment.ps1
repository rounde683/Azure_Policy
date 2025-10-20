# Azure Policy Development Environment Setup
param(
    [switch]$SkipModuleInstall
)

Write-Host "Setting up Azure Policy Development Environment..." -ForegroundColor Green

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Warning "Some installations may require Administrator privileges. Consider running as Administrator."
}

# Install required PowerShell modules
if (-not $SkipModuleInstall) {
    Write-Host "Installing PowerShell modules..." -ForegroundColor Yellow

    $modules = @('Az', 'Pester', 'PSScriptAnalyzer', 'PowerShellGet')

    foreach ($module in $modules) {
        try {
            Write-Host "Installing $module..." -ForegroundColor Cyan
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -Repository PSGallery
            Write-Host "Successfully installed $module" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to install $module`: $($_.Exception.Message)"
        }
    }
}

# Check Azure CLI installation
Write-Host "`nChecking Azure CLI..." -ForegroundColor Yellow
try {
    $azCliInfo = az version --output json | ConvertFrom-Json
    Write-Host "Azure CLI version $($azCliInfo.'azure-cli') is installed" -ForegroundColor Green
}
catch {
    Write-Warning "Azure CLI not found. Install with: winget install -e --id Microsoft.AzureCLI"
}

# Check Git installation
Write-Host "`nChecking Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "$gitVersion is installed" -ForegroundColor Green
}
catch {
    Write-Warning "Git not found. Download from: https://git-scm.com/download/win"
}

# Setup local configuration
Write-Host "`nSetting up local configuration..." -ForegroundColor Yellow

# Create local config directory
$configDir = "$env:USERPROFILE\.azure-policy-dev"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "Created configuration directory: $configDir" -ForegroundColor Green
}

# Create VS Code settings
$vscodeSettingsDir = ".\.vscode"
if (-not (Test-Path $vscodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vscodeSettingsDir -Force | Out-Null
}

$vscodeSettings = @{
    "powershell.codeFormatting.preset" = "OTBS"
    "powershell.scriptAnalysis.enable" = $true
    "json.schemas" = @(
        @{
            "fileMatch" = @("policies/definitions/*.json")
            "url" = "https://raw.githubusercontent.com/Azure/azure-policy/master/schemas/policy-definition-schema.json"
        }
    )
}

$vscodeSettingsJson = $vscodeSettings | ConvertTo-Json -Depth 10
Set-Content -Path "$vscodeSettingsDir\settings.json" -Value $vscodeSettingsJson
Write-Host "Created VS Code settings" -ForegroundColor Green

Write-Host "`nAzure Policy Development Environment setup completed!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Connect to Azure: Connect-AzAccount" -ForegroundColor White
Write-Host "2. Set your subscription: Set-AzContext -SubscriptionId 'your-subscription-id'" -ForegroundColor White
Write-Host "3. Start creating policies in the policies/definitions folder" -ForegroundColor White
Write-Host "4. Run tests: Invoke-Pester -Path ./tests" -ForegroundColor White