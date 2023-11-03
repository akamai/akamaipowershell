# Will encode invalid filename characters
function Sanitize-FileName
{
    [alias('Sanitise-FileName')]
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

    $SanitizedFilename = $Filename
    foreach($BadCharacter in $BadCharacters){
        $SanitizedFilename = $SanitizedFilename.Replace($BadCharacter, [System.Web.HttpUtility]::UrlEncode($BadCharacter))
    }

    #Special Handling for asterisk, which the HttpUtility doesn't encode
    $SanitizedFilename = $SanitizedFilename.Replace('*','%2A')
    
    return $SanitizedFilename
}
