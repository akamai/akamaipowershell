function Remove-NullQueryParameters
{
    param(
        [Parameter(Mandatory=$true)] [string] $ReqURL
        )
    
    $ParsedParameters = @()

    if(!$ReqURL.Contains("?"))
    {
        Write-Host "No query string"
        return $ReqURL
    }

    $URI = $ReqURL.Substring(0,$ReqURL.IndexOf("?"))
    $QueryString = $ReqURL.Substring($ReqURL.IndexOf("?")+1)

    if($QueryString.Contains("&"))
    {
        $Parameters = $QueryString.Split("&")
    }
    else {
        $Parameters = @()
        $Parameters = $QueryString
    }

    foreach($Parameter in $Parameters)
    {
        if(!$Parameter.Contains("="))
        {
            Write-Host -ForegroundColor Red "ERROR: '$Parameter' seems wrong"
            return $ReqURL
        }
        else {
            if($Parameter.Length -gt $Parameter.IndexOf("=") + 1)
            {
                $ParsedParameters += $Parameter
            }
        }
    }

    $JoinedParameters = $ParsedParameters -join "&"
    return "$URI`?$JoinedParameters"
}