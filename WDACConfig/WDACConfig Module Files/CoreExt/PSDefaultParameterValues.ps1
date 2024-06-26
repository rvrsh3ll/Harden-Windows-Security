# $PSDefaultParameterValues only get read from scope where invocation occurs
# This is why this file is dot-sourced in every other component of the WDACConfig module at the beginning
# Main cmdlets that are also used within other main cmdlets are mentioned here too.
$PSDefaultParameterValues = @{
    'Invoke-WebRequest:HttpVersion'                               = '3.0'
    'Invoke-WebRequest:SslProtocol'                               = 'Tls12,Tls13'
    'Invoke-RestMethod:HttpVersion'                               = '3.0'
    'Invoke-RestMethod:SslProtocol'                               = 'Tls12,Tls13'
    'Import-Module:Verbose'                                       = $false
    'Remove-Module:Verbose'                                       = $false
    'Export-ModuleMember:Verbose'                                 = $false
    'Add-Type:Verbose'                                            = $false
    'Get-WinEvent:Verbose'                                        = $false
    'Test-Path:ErrorAction'                                       = 'SilentlyContinue'
    'Receive-CodeIntegrityLogs:Verbose'                           = $Verbose
    'Get-GlobalRootDrives:Verbose'                                = $Verbose
    'Get-SignTool:Verbose'                                        = $Verbose
    'Move-UserModeToKernelMode:Verbose'                           = $Verbose
    'Set-LogSize:Verbose'                                         = $Verbose
    'Test-FilePath:Verbose'                                       = $Verbose
    'Update-Self:Verbose'                                         = $Verbose
    'Write-ColorfulText:Verbose'                                  = $Verbose
    'New-SnapBackGuarantee:Verbose'                               = $Verbose
    'Compare-SecureStrings:Verbose'                               = $Verbose
    'Get-KernelModeDriversAudit:Verbose'                          = $Verbose
    'Copy-CiRules:Verbose'                                        = $Verbose
    'Get-TBSCertificate:Verbose'                                  = $Verbose
    'Get-SignerInfo:Verbose'                                      = $Verbose
    'Get-SignedFileCertificates:Verbose'                          = $Verbose
    'Get-FileRuleOutput:Verbose'                                  = $Verbose
    'Get-CertificateDetails:Verbose'                              = $Verbose
    'Get-NestedSignerSignature:Verbose'                           = $Verbose
    'Compare-SignerAndCertificate:Verbose'                        = $Verbose
    'Remove-SupplementalSigners:Verbose'                          = $Verbose
    'Get-ExtendedFileInfo:Verbose'                                = $Verbose
    'New-StagingArea:Verbose'                                     = $Verbose
    'Set-LogPropertiesVisibility:Verbose'                         = $Verbose
    'Test-KernelProtectedFiles:Verbose'                           = $Verbose
    'Set-CiRuleOptions:Verbose'                                   = $Verbose
    'New-WDACConfig:Verbose'                                      = $Verbose
    'Test-CiPolicy:Verbose'                                       = $Verbose
    'Get-CiFileHashes:Verbose'                                    = $Verbose
    'Edit-GUIDs:Verbose'                                          = $Verbose
    'Invoke-CiSigning:Verbose'                                    = $Verbose
    'Get-KernelModeDrivers:Verbose'                               = $Verbose
    'New-Macros:Verbose'                                          = $Verbose
    'Checkpoint-Macros:Verbose'                                   = $Verbose
    'Test-ECCSignedFiles:Verbose'                                 = $Verbose

    'Build-SignerAndHashObjects:Verbose'                          = $Verbose
    'Clear-CiPolicy_Semantic:Verbose'                             = $Verbose
    'Close-EmptyXmlNodes_Semantic:Verbose'                        = $Verbose
    'Compare-CorrelatedData:Verbose'                              = $Verbose
    'Merge-Signers_Semantic:Verbose'                              = $Verbose
    'New-FilePublisherLevelRules:Verbose'                         = $Verbose
    'New-HashLevelRules:Verbose'                                  = $Verbose
    'New-PublisherLevelRules:Verbose'                             = $Verbose
    'Optimize-MDECSVData:Verbose'                                 = $Verbose
    'Remove-AllowElements_Semantic:Verbose'                       = $Verbose
    'Remove-DuplicateAllowAndFileRuleRefElements_IDBased:Verbose' = $Verbose
    'Remove-DuplicateAllowedSignersAndCiSigners_IDBased:Verbose'  = $Verbose
    'Remove-DuplicateFileAttrib_IDBased:Verbose'                  = $Verbose
    'Remove-DuplicateFileAttrib_Semantic:Verbose'                 = $Verbose
    'Remove-DuplicateFileAttribRef_IDBased:Verbose'               = $Verbose
    'Remove-OrphanAllowedSignersAndCiSigners_IDBased:Verbose'     = $Verbose
    'Remove-UnreferencedFileRuleRefs:Verbose'                     = $Verbose
    'New-RootAndLeafCertificateLevelRules:Verbose'                = $Verbose

    'Build-SignerAndHashObjects:Debug'                            = $Debug
    'Clear-CiPolicy_Semantic:Debug'                               = $Debug
    'Close-EmptyXmlNodes_Semantic:Debug'                          = $Debug
    'Compare-CorrelatedData:Debug'                                = $Debug
    'Merge-Signers_Semantic:Debug'                                = $Debug
    'New-FilePublisherLevelRules:Debug'                           = $Debug
    'New-HashLevelRules:Debug'                                    = $Debug
    'New-PublisherLevelRules:Debug'                               = $Debug
    'Optimize-MDECSVData:Debug'                                   = $Debug
    'Remove-AllowElements_Semantic:Debug'                         = $Debug
    'Remove-DuplicateAllowAndFileRuleRefElements_IDBased:Debug'   = $Debug
    'Remove-DuplicateAllowedSignersAndCiSigners_IDBased:Debug'    = $Debug
    'Remove-DuplicateFileAttrib_IDBased:Debug'                    = $Debug
    'Remove-DuplicateFileAttrib_Semantic:Debug'                   = $Debug
    'Remove-DuplicateFileAttribRef_IDBased:Debug'                 = $Debug
    'Remove-OrphanAllowedSignersAndCiSigners_IDBased:Debug'       = $Debug
    'Remove-UnreferencedFileRuleRefs:Debug'                       = $Debug
    'New-RootAndLeafCertificateLevelRules:Debug'                  = $Debug
}

# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDAzK1tB95E9p7G
# mgKEiwn7AhKBK629LA/U7jGVjG5UfqCCB9AwggfMMIIFtKADAgECAhMeAAAABI80
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
# IgQgBI+FskP37PIC/Z3OnP4rje8orE+sEwnDQwuoPSTaeKUwDQYJKoZIhvcNAQEB
# BQAEggIAVrNTTDlWvBfiCp/snE5abxe6yEEcue8ILzjVDKr289eEaeKnXcOV8u3x
# F8V2JhHe5zo7gfpa40roWuE5OqtqEvaK1/hg+x7goK1hZ66kuOIQapq+be9JFmBX
# WQBrjwVOJbs2PEHxCr1XL9mE9jMzFtjn7k51ia979mB8/FqE8jbI48IEzsgCX3dN
# hK0wpRFLAGyneYF5bxo7s3vahHPWNQzSPEx4+pRfSXQKqAtDaecUbqBajXIsQkQd
# LrMPp24gbl9LXZUhd5JpvnNuGOqwU8He6wa08H2NG3M3L4xd3ffZRaUqt/Xo31xk
# s7M4IQwlZ9pcBgfg/ST6yfuhj8K9hD1fgpp3mBX33DuhuQuHihvcG0jcnBoE8iGE
# YRZMOEwOK3r0yfgmutO4E0ZDDbxegqGRdDm/bC4CjsHtfZt6vDWddYiVc9LINWqb
# K/BbOKzE4gPd71hLtkxWmmkfqHr3/sJe538H2g4ROjzlnM1cp4hl2S4gx6iApOrj
# rB152gX4L7iSlWRlr2fBkv/UJynx8lHjhZ8EUwCa5lUPqndJrxoPuinpQBXKE+1r
# WZajBAOqVBQJokDR2jlYPGO+/jAlYAky10pJrRlW4fTSjQ7YHi/7q4LRlS4oR10E
# JNHgTrUxaeIK31i49pFQXIrL/AuxrzxUAasAD9ogzfhDWA9g4Wo=
# SIG # End signature block
