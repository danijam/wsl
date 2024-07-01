function Install-Distro {
    param (
        [Parameter(Mandatory = $true)][string]$DistroName,
        [Parameter(Mandatory = $true)][string]$DistroExe
    )

    Write-Host "Checking if the '$($DistroName)' distro is already installed..." -ForegroundColor Yellow
    $WSLDistros = wsl --list --quiet | ForEach-Object { [PSCustomObject]@{ Name = $_ } }

    if ($WSLDistros | Where-Object { $_.Name -eq $DistroName }) {
        Write-Host "The $DistroName distro is already installed." -ForegroundColor Red
        return
    }

    # Install the distro
    Write-Host "Installing the $DistroName distro..." -ForegroundColor Yellow
    wsl --install -d $DistroName -n
    Write-Host "The $DistroName distro has been installed." -ForegroundColor Yellow

    # Execute the distrobution silent setup
    Write-Host "Executing the silent setup for the $DistroName distro..." -ForegroundColor Yellow
    & $DistroExe install --root

    Write-Host "Please enter a username and password for the distro:" -ForegroundColor Yellow
    $Username = Read-Host "Enter the username"
    $Password = Read-Host "Enter the password"

    # Create a user and set the password
    Write-Host "Creating the user '$Username' and setting the password..." -ForegroundColor Yellow
    & $DistroExe run useradd -m "$Username"
    & $DistroExe run "echo $($Username):$($Password) | chpasswd"

    # Set the default shell to bash for this user
    Write-Host "Setting the default shell to bash for the user '$Username'..." -ForegroundColor Yellow
    & $DistroExe run chsh -s /bin/bash "$Username"

    # Add the user to the sudo group and others
    Write-Host "Adding the user '$Username' to the sudo group and others..." -ForegroundColor Yellow
    & $DistroExe run "usermod -aG adm,cdrom,sudo,dip,plugdev $Username"

    # Add the user to the sudoers.d directory to allow sudo without password
    Write-Host "Adding the user '$Username' to the sudoers.d directory to allow sudo without password..." -ForegroundColor Yellow
    & $DistroExe run "echo '$Username ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/$Username"

    # Update apt cache
    Write-Host "Updating apt cache..." -ForegroundColor Yellow
    & $DistroExe run sudo apt update

    # install software-properties-common
    Write-Host "Installing software-properties-common..." -ForegroundColor Yellow
    & $DistroExe run sudo apt install software-properties-common -y

    # add ansible repository
    Write-Host "Adding ansible repository..." -ForegroundColor Yellow
    & $DistroExe run sudo apt-add-repository --yes --update ppa:ansible/ansible

    # Install ansible
    Write-Host "Installing ansible..." -ForegroundColor Yellow
    & $DistroExe run sudo apt install ansible -y

    # Copy the ansible 'hosts' file to the distro
    Write-Host "Copying the ansible 'hosts' file to the distro..." -ForegroundColor Yellow
    $SourcePath = (Resolve-Path .\ansible\inventory\hosts).Path
    $DestinationPath = "\\wsl$\$DistroName\etc\ansible\hosts"
    Write-Host "Copying from $SourcePath to $DestinationPath" -ForegroundColor Yellow
    Copy-Item -Path $SourcePath -Destination $DestinationPath -Force

    # Set the default user for the distro startup from wsl
    Write-Host "Setting the default user for the distro startup from wsl..." -ForegroundColor Yellow
    & $DistroExe config --default-user "$Username"
}
