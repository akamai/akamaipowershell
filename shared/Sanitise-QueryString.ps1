# Will remove null query parameters and encode invalid characters
function Sanitise-QueryString
{
    param(
        [Parameter(Mandatory=$true)] [string] $QueryString
    )
    
    $ParsedParameters = @()

    # Remove invalid characters
    $QueryString = $QueryString.Replace(" ","%20")
    
    # Parse Elements
    if($QueryString.Contains("&"))
    {
        $Parameters = $QueryString.Split("&")
    }
    else {
        $Parameters = $QueryString
    }

    foreach($Parameter in $Parameters)
    {
        if(!$Parameter.Contains("="))
        {
            Write-Host -ForegroundColor Red "ERROR: '$Parameter' has no value"
            return $QueryString
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
        return $QueryString
    }
    else {
        $JoinedParameters = $ParsedParameters -join "&"
        return $JoinedParameters
    }
}