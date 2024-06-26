function Remove-AllowElements_Semantic {
    <#
    .SYNOPSIS
        A high performance function that removes duplicate <Allow> elements from the <FileRules> node and their corresponding <FileRuleRef> elements from the <FileRulesRef> node of the <ProductSigners> node under each <SigningScenario> node
        The criteria for removing duplicates is the Hash attribute of the <Allow> elements.
        If there are multiple <Allow> elements with the same Hash, the function keeps the first element and removes the rest.
        The function only considers <Allow> elements that are part of the same <SigningScenario> node and have the same Hash attribute as duplicates.
        After the function completes its operation, the XML file will not have any duplicate <Allow> elements, duplicate <FileRuleRef> elements or any orphan <FileRuleRef> elements.
        This is according to the CI Schema.
    .PARAMETER Path
        The path to the XML file to be modified
    .INPUTS
        System.IO.FileInfo
    .OUTPUTS
        System.Void
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$Path
    )
    Begin {
        . "$ModuleRootPath\CoreExt\PSDefaultParameterValues.ps1"

        # Load the XML file
        [System.Xml.XmlDocument]$Xml = Get-Content -Path $Path

        # Define the namespace manager
        [System.Xml.XmlNamespaceManager]$Ns = New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList $Xml.NameTable
        $Ns.AddNamespace('ns', 'urn:schemas-microsoft-com:sipolicy')

        # Get all of the <Allow> elements inside the <FileRules> node
        [System.Xml.XmlNodeList]$AllowElements = $Xml.SelectNodes('//ns:FileRules//ns:Allow', $Ns)

        # Get the <FileRules> node
        [System.Xml.XmlElement[]]$FileRulesNode = $Xml.SelectSingleNode('//ns:FileRules', $Ns)

        # Find the FileRulesRef Nodes inside the ProductSigners Nodes of each Signing Scenario
        [System.Xml.XmlNodeList]$UMCI_SigningScenario_ProductSigners_FileRulesRef_Node = $Xml.SelectNodes('//ns:SigningScenarios/ns:SigningScenario[@Value="12"]/ns:ProductSigners/ns:FileRulesRef/ns:FileRuleRef', $Ns)
        [System.Xml.XmlNodeList]$KMCI_SigningScenario_ProductSigners_FileRulesRef_Node = $Xml.SelectNodes('//ns:SigningScenarios/ns:SigningScenario[@Value="131"]/ns:ProductSigners/ns:FileRulesRef/ns:FileRuleRef', $Ns)

        [System.Xml.XmlNodeList]$UserModeFileRefs = $Xml.SelectNodes('//ns:SigningScenarios/ns:SigningScenario[@Value="12"]/ns:ProductSigners/ns:FileRulesRef', $Ns)
        [System.Xml.XmlNodeList]$KernelModeFileRefs = $Xml.SelectNodes('//ns:SigningScenarios/ns:SigningScenario[@Value="131"]/ns:ProductSigners/ns:FileRulesRef', $Ns)

        # Save the IDs of the FileRuleRef elements that are part of the User-Mode and Kernel-Mode signing scenarios as HashSets
        # These are unique because HashSets don't support duplicate values
        $UserMode_FileRulesRefIDs_HashSet = [System.Collections.Generic.HashSet[System.String]]$UMCI_SigningScenario_ProductSigners_FileRulesRef_Node.RuleID
        $KernelMode_FileRulesRefIDs_HashSet = [System.Collections.Generic.HashSet[System.String]]$KMCI_SigningScenario_ProductSigners_FileRulesRef_Node.RuleID

        # 2 Hashtables for User and Kernel mode <Allow> elements and their corresponding FileRuleRef elements together
        [System.Collections.Hashtable]$KernelModeHashTable = @{}
        [System.Collections.Hashtable]$UserModeHashTable = @{}

        # 2 Arrays to save the <Allow> elements of User and Kernel modes
        [System.Xml.XmlElement[]]$ArrayOfUserModes = @()
        [System.Xml.XmlElement[]]$ArrayOfKernelModes = @()
    }

    Process {

        # Separating User-Mode and Kernel-Mode <Allow> elements
        foreach ($AllowElement in $AllowElements) {

            # Check if the User-Mode <FileRulesRef> node has any elements
            # And then check if the current <Allow> element ID is part of the User-Mode <FileRulesRef> node
            if (($Null -ne $UserMode_FileRulesRefIDs_HashSet) -and ($UserMode_FileRulesRefIDs_HashSet.Contains($AllowElement.ID))) {
                $ArrayOfUserModes += $AllowElement
            }

            # Check if the Kernel-Mode <FileRulesRef> node has any elements
            # And then check if the current <Allow> element ID is part of the Kernel-Mode <FileRulesRef> node
            elseif (($Null -ne $KernelMode_FileRulesRefIDs_HashSet) -and ($KernelMode_FileRulesRefIDs_HashSet.Contains($AllowElement.ID))) {
                $ArrayOfKernelModes += $AllowElement
            }
            else {
                Write-Warning -Message "Remove-AllowElements_Semantic: The Allow element with ID $($AllowElement.ID) is not part of any Signing Scenario. It will be ignored."
            }
        }

        # Grouping the <Allow> elements by their Hash value, uniquely, So SHA1 and SHA256 hashes
        [System.Xml.XmlElement[]]$GroupsUserModes = $ArrayOfUserModes | Group-Object -Property Hash | ForEach-Object -Process { $_.Group[0] }
        [System.Xml.XmlElement[]]$GroupsKernelModes = $ArrayOfKernelModes | Group-Object -Property Hash | ForEach-Object -Process { $_.Group[0] }

        # Adding the User-Mode <Allow> elements and their corresponding <FileRuleRef> elements to the Hashtables
        foreach ($UserModeAllowElement in $GroupsUserModes) {

            # If the current <Allow> element ID is not already in the KernelModeHashTable, add it
            if (-NOT $UserModeHashTable.ContainsKey($UserModeAllowElement)) {

                # The key is the <Allow> element, the value is all of the <FileRuleRef> elements with the same RuleID as the Allow element's ID, without deduplication at this point
                # Cloning is necessary because after clearing the nodes, we would lose the reference to the original elements in those nodes
                $UserModeHashTable[@($UserModeAllowElement.Clone())] = @($Xml.SelectNodes("//ns:SigningScenarios/ns:SigningScenario[@Value='12']/ns:ProductSigners/ns:FileRulesRef/ns:FileRuleRef[@RuleID=`"$($UserModeAllowElement.ID)`"]", $Ns).Clone())
            }
        }

        # Adding the Kernel-Mode <Allow> elements and their corresponding <FileRuleRef> elements to the Hashtables
        foreach ($KernelModeAllowElement in $GroupsKernelModes) {

            # If the current <Allow> element ID is not already in the KernelModeHashTable, add it
            if (-NOT $KernelModeHashTable.ContainsKey($KernelModeAllowElement)) {

                # The key is the <Allow> element, the value is all of the <FileRuleRef> elements with the same RuleID as the Allow element's ID, without deduplication at this point
                $KernelModeHashTable[@($KernelModeAllowElement.Clone())] = @($Xml.SelectNodes("//ns:SigningScenarios/ns:SigningScenario[@Value='131']/ns:ProductSigners/ns:FileRulesRef/ns:FileRuleRef[@RuleID=`"$($KernelModeAllowElement.ID)`"]", $Ns).Clone())
            }
        }

        # Select and remove all <Allow> elements from <FileRules>
        [System.Xml.XmlNodeList]$AllowNodes = $Xml.SelectNodes('//ns:FileRules/ns:Allow', $NS)
        foreach ($Node in $AllowNodes) {
            [System.Void]$Node.ParentNode.RemoveChild($Node)
        }

        # Select and remove all <FileRuleRef> elements from <FileRulesRef> in each signing scenario
        [System.Xml.XmlNodeList]$SigningScenarios = $Xml.SelectNodes('//ns:SigningScenario/ns:ProductSigners/ns:FileRulesRef', $NS)
        foreach ($Scenario in $SigningScenarios) {
            [System.Xml.XmlNodeList]$FileRuleRefs = $Scenario.SelectNodes('ns:FileRuleRef', $NS)
            foreach ($FileRuleRef in $FileRuleRefs) {
                [System.Void]$FileRuleRef.ParentNode.RemoveChild($FileRuleRef)
            }
        }

        # Add Unique <Allow> elements and their corresponding <FileRuleRef> elements back to the XML file for the Kernel-Mode files
        foreach ($Group in $UserModeHashTable.GetEnumerator()) {
            # Add the unique <Allow> element
            [System.Void]$FileRulesNode.AppendChild($Group.Key[0])
            # Add the unique <FileRuleRef> element, using [0] index because the key is an array even though it only has 1 element
            [System.Void]$UserModeFileRefs.AppendChild(($Group.Value.GetEnumerator() | Group-Object -Property RuleID | ForEach-Object -Process { $_.Group[0] }))
        }

        # Add Unique <Allow> elements and their corresponding <FileRuleRef> elements back to the XML file for the Kernel-Mode files
        foreach ($Group in $KernelModeHashTable.GetEnumerator()) {
            # Add the unique <Allow> element, using [0] index because the key is an array even though it only has 1 element
            [System.Void]$FileRulesNode.AppendChild($Group.Key[0])
            # Add the unique <FileRuleRef> element
            [System.Void]$KernelModeFileRefs.AppendChild(($Group.Value.GetEnumerator() | Group-Object -Property RuleID | ForEach-Object -Process { $_.Group[0] }))
        }
    }

    End {
        # Save the modified XML file
        $Xml.Save($Path)
    }
}
Export-ModuleMember -Function 'Remove-AllowElements_Semantic'

# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBe1D4r9QzQJJcA
# pCRIhZ3h/BvP+7pP52vRZQEHU8xsKKCCB9AwggfMMIIFtKADAgECAhMeAAAABI80
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
# IgQguoYqQF7IcP3HyKoCmkVPV+q9/fh7aRmwECFakdeT6B8wDQYJKoZIhvcNAQEB
# BQAEggIAldyYHl26rXBs5rxxdJhOosx9QUf+N7sxqfLS8uZCD6rpktjzgl4Rn/99
# 2uNaJldDUY6HWd69EidvsM7LAb+we1dH1lvZjByGCXGr4ssjbasKFFnXHsYnAn/Q
# dt0K7SyXUpACzt/By1zcIVVq8hDEQ5kq41Jg1GAyZqTe8qbyQoc+I/5850HgRtCy
# dfz5xBO/jBFKBsvOaU1/KL3ORVOGyhp6ZSD3MqMI2lGLCKg6HlFWrv+8f+zw9qya
# 7JxC5vRh1k9PjGx2Kt0fyAi34f0+HBOZvJte4wi5TzdieLHfYYeR3M7wLGyFhR9Q
# kdVB17cbw0NLNbE7eowom8zu5CmJHCQ5qNqiODWf1RKErjRQx0dHHfYcDwp9M6n7
# m69cSwk3L+NkPlCCHSP7xabPISY8Nt4JpBCAfg8vyeD6NnYr1f6qU4ShsynNHKnO
# 3Lpeiu/Vz7qfVziGmVGpvobRqzpTKko/DFdCFEvOZIGIWFXCoEaEa6TW9SnvaQx1
# WLQnaJBMeCgQu40usUYS5+jI5O2PCZoQT+Pc96BK6DxLhRKE/tMpFFabsJtiGgwY
# WVUcXgd04+OGjotcbzaNL99uUSIjCkWqXUdRmPvWEpmAkw5asCMihsSGdL2nXDCg
# 4NBvwn57NiSXxMfZRL0+/NHUPmV04WlI9xtYy6V7SrxCqNDf3oM=
# SIG # End signature block
