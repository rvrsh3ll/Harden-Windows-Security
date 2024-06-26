Function Get-CIPolicySetting {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [Parameter(Mandatory = $true)][System.String]$Provider,
        [Parameter(Mandatory = $true)][System.String]$Key,
        [Parameter(Mandatory = $true)][System.String]$ValueName,
        [Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$SkipVersionCheck
    )
    Begin {
        $PSBoundParameters.Verbose.IsPresent ? ([System.Boolean]$Verbose = $true) : ([System.Boolean]$Verbose = $false) | Out-Null

        Write-Verbose -Message 'Importing the required sub-modules'
        Import-Module -FullyQualifiedName "$ModuleRootPath\Shared\Update-Self.psm1" -Force

        # if -SkipVersionCheck wasn't passed, run the updater
        if (-NOT $SkipVersionCheck) { Update-Self -InvocationStatement $MyInvocation.Statement }

        # Import the required C# type if it hasn't already been imported
        if (-NOT ('WDACConfig.WldpQuerySecurityPolicy' -as [System.Type]) ) {
            Add-Type -Path "$ModuleRootPath\C#\WldpQuerySecurityPolicy.cs"
        }
    }
    Process {
        try {
            # Create UNICODE_STRING structures
            $ProviderUS = [WDACConfig.WldpQuerySecurityPolicyWrapper]::InitUnicodeString($Provider)
            $KeyUS = [WDACConfig.WldpQuerySecurityPolicyWrapper]::InitUnicodeString($Key)
            $ValueNameUS = [WDACConfig.WldpQuerySecurityPolicyWrapper]::InitUnicodeString($ValueName)

            # Prepare output variables
            $ValueType = [WDACConfig.WLDP_SECURE_SETTING_VALUE_TYPE]::WldpNone
            $ValueSize = [System.UInt64]1024
            $Value = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($ValueSize)

            $Result = [WDACConfig.WldpQuerySecurityPolicyWrapper]::WldpQuerySecurityPolicy([ref]$ProviderUS, [ref]$KeyUS, [ref]$ValueNameUS, [ref]$ValueType, $Value, [ref]$ValueSize)

            $DecodedValue = $null

            if ($Result -eq 0) {
                switch ($ValueType) {
                    'WldpBoolean' {
                        $DecodedValue = [System.Runtime.InteropServices.Marshal]::ReadByte($Value) -ne 0
                    }
                    'WldpString' {
                        $DecodedValue = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Value)
                    }
                    'WldpInteger' {
                        $DecodedValue = [System.Runtime.InteropServices.Marshal]::ReadInt32($Value)
                    }
                }
            }

            Return [PSCustomObject]@{
                Value      = $DecodedValue
                ValueType  = $ValueType
                ValueSize  = $ValueSize
                Status     = $Result -eq 0 ? $true : $false
                StatusCode = $Result
            }
        }
        finally {
            # Clean up
            [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ProviderUS.Buffer)
            [System.Runtime.InteropServices.Marshal]::FreeHGlobal($KeyUS.Buffer)
            [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ValueNameUS.Buffer)
            [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Value)
        }
    }
    <#
    .SYNOPSIS
        Gets the secure settings value from the deployed CI policies.
        If there is a policy with the same provider, key and value then it returns the following details:

        Value = The actual value of the string
        ValueType = The type of setting: WldpString, WldpInteger or WldpBoolean
        ValueSize = the size of the returned value
        Status = True/False depending on whether the setting exists on the system or not
        StatusCode = 0 if the value exists on the system, non-zero if it doesn't.
    .DESCRIPTION
        Please use the following resources for more information

        https://learn.microsoft.com/en-us/powershell/module/configci/set-cipolicysetting
        https://learn.microsoft.com/en-us/windows/security/application-security/application-control/windows-defender-application-control/design/understanding-wdac-policy-settings
    .LINK
        https://github.com/HotCakeX/Harden-Windows-Security/wiki/Get-CIPolicySetting
    .INPUTS
        System.String
    .OUTPUTS
        PSCustomObject
    .PARAMETER Provider
        The provider of the secure setting
    .PARAMETER Key
        The key of the secure setting
    .PARAMETER ValueName
        The name of the secure setting
    .PARAMETER SkipVersionCheck
        If this switch is present, the cmdlet will skip the version check
    .EXAMPLE
        Creating the secure settings in a Code Integrity policy

        Set-CIPolicySetting -FilePath 'Policy.xml' -Provider 'WDACConfig' -ValueType 'Boolean' -Value '1' -ValueName 'IsUserModePolicy' -Key '{4a981f19-1f7f-4167-b4a6-915765e34fd6}'
    .EXAMPLE
        Creating the secure settings in a Code Integrity policy

        Set-CIPolicySetting -FilePath 'Policy.xml' -Provider 'SomeProvider' -ValueType 'String' -Value 'HotCakeX' -ValueName 'Author' -Key '{495e96a3-f6e0-4e7e-bf48-e8b6085b824a}'
    .EXAMPLE
        Creating the secure settings in a Code Integrity policy

        Set-CIPolicySetting -FilePath 'Policy.xml' -Provider 'Provider2' -ValueType 'DWord' -Value '66' -ValueName 'Role' -Key '{741b1fcf-e1ce-49e4-a274-5c367b46b00c}'
    .EXAMPLE
        Using the Get-CIPolicySetting cmdlet to query the secure strings among the deployed policies on the system.

        Get-CIPolicySetting -Provider 'WDACConfig' -Key '{4a981f19-1f7f-4167-b4a6-915765e34fd6}' -ValueName 'IsUserModePolicy'
    .EXAMPLE
        Using the Get-CIPolicySetting cmdlet to query the secure strings among the deployed policies on the system.

        Get-CIPolicySetting -Provider 'SomeProvider' -ValueName 'Author' -Key '{495e96a3-f6e0-4e7e-bf48-e8b6085b824a}'
    .EXAMPLE
        Using the Get-CIPolicySetting cmdlet to query the secure strings among the deployed policies on the system.

        Get-CIPolicySetting -Provider 'Provider2' -ValueName 'Role' -Key '{741b1fcf-e1ce-49e4-a274-5c367b46b00c}'
    .NOTES
        Note-1
        Since these settings are secured by Secure Boot, in order to successfully query these settings, you might need to restart once after deploying the CI Policy on the system.

        Note-2
        DWord value is the same as integer or WldpInteger

        Note-3
        In order to set a Boolean value using the Set-CIPolicySetting cmdlet, you need to use 1 for True or 0 for False, that will create a valid policy XML file that is compliant with the CI Policy Schema.
        #>
}

# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBqeuOQzMwf3N4x
# tVif7flsFw/n2ThI/hKZ03ALESW2eaCCB9AwggfMMIIFtKADAgECAhMeAAAABI80
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
# IgQg0t/iLiHnYrOreMYSx7AJJjFNUOeV2pPOY1KRQQDhHUowDQYJKoZIhvcNAQEB
# BQAEggIAaLka48k6BlwDNha3eWd3zlpsKiqsPSyFQJi/8bzZmSE4X9qgkVlKQaJd
# mrMvKd//pSQxbRKvK8TCMGwjhvoYBvJcke4YXEWXhda2KXRRggNSj/1lhye98bqv
# /JNzvPJmecvr0qJy1iMaX9LHcO7xnerw2iB1IFLaUIBKvS7VMtBBLWcn1xjIIICf
# GRK50mgpzVJOgY+e3xeXKFwsRGZ2ijQ3/R3bOWLEUw/r+Ue4MTLgZEKBQT11zgDa
# rmjmZRndZ26MrdF6GujMtDq2iL4Ihq/Gl0Gov2frqqa9DZXQRD9zMftoTWCc/H2u
# OXSDKfXUSWQZ+zKZlPTGvbfmV/w5gJctr3+V5mx+isC70GSr1H7RQpwql08M4/zg
# RPChnKU971tRueqwNbOvWLKH4y3oAVAZeqjV/4RaoTgpdIe2YT7nvpaMbYSwmvKV
# JiQrS4nFNIy498j1/Q+L5t8kGb1V3huh3Fe70yJcn3CGnxSA3DgkYy/Jjfubh7xy
# j2h3C6CQV2Imuw+BWTY831AzjkVp76h5CUSEw8UETNGXk5xAi9Oj0se1IT86FuRV
# te3EEPA1M5BnqpJiAlbktAQPZMXlXcjo4ZmeZOR5xvmkJqr41BaENEAmgZuvQvJ/
# xRM/n4AD5B9McJRPFwuEV/IuBCNPcUXXVrhwUqahara+ZsMSl3o=
# SIG # End signature block
