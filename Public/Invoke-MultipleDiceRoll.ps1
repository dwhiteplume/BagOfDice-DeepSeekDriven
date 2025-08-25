function Invoke-MultipleDiceRoll {
    <#
    .SYNOPSIS
        Rolls multiple dice of the same type.
    .DESCRIPTION
        Rolls the specified number of dice with the given number of sides and returns individual results and total.
    .PARAMETER Count
        The number of dice to roll.
    .PARAMETER Sides
        The number of sides on each die.
    .EXAMPLE
        Invoke-MultipleDiceRoll -Count 3 -Sides 6
        Rolls three six-sided dice and returns the results.
    .EXAMPLE
        Invoke-MultipleDiceRoll -Count 2 -Sides 4
        Rolls two four-sided dice.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Count,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Sides
    )
    
    process {
        $rolls = @()
        $total = 0
        
        for ($i = 0; $i -lt $Count; $i++) {
            $roll = Invoke-DiceRoll -Sides $Sides
            $rolls += $roll
            $total += $roll
        }
        
        return [PSCustomObject]@{
            Count = $Count
            Sides = $Sides
            Rolls = $rolls
            Total = $total
        }
    }
}