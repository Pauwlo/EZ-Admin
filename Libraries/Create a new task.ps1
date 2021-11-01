# EZ-Admin - Create a new task

$TaskName = Read-Host 'Task name'
$ScriptFolderPath = (Get-Item $MyInvocation.MyCommand.Path).Directory.FullName

$TasksFolder = "$ScriptFolderPath\..\Tasks"

if (!(Test-Path $TasksFolder)) {
    New-Item $TasksFolder -Type Directory | Out-Null
}

$TaskCount = (Get-ChildItem $TasksFolder | Measure-Object).Count
$TaskID = $TaskCount + 1
$TaskPath = "$TasksFolder\$TaskID - $TaskName"

New-Item $TaskPath -Type Directory | Out-Null
Copy-Item "$ScriptFolderPath\Task template.ps1" "$TaskPath\$TaskName.ps1" | Out-Null
New-Item "$TaskPath\Completed.txt" | Out-Null

$WShellObject = New-Object -ComObject WScript.Shell
$Shortcut = $WShellObject.CreateShortcut("$TaskPath\$TaskName.lnk")
$Shortcut.TargetPath = 'powershell'
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$TaskName.ps1`""
$Shortcut.Save()

Start-Process "$TaskPath\$TaskName.ps1"
