# BagOfDice.psm1 - Development Version
# This module can be loaded from any directory during development

# Initialize module-level variables
$script:Random = [System.Random]::new()

# Get the directory where this module file is located
$moduleRoot = $PSScriptRoot

# Import all public functions
$publicPath = Join-Path $moduleRoot "Public"
Write-Verbose "Importing functions from: $publicPath"

if (Test-Path $publicPath) {
    $functionFiles = Get-ChildItem -Path $publicPath -Filter "*.ps1" -ErrorAction Stop
    
    foreach ($file in $functionFiles) {
        try {
            Write-Verbose "Importing function from: $($file.Name)"
            . $file.FullName
        }
        catch {
            Write-Error "Failed to import function from $($file.Name): $_"
        }
    }
}
else {
    Write-Warning "Public directory not found at: $publicPath"
}

# Export module members
Export-ModuleMember -Function @(
    'Get-RandomNumber',
    'Invoke-DiceRoll', 
    'Invoke-MultipleDiceRoll',
    'Invoke-PercentageRoll',
    'ConvertFrom-DiceExpression',
    'Invoke-DiceExpression'
)

Write-Verbose "BagOfDice module loaded successfully from: $moduleRoot"
