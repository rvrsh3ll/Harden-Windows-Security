Function Test-FilePath {
    <#
    .SYNOPSIS
        Function that takes 2 arrays, one contains file paths and the other contains folder paths. It checks them and returns the unique file paths
        that are not in any of the folder paths. Performs this check recursively too so works if a filepath is in a sub-directory of a folder path.
    .NOTES
        It works even if the file paths or folder paths are non-existent/deleted, but they still need to be valid file/folder paths.
    .INPUTS
        System.IO.DirectoryInfo[]
        System.IO.FileInfo[]
    .OUTPUTS
        System.IO.FileInfo[]
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo[]])]
    param (
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -IsValid })]
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$FilePath,

        [ValidateScript({ Test-Path -Path $_ -PathType Container -IsValid })]
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$DirectoryPath
    )
    Begin {
        . "$ModuleRootPath\CoreExt\PSDefaultParameterValues.ps1"

        [System.IO.FileInfo[]]$Output = @()
    }
    Process {
        # Loop through each file path
        foreach ($File in $FilePath) {

            # Initialize a variable to store the result
            [System.Boolean]$Result = $false

            # Loop through each directory path
            foreach ($Directory in $DirectoryPath) {
                # Check if the file path starts with the directory path
                if ($File -like "$Directory\*") {
                    # The file is inside the directory or its sub-directories
                    $Result = $true
                    break # Exit the inner loop
                }
            }
            # Output the file path if it is not inside any of the directory paths
            if (-NOT $Result) {
                $Output += $File
            }
        }
    }
    End {
        Return ($Output | Select-Object -Unique)
    }
}
Export-ModuleMember -Function 'Test-FilePath'

# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDkCoNu18a8hf1D
# NyGqN7ZPAho6p11nQjrKraYECoKFKqCCB9AwggfMMIIFtKADAgECAhMeAAAABI80
# LDQz/68TAAAAAAAEMA0GCSqGSIb3DQEBDQUAME8xEzARBgoJkiaJk/IsZAEZFgNj
# b20xIjAgBgoJkiaJk/IsZAEZFhJIT1RDQUtFWC1DQS1Eb21haW4xFDASBgNVBAMT
# C0hPVENBS0VYLUNBMCAXDTIzMTIyNzExMjkyOVoYDzIyMDgxMTEyMTEyOTI5WjB5
# MQswCQYDVQQGEwJVSzEeMBwGA1UEAxMVSG90Q2FrZVggQ29kZSBTaWduaW5nMSMw
# IQYJKoZIhvcNAQkBFhRob3RjYWtleEBvdXRsb29rLmNvbTElMCMGCSqGSIb3DQEJ
# ARYWU3B5bmV0Z2lybEBvdXRsb29rLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKb1BJzTrpu1ERiwr7ivp0UuJ1GmNmmZ65eckLpGSF+2r22+7Tgm
# pEifj9NhPw0X60F9HhdSM+2XeuikmaNMvq8XRDUFoenv9P1ZU1wli5WTKHJ5ayDW
# k2NP22G9IPRnIpizkHkQnCwctx0AFJx1qvvd+EFlG6ihM0fKGG+DwMaFqsKCGh+M
# rb1bKKtY7UEnEVAsVi7KYGkkH+ukhyFUAdUbh/3ZjO0xWPYpkf/1ldvGes6pjK6P
# US2PHbe6ukiupqYYG3I5Ad0e20uQfZbz9vMSTiwslLhmsST0XAesEvi+SJYz2xAQ
# x2O4n/PxMRxZ3m5Q0WQxLTGFGjB2Bl+B+QPBzbpwb9JC77zgA8J2ncP2biEguSRJ
# e56Ezx6YpSoRv4d1jS3tpRL+ZFm8yv6We+hodE++0tLsfpUq42Guy3MrGQ2kTIRo
# 7TGLOLpayR8tYmnF0XEHaBiVl7u/Szr7kmOe/CfRG8IZl6UX+/66OqZeyJ12Q3m2
# fe7ZWnpWT5sVp2sJmiuGb3atFXBWKcwNumNuy4JecjQE+7NF8rfIv94NxbBV/WSM
# pKf6Yv9OgzkjY1nRdIS1FBHa88RR55+7Ikh4FIGPBTAibiCEJMc79+b8cdsQGOo4
# ymgbKjGeoRNjtegZ7XE/3TUywBBFMf8NfcjF8REs/HIl7u2RHwRaUTJdAgMBAAGj
# ggJzMIICbzA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiG7sUghM++I4HxhQSF
# hqV1htyhDXuG5sF2wOlDAgFkAgEIMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYB
# BQUHAwMwHQYDVR0OBBYEFOlnnQDHNUpYoPqECFP6JAqGDFM6MB8GA1UdIwQYMBaA
# FICT0Mhz5MfqMIi7Xax90DRKYJLSMIHUBgNVHR8EgcwwgckwgcaggcOggcCGgb1s
# ZGFwOi8vL0NOPUhPVENBS0VYLUNBLENOPUhvdENha2VYLENOPUNEUCxDTj1QdWJs
# aWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9u
# LERDPU5vbkV4aXN0ZW50RG9tYWluLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9jYXRp
# b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgccG
# CCsGAQUFBwEBBIG6MIG3MIG0BggrBgEFBQcwAoaBp2xkYXA6Ly8vQ049SE9UQ0FL
# RVgtQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZp
# Y2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Tm9uRXhpc3RlbnREb21haW4sREM9Y29t
# P2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0
# aG9yaXR5MA0GCSqGSIb3DQEBDQUAA4ICAQA7JI76Ixy113wNjiJmJmPKfnn7brVI
# IyA3ZudXCheqWTYPyYnwzhCSzKJLejGNAsMlXwoYgXQBBmMiSI4Zv4UhTNc4Umqx
# pZSpqV+3FRFQHOG/X6NMHuFa2z7T2pdj+QJuH5TgPayKAJc+Kbg4C7edL6YoePRu
# HoEhoRffiabEP/yDtZWMa6WFqBsfgiLMlo7DfuhRJ0eRqvJ6+czOVU2bxvESMQVo
# bvFTNDlEcUzBM7QxbnsDyGpoJZTx6M3cUkEazuliPAw3IW1vJn8SR1jFBukKcjWn
# aau+/BE9w77GFz1RbIfH3hJ/CUA0wCavxWcbAHz1YoPTAz6EKjIc5PcHpDO+n8Fh
# t3ULwVjWPMoZzU589IXi+2Ol0IUWAdoQJr/Llhub3SNKZ3LlMUPNt+tXAs/vcUl0
# 7+Dp5FpUARE2gMYA/XxfU9T6Q3pX3/NRP/ojO9m0JrKv/KMc9sCGmV9sDygCOosU
# 5yGS4Ze/DJw6QR7xT9lMiWsfgL96Qcw4lfu1+5iLr0dnDFsGowGTKPGI0EvzK7H+
# DuFRg+Fyhn40dOUl8fVDqYHuZJRoWJxCsyobVkrX4rA6xUTswl7xYPYWz88WZDoY
# gI8AwuRkzJyUEA07IYtsbFCYrcUzIHME4uf8jsJhCmb0va1G2WrWuyasv3K/G8Nn
# f60MsDbDH1mLtzGCAxgwggMUAgEBMGYwTzETMBEGCgmSJomT8ixkARkWA2NvbTEi
# MCAGCgmSJomT8ixkARkWEkhPVENBS0VYLUNBLURvbWFpbjEUMBIGA1UEAxMLSE9U
# Q0FLRVgtQ0ECEx4AAAAEjzQsNDP/rxMAAAAAAAQwDQYJYIZIAWUDBAIBBQCggYQw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
# IgQgwE542d0nnWEQ3nx1P03lGX2S2WWepXdbYXsmIroJmKAwDQYJKoZIhvcNAQEB
# BQAEggIAL3C97Eg9TquSmK33GTCmr9N2OSInCup3rjVDDEKwBSNJvOWSh3IXvaLD
# K56Lt2SyJatAdQ786E3doTIB10GxHXzfviypuYlibUadV924RwVqUNkDt+K8tDsv
# YquSA2mBWJBcD5m+VoEoCSaet/JJxT90om9UN1w2Zpvh1IUB6xOuC9jjtegMnXpJ
# KR95ecc44sRinm1KMGfykLaA5xQ88pSvgMSNe26Pm6SI7cLV5Y4eGxlQNC7w26IZ
# mZnU8maQFH/g+1i/ulgzv7Y++/win0C1RmK6fCx4ArJKQBDFz42O/gGTa8Nudlc5
# M8Eq9UtzCmgTm2nPINL/D89K4BSWAn+FvtystFGEnJUxu5sbKFLCVkxjp9jGBxKC
# fEXe9x8GTKRJh1J/oqcIP9XTb9CxJFWxQTiqcqHk9eLuFjpEUm7D7yUO2+c2C91s
# JPfWrk6bGos4lrLywqaoPWQv+9A8mICcMRiDMmipWqjmenNG3Vx5g19DslUlzTbb
# 3jz1ldxfOTOUqSir47e6H1bmzZuqIxgGrfCBno8HgSm82RtDIfyIV8BPxhxV7BYM
# NPMGL8TYP7vtJKHOWScoL/acB65zw23kZQxwQ1tgyV61ptOLAye0+wGhckhpWg5J
# VDG86mAi3IM60lJKh0v+0iZ7aUHZ5pgqHdTo78VMstxaYlrihNg=
# SIG # End signature block
