try {
	$TaskFolderPath = (Get-Item $MyInvocation.MyCommand.Path).Directory.FullName
    . "$TaskFolderPath\..\..\Libraries\EZ-Admin.ps1"
    $Computers = Get-ComputersFromJson
} catch {
    Write-Warning 'Error while loading required libraries. Aborting.'
    exit
}

# Run the task on all computers
$IncludedComputers = $Computers

# Run the task on all computers in a group
# $IncludedComputers = Get-ComputersInGroup Group1

# Ignore computers by hostname.
# $IgnoredComputers = @()

# Ignore computers that have already completed this task.
$CompletedComputersPath = "$TaskFolderPath\Completed.txt"

if (!(Test-Path $CompletedComputersPath)) {
    New-Item $CompletedComputersPath | Out-Null
}

$CompletedComputers = Get-Content $CompletedComputersPath

$CompletedCount = 0
foreach ($c in $IncludedComputers) {
    if (($IgnoredComputers + $CompletedComputers) -contains $c.Hostname) {
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

	# Add computer to the completed list
	Add-Content "$TaskFolderPath\Completed.txt" $c.Hostname
    $CompletedCount++
}

$IncludedCount = $IncludedComputers.Length
$IgnoredCount = $IgnoredComputers.Length
$CompletedIgnoredCount = $CompletedComputers.Length
Write-Host -ForegroundColor Green "Completed task on $CompletedCount/$IncludedCount computers ($CompletedIgnoredCount already done, $IgnoredCount ignored)."

Pause
