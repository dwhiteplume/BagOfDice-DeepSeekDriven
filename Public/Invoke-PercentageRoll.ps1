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
        
        $tensValue = if ($tensDie -eq 10) { 0 } else { $tensDie }
        $onesValue = if ($onesDie -eq 10) { 0 } else { $onesDie }
        
        $result = ($tensValue * 10) + $onesValue
        
        if ($result -eq 0) {
            return 100
        }
        
        return $result
    }
}