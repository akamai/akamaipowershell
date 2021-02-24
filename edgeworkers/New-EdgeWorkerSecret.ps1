function New-EdgeWorkerSecret
{
    $Lenth = 64
    $Secret = ''
    While($Secret.length -lt $Length){
        $Secret += ((48..57) + (97..102) | Get-Random | foreach { [char]$_ } )
    }
    return $Secret
}