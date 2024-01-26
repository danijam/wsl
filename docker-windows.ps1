# Set Error Action Preference to Stop
$ErrorActionPreference = "Stop"

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Please re-run this script as an Administrator."
    exit 1
}

# Exit script if C:\docker exists already
if (Test-Path C:\docker) {
    Write-Host "C:\docker already exists. Exiting script." -ForegroundColor Red
    Exit 1
}

# Create C:\docker directory
New-Item -Path C:\ -Name docker -ItemType Directory
Write-Host "Created C:\docker directory" -ForegroundColor Green

# download docker for windows zip file to C:\docker
$DownloadsPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
Write-Host "Preparing to download to users download directory: $downloadsPath" -ForegroundColor Green

Invoke-WebRequest -Uri "https://download.docker.com/win/static/stable/x86_64/docker-25.0.1.zip" -OutFile "$DownloadsPath\docker.zip"
Write-Host "Downloaded docker for windows zip file to C:\docker" -ForegroundColor Green

# extract docker for windows zip file to C:\docker
Expand-Archive $DownloadsPath\docker.zip -DestinationPath C:\docker
Write-Host "Extracted docker for windows zip file to C:\docker" -ForegroundColor Green

# Delete the docker archive from the Downloads directory
Remove-Item -Path $DownloadsPath\docker.zip
Write-Host "Deleted docker for windows zip file from $DownloadsPath" -ForegroundColor Green

# Fudge given the fact the download already contains a root directory called docker
# Copy the contents of C:\docker\docker to C:\docker
Copy-Item -Path C:\docker\docker\* -Destination C:\docker -Recurse
# Remove the C:\docker\docker directory
Remove-Item -Path C:\docker\docker -Recurse
Write-Host "Copied the contents of C:\docker\docker to C:\docker and removed C:\docker\docker" -ForegroundColor Green

# Add C:\docker to the system path
[Environment]::SetEnvironmentVariable("Path", "$($env:path);C:\docker", [System.EnvironmentVariableTarget]::Machine)
Write-Host "Added C:\docker to the system path" -ForegroundColor Green

# Reload the system and user path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
Write-Host "Reloaded the system and user path" -ForegroundColor Green

# Check if Docker is found on the path
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not found on the path. Exiting script." -ForegroundColor Red
    Exit 1
}

# Install the docker service
dockerd --register-service
Write-Host "Installed the docker service" -ForegroundColor Green

# Start the docker service
Start-Service docker
Write-Host "Started the docker service" -ForegroundColor Green

docker run hello-world
Write-Host "Ran the hello-world container" -ForegroundColor Green

