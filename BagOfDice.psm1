[CmdletBinding()]
param()

# Import all public functions
$publicPath = Join-Path $PSScriptRoot "Public"
$publicFunctions = Get-ChildItem -Path $publicPath -Filter "*.ps1" -ErrorAction Stop

foreach ($functionFile in $publicFunctions) {
    try {
        . $functionFile.FullName
        Write-Verbose "Imported function from: $($functionFile.Name)"
    }
    catch {
        Write-Error "Failed to import function from $($functionFile.Name): $_"
    }
}

# Initialize module-level variables
$script:Random = [System.Random]::new()

# Export module members
Export-ModuleMember -Function @(
    'Get-RandomNumber',
    'Invoke-DiceRoll', 
    'Invoke-MultipleDiceRoll',
    'Invoke-PercentageRoll',
    'ConvertFrom-DiceExpression',
    'Invoke-DiceExpression'
)
