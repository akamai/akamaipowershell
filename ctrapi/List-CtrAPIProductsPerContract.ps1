function List-CtrApiProductsPerContract
{
    Param(
        [Parameter(Mandatory=$true)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $From,
        [Parameter(Mandatory=$false)] [string] $To,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateMatch = '[\d]{4}-[\d]{2}-[\d]{2}'
    if(($From -or $To) -and ($From -notmatch $DateMatch -or $To -notmatch $DateMatch)){
        throw "ERROR: From & To must be in the format 'YYYY-MM-DD'"
    }

    $Path = "/contract-api/v1/contracts/$ContractID/products/summaries?from=$From&to=$To"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.products.'marketing-products'
    }
    catch {
        throw $_
    }  
}
