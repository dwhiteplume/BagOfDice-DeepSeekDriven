function Invoke-PercentageRoll {
    <#
    .SYNOPSIS
        Rolls percentile dice (d%) using two ten-sided dice.
    .DESCRIPTION
        Simulates rolling physical percentile dice where:
        - One die represents tens (00, 10, 20, ..., 90)
        - One die represents ones (0, 1, 2, ..., 9)
        - A roll of 00 and 0 is interpreted as 100
        - All other combinations are read as-is (00+1=1, 90+9=99, etc.)
    .EXAMPLE
        Invoke-PercentageRoll
        # Returns a value between 1-100 based on physical dice probabilities
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param()
    
    process {
        # Roll two ten-sided dice (0-9)
        $tensDie = Invoke-DiceRoll -Sides 10  # Returns 1-10, but we need 0-9
        $onesDie = Invoke-DiceRoll -Sides 10  # Returns 1-10, but we need 0-9
        
        # Convert to 0-9 range (typical d10 numbering)
        $tensValue = $tensDie - 1  # 1→0, 2→1, ..., 10→9
        $onesValue = $onesDie - 1  # 1→0, 2→1, ..., 10→9
        
        # Calculate result (tensValue is already 0-9, representing 00-90)
        $result = ($tensValue * 10) + $onesValue
        
        # 00 + 0 is interpreted as 100
        if ($result -eq 0) {
            return 100
        }
        
        return $result
    }
}
