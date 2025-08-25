function Invoke-DiceExpression {
    <#
    .SYNOPSIS
        Evaluates a dice expression and returns the result.
    .DESCRIPTION
        Parses and evaluates complex dice expressions like "d6", "3d6", "2d4+1", or "d8+2d4+2".
    .PARAMETER Expression
        The dice expression to evaluate.
    .EXAMPLE
        Invoke-DiceExpression -Expression "3d6"
        Rolls three six-sided dice and returns the total.
    .EXAMPLE
        Invoke-DiceExpression -Expression "2d4+1d8+2"
        Rolls two four-sided dice, one eight-sided die, adds 2, and returns the total.
    .EXAMPLE
        "d6", "3d6", "2d4+1" | Invoke-DiceExpression
        Processes multiple dice expressions through the pipeline.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Expression
    )
    
    process {
        $parsed = ConvertFrom-DiceExpression -Expression $Expression
        if (-not $parsed) {
            return $null
        }
        
        $total = 0
        $rollDetails = @()
        
        foreach ($component in $parsed.Components) {
            switch ($component.Type) {
                'Dice' {
                    $diceResult = Invoke-MultipleDiceRoll -Count $component.Count -Sides $component.Sides
                    $total += $diceResult.Total
                    $rollDetails += "{$($component.Count)d$($component.Sides)=$($diceResult.Rolls -join ',')}"
                }
                'Modifier' {
                    $total += $component.Value
                    $rollDetails += if ($component.Value -ge 0) {
                        "{+$($component.Value)}"
                    } else {
                        "{$($component.Value)}"
                    }
                }
            }
        }
        
        return [PSCustomObject]@{
            Expression = $Expression
            Total = $total
            RollDetails = $rollDetails -join ' '
            Components = $parsed.Components
        }
    }
}