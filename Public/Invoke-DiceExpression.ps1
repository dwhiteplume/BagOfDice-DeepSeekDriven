function Invoke-DiceExpression {
    <#
    .SYNOPSIS
        Evaluates complex dice expressions and provides detailed roll reporting.
    .DESCRIPTION
        Parses and evaluates dice expressions like "3d6+1" or "1d8+2d4-1" with 
        detailed reporting of individual dice rolls and modifiers.
    .PARAMETER Expression
        The dice expression to evaluate (e.g., "3d6+1", "1d8+2d4-1")
    .EXAMPLE
        Invoke-DiceExpression -Expression "3d6+1"
        # Returns: 12
        # Reports: [4,2,6]+1 = 12
    .EXAMPLE  
        Invoke-DiceExpression -Expression "1d8+2d4-1"
        # Returns: 9
        # Reports: [7]+[1,3]-1 = 9
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Expression
    )
    
    process {
        # Clean and tokenize the expression
        $cleanExpression = $Expression -replace '\s', ''  # Remove whitespace
        Write-Verbose "Parsing expression: $cleanExpression"
        
        # Initialize tracking variables
        $total = 0
        $rollReport = @()
        $currentIndex = 0
        $expressionParts = @()
        
        # Parse the expression
        while ($currentIndex -lt $cleanExpression.Length) {
            $remaining = $cleanExpression.Substring($currentIndex)
            
            # Check for dice roll pattern (NdS or dS)
            if ($remaining -match '^(\d*)d(\d+)(.*)$') {
                $count = if ([string]::IsNullOrEmpty($matches[1])) { 1 } else { [int]$matches[1] }
                $sides = [int]$matches[2]
                
                # Validate dice parameters
                if ($count -le 0) {
                    throw "Invalid dice count: $count. Must be positive integer."
                }
                if ($sides -le 1) {
                    throw "Invalid side count: $sides. Must be at least 2."
                }
                
                # Roll the dice
                $rolls = @()
                $diceTotal = 0
                for ($i = 0; $i -lt $count; $i++) {
                    $roll = Invoke-DiceRoll -Sides $sides
                    $rolls += $roll
                    $diceTotal += $roll
                }
                
                $total += $diceTotal
                $rollReport += "[$($rolls -join ',')]"
                $expressionParts += "d$sides"
                
                $currentIndex += $matches[0].Length - $matches[3].Length
            }
            # Check for modifier pattern (+N or -N)
            elseif ($remaining -match '^([+-]?\d+)(.*)$') {
                $modifier = [int]$matches[1]
                $total += $modifier
                
                if ($modifier -ge 0) {
                    $rollReport += "+$modifier"
                    $expressionParts += "+$modifier"
                } else {
                    $rollReport += "$modifier"  # Negative numbers already have -
                    $expressionParts += "$modifier"
                }
                
                $currentIndex += $matches[1].Length
            }
            else {
                throw "Failed to parse expression at position $currentIndex: '$remaining'"
            }
        }
        
        # Build and display the detailed report
        $reportString = $rollReport -join ''
        Write-Host "$Expression = $reportString = $total" -ForegroundColor Cyan
        
        # Return the final total
        return $total
    }
}
