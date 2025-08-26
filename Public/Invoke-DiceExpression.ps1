function Invoke-DiceExpression {
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
        
        # Parse tokens with correct pattern matching order
        while ($currentIndex -lt $cleanExpression.Length) {
            $remaining = $cleanExpression.Substring($currentIndex)
            
            Write-Verbose "Processing: '$remaining' at position $currentIndex"
            
            # 1. FIRST check for explicit dice patterns (NdS)
            if ($remaining -match '^(\d+)d(\d+)(.*)$') {
                # Explicit dice count (2d4, 3d6, etc.)
                $count = [int]$matches[1]
                $sides = [int]$matches[2]
                $remainingAfterMatch = $matches[3]
                
                Write-Verbose "Found dice: ${count}d${sides}"
                
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
                
                $currentIndex += $matches[0].Length - $remainingAfterMatch.Length
                continue
            }
            # 2. THEN check for implicit dice patterns (dS)
            elseif ($remaining -match '^d(\d+)(.*)$') {
                # Implied dice count (d6, d20, etc.) - count=1
                $sides = [int]$matches[1]
                $remainingAfterMatch = $matches[2]
                
                Write-Verbose "Found implied dice: d${sides}"
                
                if ($sides -le 1) { throw "Dice sides must be ≥2: $sides" }
                
                # Roll the single die
                $roll = Invoke-DiceRoll -Sides $sides
                $total += $roll
                $rollReport += "[$roll]"
                
                $currentIndex += $matches[0].Length - $remainingAfterMatch.Length
                continue
            }
            # 3. FINALLY check for modifiers (this must come LAST!)
            elseif ($remaining -match '^([+-])(\d+)(.*)$') {
                # Signed modifiers (+1, -2, etc.)
                $sign = $matches[1]
                $modifierValue = [int]$matches[2]
                $remainingAfterMatch = $matches[3]
                
                Write-Verbose "Found modifier: ${sign}${modifierValue}"
                
                $modifier = if ($sign -eq '+') { $modifierValue } else { -$modifierValue }
                $total += $modifier
                $rollReport += "${sign}${modifierValue}"
                
                $currentIndex += $matches[0].Length - $remainingAfterMatch.Length
                continue
            }
            elseif ($remaining -match '^(\d+)(.*)$') {
                # Unsigned positive modifiers (should be rare in dice notation)
                $modifier = [int]$matches[1]
                $remainingAfterMatch = $matches[2]
                
                Write-Verbose "Found unsigned modifier: ${modifier}"
                
                $total += $modifier
                $rollReport += "+${modifier}"
                
                $currentIndex += $matches[1].Length
                continue
            }
            else {
                throw ("Failed to parse expression at position {0}: '{1}'" -f $currentIndex, $remaining)
            }
        }
        
        # Generate visual report
        $reportString = $rollReport -join ''
        Write-Host "$Expression = $reportString = $total" -ForegroundColor Cyan
        return $total
    }
}