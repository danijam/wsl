# Set error action preference to stop
$ErrorActionPreference = "Stop"

# dot source load ALL functions from scripts/functions directory
$FunctionsPath = (Resolve-Path .\scripts\functions).Path
$Functions = Get-ChildItem -Path $FunctionsPath -Filter *.ps1
foreach ($Function in $Functions) {
    . $Function.FullName
}

# Check if the Ubuntu-22.04 distro is already installed
$DistroName = "Ubuntu-22.04"
$DistroExe = $DistroName.ToLower().Replace("-", "").Replace(".", "")

# Call the create distro function
Install-Distro -DistroName $DistroName -DistroExe $DistroExe

# Copy the ansible content to the distro
Set-AnsibleProject -DistroName $DistroName

# Execute the ansible playbook on the distro
Invoke-Playbook -DistroExe $DistroExe
