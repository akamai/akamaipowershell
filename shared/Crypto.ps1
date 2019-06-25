    #Function to generate HMAC SHA256 Base64
    Function Crypto ($secret, $message)
    {
        [byte[]] $keyByte = [System.Text.Encoding]::ASCII.GetBytes($secret)
        [byte[]] $messageBytes = [System.Text.Encoding]::ASCII.GetBytes($message)
        $hmac = new-object System.Security.Cryptography.HMACSHA256((,$keyByte))
        [byte[]] $hashmessage = $hmac.ComputeHash($messageBytes)
        $Crypt = [System.Convert]::ToBase64String($hashmessage)

        return $Crypt
    }