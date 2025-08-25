# Bag of Dice 🎊
A powerful and flexible PowerShell module for simulating dice rolls, parsing complex dice expressions, and generating random numbers for tabletop gaming, RPGs, and probability testing.

# # Features

-   **Single Die Rolls**: Roll any Nsided die (d6, d20, etc.)
-   **Multiple Dice Rolls**: Roll multiple dice of the same type (3d6, 2d4, etc.)
-   **Percentage Rolls**: Traditional d% rolls where 00 is interpreted as 100
-   **Complex Expressions**: Parse and evaluate advanced dice expressions (2d4+1d8+2, 3d6-1, etc.)
-   **Pipeline Support**: Process multiple expressions through the pipeline
-   **Detailed Results**: Get both total values and individual roll breakdowns

## Installation

### Manual Installation

1.  Download or clone this repository
2.  Copy the BagOfDice folder to your PowerShell modules directory:

    ```powershell
    # Typical path for Windows PowerShell
    $env:USERPROFILE\Documents\WindowsPowerShell\Modules\
    
    # Typical path for PowerShell Core
    $env:USERPROFILE\Documents\PowerShell\Modules\
    ```

3.  Import the module:

    ```powershell
    Import-Module BagOfDice
    ```

### Using Build Script

Run the provided build script from the project root:

    ```powershell
    .\Build.ps1
    ```

## Functions

### `Invoke-DiceRoll`
Rolls a single die with specified number of sides.

    ```powershell
    Invoke-DiceRoll -Sides 6
    # Returns: 4 (example result)
    ```

### `Invoke-MultipleDiceRoll`

Rolls multiple dice of the same type and returns individual results and total.

    ```powershell
    Invoke-MultipleDiceRoll -Count 3 -Sides 6
    # Returns: Object with Count, Sides, Rolls array, and Total
    ```

### `Invoke-PercentageRoll`

Rolls a percentage value (d%) using two ten-sided dice where one represents tens and the other ones.

    ```powershell
    Invoke-PercentageRoll
    # Returns: 47 (example result, 00 = 100)
    ```

### `Invoke-DiceExpression`

Parses and evaluates complex dice expressions.

    ```powershell
    Invoke-DiceExpression -Expression "2d4+1d8+2"
    # Returns: Object with Expression, Total, and RollDetails

    # Pipeline usage
    "d6", "3d6", "2d4+1" | Invoke-DiceExpression
    ```

## Examples

    ```powershell
    # Basic dice rolls
    Invoke-DiceRoll -Sides 20
    Invoke-MultipleDiceRoll -Count 4 -Sides 6

    # Complex expressions
    Invoke-DiceExpression -Expression "3d6+2"
    Invoke-DiceExpression -Expression "1d8+2d4-1"

    # Percentage rolls for RPG skill checks
    Invoke-PercentageRoll
    ```

## Module Structure

```
BagOfDice/�  ℃ BagOfDice.psd1 (Module manifest)
   ℃ BagOfDice.psm1 (Main module file)
    ℃ Build.ps1 (Optional build script)
```

## Requirements

- PowerShell 5.1 or newer
- .NED Framework 4.7.2 or newer

## License

MIT License - feel free to use in personal and commercial projects.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please open an issue on the GitHub repository.
