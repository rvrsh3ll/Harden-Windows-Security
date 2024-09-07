using System;
using System.Diagnostics;

#nullable enable

namespace HardenWindowsSecurity
{
    public partial class ConfirmSystemComplianceMethods
    {
        /// <summary>
        /// Get the security group policies by utilizing the Secedit.exe
        /// </summary>
        public static void ExportSecurityPolicy()
        {
            // Assuming securityPolicyInfPath is defined in your environment
            string securityPolicyInfPath = HardenWindowsSecurity.GlobalVars.securityPolicyInfPath;
            string? systemDrive = Environment.GetEnvironmentVariable("SystemDrive");

            if (systemDrive == null)
            {
                // Handle the case where SystemDrive is not set
                throw new InvalidOperationException("SystemDrive environment variable is not set.");
            }

            // Create the process start info
            ProcessStartInfo processStartInfo = new ProcessStartInfo
            {
                FileName = $"{systemDrive}\\Windows\\System32\\Secedit.exe",
                Arguments = $"/export /cfg \"{securityPolicyInfPath}\"",
                // RedirectStandardOutput = false,
                RedirectStandardError = true, // Redirect the StandardError stream
                UseShellExecute = false,
                CreateNoWindow = true
            };

            // Start the process
            using (Process? process = Process.Start(processStartInfo))
            {
                if (process == null)
                {
                    throw new InvalidOperationException("Failed to start Secedit.exe process.");
                }

                // Read the output
                // string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();

                process.WaitForExit();

                if (!string.IsNullOrEmpty(error))
                {
                    HardenWindowsSecurity.Logger.LogMessage("Error: " + error, LogTypeIntel.Error);
                }
            }
        }
    }
}