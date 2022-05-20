try {
    . '.\Libraries\EZ-Admin.ps1'
    $Computers = Get-ComputersFromJson
} catch {
    Write-Warning 'Error while loading required libraries. Aborting.'
    exit
}

# Enter a PowerShell Session
# Enter-PSSessionByName DeviceName

# Run something on all computers
$IncludedComputers = $Computers

# Run something on all computers in a group
# $IncludedComputers = Get-ComputersInGroup Group1

# Ignore computers by name.
# $IgnoredComputers = @()

foreach ($c in $IncludedComputers) {
    if ($IgnoredComputers -contains $c.Name) {
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
