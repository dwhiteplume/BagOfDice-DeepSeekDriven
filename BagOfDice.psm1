#Requires -Version 5.1

$script:Random = [System.Random]::new()

function Get-RandomNumber {
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
    [CmdletBinding()]
    [OutputType([int])]
    param()
    process {
        $tensDie = Invoke-DiceRoll -Sides 10
        $onesDie = Invoke-DiceRoll -Sides 10
        $tensValue = if ($tensDie -eq 10) { 0 } else { $tensDie }
        $onesValue = if ($onesDie -eq 10) { 0 } else { $onesDie }
        $result = ($tensValue * 10) + $onesValue
        if ($result -eq 0) {
            return 100
        }
        return $result
    }
}

function ConvertFrom-DiceExpression {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Expression
    )
    process {
        $cleanExpression = $Expression -replace '\s', '' -replace '‐', '-' -replace '–', '-' -replace '—', '-' | 
            ForEach-Object { $PSItem.ToLower() }
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
                $modifier = [int]$matches[1]
                $components += [PSCustomObject]@{
                    Type = 'Modifier'
                    Value = $modifier
                }
                $currentIndex += $matches[1].Length
            }
            elseif ($remaining -match '^(\d+)?d(\d+)(.*)$') {
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

Export-ModuleMember -Function @(
    'Get-RandomNumber',
    'Invoke-DiceRoll',
    'Invoke-MultipleDiceRoll',
    'Invoke-PercentageRoll',
    'ConvertFrom-DiceExpression',
    'Invoke-DiceExpression'
)