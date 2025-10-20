# Test Azure Policy Definitions
param(
    [string]$PolicyPath = "./policies/definitions"
)

Write-Host "Starting policy validation..." -ForegroundColor Green

# Get all policy definition files
$policyFiles = Get-ChildItem -Path $PolicyPath -Filter "*.json" -Recurse
$validationResults = @()

foreach ($file in $policyFiles) {
    $result = @{
        File = $file.Name
        Path = $file.FullName
        Valid = $false
        Errors = @()
    }
    
    try {
        Write-Host "Validating policy: $($file.Name)" -ForegroundColor Yellow
        
        # Test JSON syntax
        $policyContent = Get-Content $file.FullName | ConvertFrom-Json
        
        # Validate required fields
        $requiredFields = @('if', 'then')
        foreach ($field in $requiredFields) {
            if (-not $policyContent.$field) {
                $result.Errors += "Missing required field: $field"
            }
        }
        
        # Validate metadata
        if (-not $policyContent.metadata) {
            $result.Errors += "Missing metadata section"
        } else {
            if (-not $policyContent.metadata.displayName) {
                $result.Errors += "Missing displayName in metadata"
            }
            if (-not $policyContent.metadata.description) {
                $result.Errors += "Missing description in metadata"
            }
        }
        
        if ($result.Errors.Count -eq 0) {
            $result.Valid = $true
            Write-Host "Policy is valid: $($file.Name)" -ForegroundColor Green
        } else {
            Write-Host "Policy has errors: $($file.Name)" -ForegroundColor Red
            foreach ($errorMsg in $result.Errors) {
                Write-Host "  - $errorMsg" -ForegroundColor Red
            }
        }
    }
    catch {
        $result.Errors += "JSON parsing error: $($_.Exception.Message)"
        Write-Host "JSON parsing error in: $($file.Name)" -ForegroundColor Red
        Write-Host "  - $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $validationResults += $result
}

# Summary
$validResults = @($validationResults | Where-Object { $_.Valid -eq $true })
$validPolicies = $validResults.Count
$totalPolicies = $validationResults.Count

Write-Host "`nValidation Summary:" -ForegroundColor Cyan
Write-Host "Total policies: $totalPolicies" -ForegroundColor White
Write-Host "Valid policies: $validPolicies" -ForegroundColor Green
Write-Host "Invalid policies: $($totalPolicies - $validPolicies)" -ForegroundColor Red

if ($validPolicies -eq $totalPolicies) {
    Write-Host "`nAll policies are valid!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome policies have validation errors!" -ForegroundColor Red
    exit 1
}