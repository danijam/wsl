# Set error action preference to stop
$ErrorActionPreference = "Stop"

# Check if the Ubuntu-22.04 distro is already installed
$DistroName = "Ubuntu-22.04"

Write-Host "Checking if the '$($DistroName)' distro is already installed..." -ForegroundColor Yellow
$WSLDistros = wsl --list --quiet | ForEach-Object { [PSCustomObject]@{ Name = $_ } }

if ($WSLDistros | Where-Object { $_.Name -eq $DistroName }) {
    Write-Host "The $DistroName distro is already installed. Preparing to delete" -ForegroundColor Yellow
    wsl --unregister $DistroName
}
else {
    Write-Host "The $DistroName distro is not installed. Exiting..." -ForegroundColor Red
    exit 1
}
