# EZ-Admin
# You shouldn't run this script alone. Include it somewhere else instead.

class Computer {
    [string]$Hostname
    [string]$Username
    [System.Management.Automation.PSCredential]$Credential
    [Object]$Session

    Computer (
        [string]$hostname,
        [string]$username,
        [System.Management.Automation.PSCredential]$credential
    ) {
        $this.Hostname = $hostname
        $this.Username = $username
        $this.Credential = $credential
    }

    [string]ToString() {
        return ("{0}\{1}" -f $this.Hostname, $this.Username)
    }
}

function Get-ComputerByHostname {

    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Hostname 
    )

    foreach ($c in $Computers) {
        if ($c.Hostname -eq $Hostname) {
            return $c
        }
    }

    Write-Warning 'Unknown hostname.'
}

function Get-PSSessionByComputer {

    Param(
        [parameter(Mandatory=$true)]
        [Computer]
        $Computer 
    )

    $Session = $null

    if ($null -eq $Computer.Session) {
        $SessionOption = New-PSSessionOption -OpenTimeout 1
        $Session = New-PSSession $Computer.Hostname -UseSSL -Credential $Computer.Credential -SessionOption $SessionOption -ErrorAction SilentlyContinue 
    }

    if ($Session) {
        $Computer.Session = $Session
    } else {
        Write-Warning "Couldn't create PowerShell Session for $Computer."
    }

    return $Session
}

function Get-PSSessionByHostname {
    
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Hostname 
    )

    $c = Get-ComputerByHostname $Hostname

    if ($c) {
        return Get-PSSessionByComputer $c
    }

    Write-Warning 'Unknown hostname.'
}

function Enter-PSSessionByHostname {
    
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Hostname 
    )

    $s = Get-PSSessionByHostname $Hostname
    if ($null -ne $s) {
        Enter-PSSession $s
    } else {
        Write-Warning "Couldn't connect to $Hostname."
    }
}

function New-EncryptedJsonFile {

    Param(
        [parameter(Mandatory=$true)]
        [Array]
        $File 
    )

    try {
        $Json = $File | ConvertFrom-Json

        foreach ($Object in $Json) {
            $Object.Hostname = $Object.Hostname | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
            $Object.Username = $Object.Username | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
            $Object.Password = $Object.Password | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
        }
    
        $Json | ConvertTo-Json | Set-Content ./Computers.json
    
        $File = Get-ChildItem ./Computers.json -Force
        $File | ForEach-Object { $_.Attributes += 'Hidden' }
        Write-Host ("JSON array encrypted successfully at: {0}" -f $File.FullName)
    } catch {
        Write-Warning 'An error occured while encrypting the JSON. Please check the syntax and try again.'
    }
    
}

function Get-ComputersFromJson {
    if (!(Test-Path ./Libraries/Computers.json)) {
        Write-Host -ForegroundColor Yellow "Couldn't find Computers.json. Did you run Encrypt JSON file?"
        Exit
    }

    $Json = Get-Content ./Libraries/Computers.json | ConvertFrom-Json
    $Computers = New-Object System.Collections.Generic.List[Computer]

    foreach ($Object in $Json) {
        $Hostname = $Object.Hostname | ConvertTo-SecureString
        $Username = $Object.Username | ConvertTo-SecureString
        $Password = $Object.Password | ConvertTo-SecureString

        $Hostname = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Hostname))
        $Username = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Username))
        $Credential = New-Object System.Management.Automation.PsCredential($Username, $Password)

        $Computers.Add([Computer]::new($Hostname, $Username, $Credential))
    }

    return $Computers
}
