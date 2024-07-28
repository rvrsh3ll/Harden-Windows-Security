using System;
using Microsoft.Win32;
using System.Globalization;

namespace WDACConfig
{
    // prepares the environment. It also runs commands that would otherwise run in the default constructor for the GlobalVars Class
    public class Initializer
    {
        /// These are the codes that were present in GlobalVar class's default constructor but defining them as a separate method an allows any errors thrown in them to be properly displayed in PowerShell instead of showing an error occurred in the default constructor of a class
        public static void Initialize()
        {
            using (RegistryKey key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows NT\CurrentVersion"))
            {
                if (key != null)
                {
                    object ubrValue = key.GetValue("UBR");
                    if (ubrValue != null && int.TryParse(ubrValue.ToString(), out int ubr))
                    {
                        WDACConfig.GlobalVars.UBR = ubr;
                    }
                    else
                    {
                        throw new InvalidOperationException("The UBR value could not be retrieved from the registry: HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion");
                    }
                }
                else
                {
                    throw new InvalidOperationException("The UBR key does not exist in the registry path: HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion");
                }
            }

            // Concatenate OSBuildNumber and UBR to form the final string
            WDACConfig.GlobalVars.FullOSBuild = $"{WDACConfig.GlobalVars.OSBuildNumber}.{WDACConfig.GlobalVars.UBR}";

            // Convert the FullOSBuild and RequiredBuild strings to decimals so that we can compare them
            if (!TryParseBuildVersion(buildVersion: WDACConfig.GlobalVars.FullOSBuild, result: out decimal fullOSBuild))
            {
                throw new FormatException("The OS build version strings are not in a correct format.");
            }

            // Make sure the current OS build is equal or greater than the required build number
            if (!(fullOSBuild >= WDACConfig.GlobalVars.Requiredbuild))
            {
                throw new PlatformNotSupportedException($"You are not using the latest build of the Windows OS. A minimum build of {WDACConfig.GlobalVars.Requiredbuild} is required but your OS build is {fullOSBuild}\nPlease go to Windows Update to install the updates and then try again.");
            }
        }


        // This method gracefully parses the OS build version strings to decimals
        // and performs this in a culture-independent way
        // in languages such as Swedish where the decimal separator is , instead of .
        // this will work properly
        // in PowerShell we can see the separator by running: (Get-Culture).NumberFormat.NumberDecimalSeparator
        private static bool TryParseBuildVersion(string buildVersion, out decimal result)
        {
            // Use CultureInfo.InvariantCulture for parsing
            return Decimal.TryParse(buildVersion, NumberStyles.Number, CultureInfo.InvariantCulture, out result);
        }
    }
}
