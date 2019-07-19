function Remove-NullQueryParameters
{
    param(
        [Parameter(Mandatory=$true)] [string] $ReqURL
    )
    
    $ParsedParameters = @()
    # Add support for just the query string being passed, not the whole URL
    if($ReqURL.Contains("/")){
        if(!$ReqURL.Contains("?"))
        {
            return $ReqURL
        }

        $URI = $ReqURL.Substring(0,$ReqURL.IndexOf("?"))
        $QueryString = $ReqURL.Substring($ReqURL.IndexOf("?")+1)
        $JustQueryString = $false
    }
    else{
        $QueryString = $ReqURL
        $JustQueryString = $true
    }
    
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

    if($ParsedParameters.Count -eq 0)
    {
        return $URI
    }
    else {
        $JoinedParameters = $ParsedParameters -join "&"
        if($JustQueryString){
            return $JoinedParameters
        }
        else{
            return "$URI`?$JoinedParameters"
        }
    }
}