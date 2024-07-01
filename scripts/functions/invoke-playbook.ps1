function Invoke-Playbook {
    param (
        [Parameter(Mandatory = $true)][string]$DistroExe
    )

    # Get Username from WSL distro
    $Username = & $DistroExe run whoami

    # Execute the ansible playbook on the distro
    Write-Host "Executing the ansible playbook on the distro..." -ForegroundColor Yellow
    & $DistroExe run ansible-playbook /home/$Username/ansible/project/playbook.yaml --extra-vars "username=$($Username)"
}
