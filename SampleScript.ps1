# This is a sample script to test the Latest Version Check
[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [Switch]
    $SkipVersionCheck
)
# Get the full script path
$ScriptFullPath = $MyInvocation.MyCommand.Path
# Get Script Location
$ScriptLocation = Split-Path -Parent $ScriptFullPath
# Set the Script version
$ScriptVersion = "1.0"

Write-Host "Starting the script"
$moduleInfo = Import-Module .\LatestVersionCheck.psd1

$gitHubLatestVersionParameters = @{
    currentVersion = $ScriptVersion;
    repositoryName = "AssafMiron/CheckLatestVersion";
    scriptVersionFileName = "SampleScript.ps1";
    sourceFolderPath = $ScriptLocation;
    
    # More parameters that can be used
    # repositoryFolderPath = "CYBRHardeningCheck";
    # branch = "main";
    # versionPattern = "ScriptVersion";
}

If(! $SkipVersionCheck)
{
	try{
        # For the sample we will send a lower script version
        $gitHubLatestVersionParameters.currentVersion = "0.5";
        Write-Host "Current script version $($gitHubLatestVersionParameters.currentVersion)"
        $isLatestVersion = $(Test-GitHubLatestVersion @gitHubLatestVersionParameters)
		If($isLatestVersion -eq $false)
		{
            # Skip the version check so we don't get into a loop
            $command = "$ScriptFullPath -SkipVersionCheck:$true"
			# Run the updated script
			$scriptPathAndArgs = "powershell.exe -NoLogo -File `"$ScriptFullPath`" -SkipVersionCheck"
			# $scriptPathAndArgs = "powershell.exe -NoLogo -File `"$command`" "
			Write-Host "Finished Updating, relaunching the script"
			Invoke-Expression $scriptPathAndArgs
			# Exit the current script
			return
		}
	} catch {
		Write-Error "Error checking for latest version." -Exception $_.Exception
	}
}

Write-Host "This is the current script version $ScriptVersion, checking script version from GitHub"
# Revert the current version to the script version
$gitHubLatestVersionParameters.currentVersion = $ScriptVersion
If($(Test-GitHubLatestVersion @gitHubLatestVersionParameters -TestOnly))
{
    Write-Host "This is the latest script version"
}
Remove-Module $moduleInfo
Write-Host "Script ended"

