try {
    . '.\Libraries\EZ-Admin.ps1'
    $Computers = Get-ComputersFromJson
} catch {
    Write-Warning 'Error while loading required libraries. Aborting.'
    exit
}

# Enter a PowerShell Session
# Enter-PSSessionByHostname DeviceName

# Run something on all computers
$IncludedComputers = $Computers

# Run something on all computers in a group
# $IncludedComputers = Get-ComputersInGroup Group1

# Ignore computers by hostname ones.
# $IgnoredComputers = @() # Add hostnames here

foreach ($c in $IncludedComputers) {
    if ($IgnoredComputers -contains $c.Hostname) {
        continue
    }

    <# Examples:

    Run a remote command:
    $Session = Get-PSSessionByComputer $c
    if ($Session) {
        Invoke-Command -Session $Session { Write-Host "Hello, world! My name is $env:COMPUTERNAME." }
    }

    Send a local file to computer:
    $Username = $c.Username
    Copy-Item '.\MyLocalFile' -ToSession (Get-PSSessionByComputer $c) "C:\Users\$Username\Desktop\MyRemoteFile" -Force

    #>
}
