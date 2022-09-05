function Get-RandomString {
    param(
        [Parameter(Mandatory=$false)] [int] $Length = 16,
        [Parameter(Mandatory=$true, ParameterSetName='Alphabetical')] [switch] $Alphabetical,
        [Parameter(Mandatory=$true, ParameterSetName='AlphaNumeric')] [switch] $AlphaNumeric,
        [Parameter(Mandatory=$true, ParameterSetName='Numerical')] [switch] $Numerical,
        [Parameter(Mandatory=$true, ParameterSetName='Hex')] [switch] $Hex
    )

    $Multiplier = 120
    $AlphabetRange = (97..122)
    $AtoFRange = (97..102)
    $NumberRange = (48..57)

    Switch($PSCmdlet.ParameterSetName) {
        'Alphabetical' { $CharRange = $AlphabetRange }
        'AlphaNumeric' { $CharRange = $AlphabetRange + $NumberRange }
        'Numerical'    { $CharRange = $NumberRange }
        'Hex'          { $CharRange = $AtoFRange + $NumberRange}
    }

    $Result = -join ( $CharRange *$Multiplier | Get-Random -Count $Length | foreach {[char]$_})
    return $Result
}