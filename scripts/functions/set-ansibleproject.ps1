function Set-AnsibleProject {
    param (
        [Parameter(Mandatory = $true)][string]$DistroName
    )

    # Get the username of the default user in this distro
    $Username = (wsl -d $DistroName --exec whoami).Trim()

    # Check $Username is not null or empty
    if ([string]::IsNullOrEmpty($Username)) {
        Write-Host "The username from whoami is null or empty." -ForegroundColor Red
        exit 1
    }

    Write-Host "Copying the ansible directory to the distro..." -ForegroundColor Yellow
    $SourcePath = (Resolve-Path .\ansible).Path
    $DestinationPath = "\\wsl$\$DistroName\home\$Username\ansible"

    # Create the ansible directory if it doesn't exist
    if (-not (Test-Path -Path $DestinationPath)) {
        Write-Host "Creating directory $DestinationPath" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $DestinationPath
    }
    Copy-Item -Path $SourcePath\* -Destination $DestinationPath -Recurse -Force
}
