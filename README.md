# EZ-Admin

A simple PowerShell library to run PowerShell scripts on a Windows network via PowerShell Remote.

## Installation

0. Prepare a JSON file following [the example below](#json-example).
1. Clone (or download) this repository on your computer.
2. Open a PowerShell terminal into the `Libraries` folder.
3. Run `.\Encrypt JSON File.ps1` and paste your JSON file.
4. EZ-Admin is ready to use!

## Usage

1. Duplicate the template script called `# EZ-Admin Template.ps1`.
2. Create your PowerShell script based on your needs, and feel free to use the following commands:
    - `Get-ComputerByHostname`
    - `Get-PSSessionByComputer`
    - `Get-PSSessionByHostname`
    - `Enter-PSSessionByHostname`
3. Run your script!

## JSON Example

```json
[
  {
    "Name": "DEVICE1",
    "Hostname": "device1.company",
    "Username": "John Doe",
    "Password": "weakpassword",
    "Group": "Group1"
  },
  {
    "Name": "DEVICE2",
    "Hostname": "device2.company",
    "Username": "Someone Else",
    "Password": "EZhc96~3+$eEE3&h",
    "Group": "Group1"
  }
]

```
