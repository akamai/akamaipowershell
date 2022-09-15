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

    #Special Handling for asterisk, which the HttpUtility doesn't encode
    $SanitisedFilename = $SanitisedFilename.Replace('*','%2A')
    
    return $SanitisedFilename
}
