# Deploy Azure Policy Definitions
# This script deploys policy definitions to Azure

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$ManagementGroupId,
    
    [Parameter(Mandatory = $false)]
    [string]$PolicyPath = "./policies/definitions"
)

# Connect to Azure
Write-Host "Connecting to Azure..." -ForegroundColor Green
Connect-AzAccount -Subscription $SubscriptionId

# Set context
Set-AzContext -SubscriptionId $SubscriptionId

# Get all policy definition files
$policyFiles = Get-ChildItem -Path $PolicyPath -Filter "*.json" -Recurse

foreach ($file in $policyFiles) {
    try {
        Write-Host "Processing policy: $($file.Name)" -ForegroundColor Yellow
        
        # Read policy content
        $policyContent = Get-Content $file.FullName | ConvertFrom-Json
        
        # Extract policy name from filename
        $policyName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        
        # Deploy policy definition
        if ($ManagementGroupId) {
            # Deploy to management group
            New-AzPolicyDefinition -Name $policyName -Policy $file.FullName -ManagementGroupName $ManagementGroupId
        } else {
            # Deploy to subscription
            New-AzPolicyDefinition -Name $policyName -Policy $file.FullName -SubscriptionId $SubscriptionId
        }
        
        Write-Host "Successfully deployed policy: $policyName" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to deploy policy $($file.Name): $($_.Exception.Message)"
    }
}

Write-Host "Policy deployment completed!" -ForegroundColor Green