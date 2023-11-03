# Will remove null query parameters and encode invalid characters
function Sanitize-QueryString
{
  [alias('Sanitise-QueryString')]
    param(
        [Parameter(Mandatory=$true)] [string] $QueryString
    )
    
    $ValidParameters = New-Object -TypeName System.Collections.ArrayList

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
                $ValidParameters.Add($Parameter) | Out-Null
            }
        }
    }

    if($ValidParameters.Count -eq 0)
    {
        return $null
    }
    else {
        $JoinedParameters = $ValidParameters -join "&"
        return $JoinedParameters
    }
}
