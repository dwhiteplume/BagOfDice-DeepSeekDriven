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