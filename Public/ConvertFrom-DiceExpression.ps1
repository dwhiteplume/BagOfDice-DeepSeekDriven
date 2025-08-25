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