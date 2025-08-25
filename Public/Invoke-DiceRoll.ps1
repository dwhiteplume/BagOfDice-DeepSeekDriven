function Invoke-DiceRoll {
    <#
    .SYNOPSIS
        Rolls a single die with the specified number of sides.
    .DESCRIPTION
        Simulates rolling a single die with the given number of sides.
    .PARAMETER Sides
        The number of sides on the die. Common values are 4, 6, 8, 10, 12, 20, 100.
    .EXAMPLE
        Invoke-DiceRoll -Sides 6
        Rolls a standard six-sided die.
    .EXAMPLE
        Invoke-DiceRoll -Sides 20
        Rolls a twenty-sided die (d20).
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Sides
    )
    
    process {
        return Get-RandomNumber -Maximum $Sides
    }
}