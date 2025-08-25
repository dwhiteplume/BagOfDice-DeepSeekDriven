<#
.SYNOPSIS
PowerShell module for dice rolling operations including complex dice expressions.
.DESCRIPTION
Provides functions for rolling various types of dice including single dice, multiple dice,
percentage rolls, and complex dice expressions with modifiers.
#>

#Requires -Version 5.1

using namespace System.Management.Automation

$script:Random = [System.Random]::new()

function Get-RandomNumber {
    <#
    .SYNOPSIS
        Generates a random number within a specified range.
    .DESCRIPTION
        Returns a random integer between the specified minimum and maximum values (inclusive).
    .PARAMETER Minimum
        The minimum value of the range (inclusive). Default is 1.
    .PARAMETER Maximum
        The maximum value of the range (inclusive).
    .EXAMPLE
        Get-RandomNumber -Minimum 1 -Maximum 6
        Returns a random number between 1 and 6.
    .EXAMPLE
        Get-RandomNumber -Maximum 20
        Returns a random number between 1 and 20.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Position = 0)]
        [int]$Minimum = 1,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [int]$Maximum
    )
    
    process {
        if ($Minimum -gt $Maximum) {
            Write-Error "Minimum value cannot be greater than maximum value."
            return
        }
        
        return $script:Random.Next($Minimum, $Maximum + 1)
    }
}

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

function Invoke-PercentageRoll {
    <#
    .SYNOPSIS
        Rolls a percentage value using two ten-sided dice.
    .DESCRIPTION
        Simulates a percentage roll (d%) using two ten-sided dice where one represents tens and the other ones.
        A roll of 00 (0 tens and 0 ones) is interpreted as 100.
    .EXAMPLE
        Invoke-PercentageRoll
        Rolls a percentage value between 1 and 100.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param()
    
    process {
        $tensDie = Invoke-DiceRoll -Sides 10
        $onesDie = Invoke-DiceRoll -Sides 10
        
        # Adjust for 0-based: 0 becomes 10, but for percentage we need special handling
        $tensValue = if ($tensDie -eq 10) { 0 } else { $tensDie }
        $onesValue = if ($onesDie -eq 10) { 0 } else { $onesDie }
        
        $result = ($tensValue * 10) + $onesValue
        
        # 00 is interpreted as 100
        if ($result -eq 0) {
            return 100
        }
        
        return $result
    }
}

function ConvertFrom-DiceExpression {
    <#
    .SYNOPSIS
        Parses a dice expression string into its components.
    .DESCRIPTION
        Parses dice expressions like "d6", "3d6", "2d4+1", or "d8+2d4+2" into a structured object.
    .PARAMETER Expression
        The dice expression to parse.
    .EXAMPLE
        ConvertFrom-DiceExpression -Expression "3d6"
        Parses the expression "3d6" into its components.
    .EXAMPLE
        ConvertFrom-DiceExpression -Expression "2d4+1d8+2"
        Parses a complex dice expression.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Expression
    )
    
    process {
        # Remove whitespace and convert to lowercase for consistent parsing
        $cleanExpression = $Expression -replace '\s', '' -replace '‐', '-' -replace '–', '-' -replace '—', '-' | 
            ForEach-Object { $PSItem.ToLower() }
        
        # Regex pattern to match dice expressions: [count]d[sides][+-modifier]
        $pattern = '^(?:(?<count>\d+)?d(?<sides>\d+)|(?<modifier>[+-]?\d+))+$'
        
        if ($cleanExpression -notmatch $pattern) {
            Write-Error "Invalid dice expression: $Expression"
            return $null
        }
        
        $components = @()
        $currentIndex = 0
        
        while ($currentIndex -lt $cleanExpression.Length) {
            $remaining = $cleanExpression.Substring($currentIndex)
            
            if ($remaining -match '^([+-]?\d+)(.*)$') {
                # It's a modifier
                $modifier = [int]$matches[1]
                $components += [PSCustomObject]@{
                    Type = 'Modifier'
                    Value = $modifier
                }
                $currentIndex += $matches[1].Length
            }
            elseif ($remaining -match '^(\d+)?d(\d+)(.*)$') {
                # It's a dice roll
                $count = if ([string]::IsNullOrEmpty($matches[1])) { 1 } else { [int]$matches[1] }
                $sides = [int]$matches[2]
                
                $components += [PSCustomObject]@{
                    Type = 'Dice'
                    Count = $count
                    Sides = $sides
                }
                $currentIndex += $matches[0].Length - $matches[3].Length
            }
            else {
                Write-Error "Failed to parse expression at position $currentIndex: $remaining"
                return $null
            }
        }
        
        return [PSCustomObject]@{
            OriginalExpression = $Expression
            Components = $components
        }
    }
}

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

# Export the module functions
Export-ModuleMember -Function @(
    'Get-RandomNumber',
    'Invoke-DiceRoll',
    'Invoke-MultipleDiceRoll',
    'Invoke-PercentageRoll',
    'ConvertFrom-DiceExpression',
    'Invoke-DiceExpression'
)