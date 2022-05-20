# EZ-Admin
# You shouldn't run this script alone. Include it somewhere else instead.

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptFolderPath = (Get-Item $ScriptPath).Directory.FullName

class Computer {
    [string]$Name
    [string]$Hostname
    [string]$Username
    [System.Management.Automation.PSCredential]$Credential
    [string]$Group
    [Object]$Session

    Computer (
        [string]$name,
        [string]$hostname,
        [string]$username,
        [System.Management.Automation.PSCredential]$credential,
        [string]$group
    ) {
        $this.Name = $name
        $this.Hostname = $hostname
        $this.Username = $username
        $this.Credential = $credential
        $this.Group = $group
    }

    [string]ToString() {
        return ("{0}\{1} ({2})" -f $this.Name, $this.Username, $this.Group)
    }
}

function Get-ComputerByName {

    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Name 
    )

    foreach ($c in $Computers) {
        if ($c.Name -eq $Name) {
            return $c
        }
    }

    Write-Warning 'Unknown name.'
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

function Get-ComputersInGroup {

    Param(
        [parameter(Mandatory=$true)]
        [string]
        $Group
    )

    return $Computers | Where-Object {
        $_.Group -eq $Group
    }
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

function Get-PSSessionByName {
    
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Name 
    )

    $c = Get-ComputerByName $Name

    if ($c) {
        return Get-PSSessionByComputer $c
    }

    Write-Warning 'Unknown name.'
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

function Enter-PSSessionByName {
    
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Name 
    )

    $s = Get-PSSessionByName $Name
    if ($null -ne $s) {
        Enter-PSSession $s
    } else {
        Write-Warning "Couldn't connect to $Name."
    }
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

    $Path = 'Computers.json'

    try {
        $Json = $File | ConvertFrom-Json

        foreach ($Object in $Json) {
            $Object.Name = $Object.Name | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
            $Object.Hostname = $Object.Hostname | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
            $Object.Username = $Object.Username | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
            $Object.Password = $Object.Password | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
            $Object.Group = $Object.Group | ConvertTo-SecureString -AsPlainText | ConvertFrom-SecureString
        }
    
        $Json | ConvertTo-Json | Set-Content $Path
    
        $Properties = (Get-ItemProperty $Path)
        if (! ($Properties.Attributes -band [IO.FileAttributes]::Hidden)) {
            $Properties.Attributes += [IO.FileAttributes]::Hidden
        }
        Write-Host ('Encrypted computer list saved to {0}' -f $Properties.FullName)
    } catch {
        Write-Warning 'An error occured while encrypting the JSON. Please check the syntax and try again.'
    }
    
}

function Get-ComputersFromJson {

    Param(
        [parameter(Mandatory=$false)]
        [String]
        $Path = "$ScriptFolderPath\Computers.json"
    )

    if (!(Test-Path $Path)) {
        Write-Host -ForegroundColor Yellow "Couldn't find Computers.json. Did you run Encrypt JSON file?"
        Exit
    }

    $Json = Get-Content $Path | ConvertFrom-Json
    $Computers = New-Object System.Collections.Generic.List[Computer]

    foreach ($Object in $Json) {
        $Name = $Object.Name | ConvertTo-SecureString
        $Hostname = $Object.Hostname | ConvertTo-SecureString
        $Username = $Object.Username | ConvertTo-SecureString
        $Password = $Object.Password | ConvertTo-SecureString
        $Group = $Object.Group | ConvertTo-SecureString

        $Name = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Name))
        $Hostname = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Hostname))
        $Username = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Username))
        $Credential = New-Object System.Management.Automation.PsCredential($Username, $Password)
        $Group = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Group))

        $Computers.Add([Computer]::new($Name, $Hostname, $Username, $Credential, $Group))
    }

    return $Computers
}
