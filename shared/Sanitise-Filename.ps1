# Will encode invalid filename characters
function Sanitise-FileName
{
    param(
        [Parameter(Mandatory=$true)] [string] $Filename
    )
    
    $BadCharacters = @(
        '\',
        '/',
        ':',
        '*',
        '?',
        '"',
        '<',
        '>',
        '|'
    )

    $SanitisedFilename = $Filename
    foreach($BadCharacter in $BadCharacters){
        $SanitisedFilename = $SanitisedFilename.Replace($BadCharacter, [System.Web.HttpUtility]::UrlEncode($BadCharacter))
    }
    
    return $SanitisedFilename
}