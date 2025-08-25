[CmdletBinding()]
param()

Write-Verbose "Initiate script scoped variable `$Random"
$script:Random = [System.Random]::new()
$Test = Get-Variable Random -Scope Script | Select-Object -ExpandProperty Value
Write-Verbose "Success = $(($Test.GetType()| Select-Object -ExpandProperty FullName) -eq 'System.Random')"

Write-Verbose "Import all public functions"
$publicFunctions = try {
                     Get-ChildItem -Path "$PSScriptRoot/Public" -Filter "*.ps1" -ErrorAction Stop
                     Write-Verbose "Imported $((Get-ChildItem -Path "$PSScriptRoot/Public" -Filter "*.ps1").Count) functions."
                   } catch {
                     Write-Error "Unable to import functions. Exiting"
                     exit 1
                   }
Write-Verbose "Processing functions..."
foreach ($functionFile in $publicFunctions) {
    Write-verbose "... $($functionFile.FullName)"
    . $functionFile.FullName
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
