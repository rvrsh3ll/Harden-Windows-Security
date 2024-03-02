# Importing the $PSDefaultParameterValues to the current session, prior to everything else
. "$ModuleRootPath\CoreExt\PSDefaultParameterValues.ps1"

# Argument tab auto-completion for installed Appx package names
[System.Management.Automation.ScriptBlock]$ArgumentCompleterAppxPackageNames = {
    # Get the current command and the already bound parameters
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    # Get the app package names that match the word to complete
    Get-AppxPackage -Name *$wordToComplete* | ForEach-Object -Process {
        "`"$($_.Name)`""
    }
}

# Opens Folder picker GUI so that user can select folders to be processed
[System.Management.Automation.ScriptBlock]$ArgumentCompleterFolderPathsPicker = {
    # non-top-most, works better with window focus
    [System.Windows.Forms.FolderBrowserDialog]$Browser = New-Object -TypeName 'System.Windows.Forms.FolderBrowserDialog'
    $null = $Browser.ShowDialog()
    # Add quotes around the selected path
    return "`"$($Browser.SelectedPath)`""
}

# Opens File picker GUI so that user can select an .exe file - for SignTool.exe
[System.Management.Automation.ScriptBlock]$ArgumentCompleterExeFilePathsPicker = {
    # Create a new OpenFileDialog object
    [System.Windows.Forms.OpenFileDialog]$Dialog = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog'
    # Set the filter to show only executable files
    $Dialog.Filter = 'Executable files (*.exe)|*.exe'
    $Dialog.Title = 'Select the SignTool executable file'
    $Dialog.InitialDirectory = $UserConfigDir
    # Show the dialog and get the result
    [System.String]$Result = $Dialog.ShowDialog()
    # If the user clicked OK, return the selected file path
    if ($Result -eq 'OK') {
        return "`"$($Dialog.FileName)`""
    }
}

# Opens File picker GUI so that user can select a .cer file
[System.Management.Automation.ScriptBlock]$ArgumentCompleterCerFilePathsPicker = {
    # Create a new OpenFileDialog object
    [System.Windows.Forms.OpenFileDialog]$Dialog = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog'
    # Set the filter to show only certificate files
    $Dialog.Filter = 'Certificate files (*.cer)|*.cer'
    $Dialog.Title = 'Select a certificate file'
    $Dialog.InitialDirectory = $UserConfigDir
    # Show the dialog and get the result
    [System.String]$Result = $Dialog.ShowDialog()
    # If the user clicked OK, return the selected file path
    if ($Result -eq 'OK') {
        return "`"$($Dialog.FileName)`""
    }
}

# Opens File picker GUI so that user can select a .xml file
[System.Management.Automation.ScriptBlock]$ArgumentCompleterXmlFilePathsPicker = {
    # Create a new OpenFileDialog object
    [System.Windows.Forms.OpenFileDialog]$Dialog = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog'
    # Set the filter to show only XML files
    $Dialog.Filter = 'XML files (*.xml)|*.xml'
    $Dialog.Title = 'Select XML files'
    $Dialog.InitialDirectory = $UserConfigDir
    # Show the dialog and get the result
    [System.String]$Result = $Dialog.ShowDialog()
    # If the user clicked OK, return the selected file path
    if ($Result -eq 'OK') {
        return "`"$($Dialog.FileName)`""
    }
}

# Opens Folder picker GUI so that user can select folders to be processed
# WildCard file paths
[System.Management.Automation.ScriptBlock]$ArgumentCompleterFolderPathsPickerWildCards = {
    # non-top-most, works better with window focus
    [System.Windows.Forms.FolderBrowserDialog]$Browser = New-Object -TypeName 'System.Windows.Forms.FolderBrowserDialog'
    $null = $Browser.ShowDialog()
    # Add quotes around the selected path and a wildcard character at the end
    return "`"$($Browser.SelectedPath)\*`""
}

# Opens File picker GUI so that user can select any files
[System.Management.Automation.ScriptBlock]$ArgumentCompleterAnyFilePathsPicker = {
    # Create a new OpenFileDialog object
    [System.Windows.Forms.OpenFileDialog]$Dialog = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog'
    # Show the dialog and get the result
    [System.String]$Result = $Dialog.ShowDialog()
    # If the user clicked OK, return the selected file path
    if ($Result -eq 'OK') {
        return "`"$($Dialog.FileName)`""
    }
}

# Opens File picker GUI so that user can select multiple .xml files
[System.Management.Automation.ScriptBlock]$ArgumentCompleterMultipleXmlFilePathsPicker = {
    # Create a new OpenFileDialog object
    [System.Windows.Forms.OpenFileDialog]$Dialog = New-Object -TypeName 'System.Windows.Forms.OpenFileDialog'
    # Set the filter to show only XML files
    $Dialog.Filter = 'XML files (*.xml)|*.xml'
    # Set the MultiSelect property to true
    $Dialog.MultiSelect = $true
    $Dialog.ShowPreview = $true
    $Dialog.Title = 'Select WDAC Policy XML files'
    $Dialog.InitialDirectory = $UserConfigDir
    # Show the dialog and get the result
    [System.String]$Result = $Dialog.ShowDialog()
    # If the user clicked OK, return the selected file paths
    if ($Result -eq 'OK') {
        return "`"$($Dialog.FileNames -join '","')`""
    }
}


# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAB1DbIBf+Guv7X
# QkNqjwq3M17rFLiMLQYYqsWU71pl26CCB9AwggfMMIIFtKADAgECAhMeAAAABI80
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
# IgQg28CcrFgl6tFBp9lN1eMMm2PfI+8yTgUPdn0DLrMmOvswDQYJKoZIhvcNAQEB
# BQAEggIAfJgA7+sLh/hQa1PgwjRR5NH5ggEW9FPgUdXCG8qPy3u5en1Vdk6CDL39
# 4tbs3H8EB2mqAUfRaMQ5aKGZGMF34MEmAe4uGCA8g9PEdr/hMp1zSRDXEdvsJYEk
# Qr8IKlYoVdMjky4pxZfZmSlhLHOsGNsySPrWTekEryMqgbjVyfIQfCdkDvRDMwVQ
# FoqBTthPU7O8pOaSyLs9JtWP7N4XyUHtf2Rlquji+w5RlSYqpXdSsqGXiby0nCHj
# OVZuYnffN0SM05JUnfd9uksYvRpw7Ls6XuuK6uMP89XLuemR5EYv/PF8Xm2nUX1/
# xvjd/eH+sOhvR64Or+vxIE78GDFxDQ980uugL2NPAEqzpez4/nx4ws7q0D2G3lus
# hCuaIBNCLkDNaemWeKRgfspXFNYY8X/vuslu6cREjzFjgEspYpvt5Zm76oyXxhF1
# P4uGH1/gQcSgLVhweF8sflp2lnNFrmJdYZUrkg5sl8vjrNfqoS7wG59sf/S66Kph
# 6Aymqhbaee0XPT23KKRsijYmGKbVtCqlIxwvUoux62WTsKwzlNu+rH5eYNHOtStM
# UUkHT3zpOq3sq4lW1laweP2asb3hOLweQrWA08DxpqYAX/xXg/fxs34gsMFw84mu
# Oztr9lwyGFj4PzO+EQozOZntRgO5lfQERTXcZt1iDC1mrg8OFRc=
# SIG # End signature block
