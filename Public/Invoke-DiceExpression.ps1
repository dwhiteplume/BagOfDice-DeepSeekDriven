function Invoke-DiceExpression {
    <#
    .SYNOPSIS
        Evaluates complex dice expressions with detailed verbose reporting.
    .DESCRIPTION
        Parses and evaluates dice expressions like "3d6+1" or "1d8+2d4-1" with 
        detailed verbose reporting of individual dice rolls and modifiers.
    .PARAMETER Expression
        The dice expression to evaluate (e.g., "3d6+1", "1d8+2d4-1")
    .EXAMPLE
        Invoke-DiceExpression -Expression "3d6+1" -Verbose
        # Returns: 12
        # Verbose output shows: [4,2,6] +1 = 12
    .EXAMPLE  
        Invoke-DiceExpression -Expression "1d8+2d4-1" -Verbose
        # Returns: 9
        # Verbose output shows: [7] + [1,3] -1 = 9
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Expression
    )
    
    process {
        # Clean the expression
        $cleanExpression = $Expression -replace '\s', ''
        Write-Verbose "Parsing expression: $cleanExpression"
        
        $total = 0
        $rollReport = @()
        $currentIndex = 0
        
        # Parse the expression into operations
        while ($currentIndex -lt $cleanExpression.Length) {
            $remaining = $cleanExpression.Substring($currentIndex)
            
            # 1. Check for dice patterns first (NdS)
            if ($remaining -match '^(\d+d\d+)') {
                $operation = $matches[1]
                Write-Verbose "Found dice operation: $operation"
                
                # Parse dice components
                if ($operation -match '^(\d+)d(\d+)$') {
                    $count = [int]$matches[1]
                    $sides = [int]$matches[2]
                    
                    # Validate
                    if ($count -le 0) { throw "Dice count must be positive: $count" }
                    if ($sides -le 1) { throw "Dice sides must be ≥2: $sides" }
                    
                    # Roll the dice
                    $rolls = @()
                    for ($i = 1; $i -le $count; $i++) {
                        $roll = Invoke-DiceRoll -Sides $sides
                        $rolls += $roll
                    }
                    $diceTotal = ($rolls | Measure-Object -Sum).Sum
                    $total += $diceTotal
                    $rollReport += "[$($rolls -join ',')]"
                    
                    $currentIndex += $operation.Length
                    continue
                }
            }
            # 2. Check for implied dice patterns (dS)
            elseif ($remaining -match '^(d\d+)') {
                $operation = $matches[1]
                Write-Verbose "Found implied dice operation: $operation"
                
                if ($operation -match '^d(\d+)$') {
                    $sides = [int]$matches[1]
                    
                    if ($sides -le 1) { throw "Dice sides must be ≥2: $sides" }
                    
                    # Roll the single die
                    $roll = Invoke-DiceRoll -Sides $sides
                    $total += $roll
                    $rollReport += "[$roll]"
                    
                    $currentIndex += $operation.Length
                    continue
                }
            }
            # 3. Check for modifiers with explicit signs (+N, -N)
            elseif ($remaining -match '^([+-]\d+)') {
                $operation = $matches[1]
                Write-Verbose "Found modifier operation: $operation"
                
                $modifier = [int]$operation  # PowerShell handles +1/-1 conversion
                $total += $modifier
                $rollReport += $operation
                
                $currentIndex += $operation.Length
                continue
            }
            # 4. Check for positive modifiers without explicit + (rare)
            elseif ($remaining -match '^(\d+)') {
                $operation = $matches[1]
                Write-Verbose "Found unsigned positive modifier: $operation"
                
                $modifier = [int]$operation
                $total += $modifier
                $rollReport += "+$operation"
                
                $currentIndex += $operation.Length
                continue
            }
            else {
                # Use string formatting to avoid parser issues
                $errorMessage = "Failed to parse expression at position {0} '{1}'" -f $currentIndex, $remaining
                throw $errorMessage
            }
        }
        
        # Generate verbose report
        $reportString = $rollReport -join ' '
        Write-Verbose "$Expression = $reportString = $total"
        
        # Return just the final total
        return $total
    }
}