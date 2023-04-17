function Decode-URL{
    Param(
        [Parameter(Mandatory=$false)] [string] $EncodedString
    )

    Write-Debug "Decoding '$EncodedString'"
    try{
        $DecodedString = [System.Net.WebUtility]::UrlDecode($EncodedString)
        return $DecodedString
    }
    catch{
        Write-Debug "Error decoding '$EncodedString'"
        Write-Debug $_
        return $EncodedString
    }
    
}
