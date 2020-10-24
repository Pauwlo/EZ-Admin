# EZ-Admin - Encrypt JSON file

try {
    . '.\EZ-Admin.ps1'
} catch {
    Write-Warning 'Error while loading EZ-Admin. Aborting.'
    exit
}

$CurrentLine = '';
$Lines = @();

Write-Host "Paste your JSON array here"

while ($CurrentLine -ne "]") {
    $CurrentLine = Read-Host ">"
    $Lines += $CurrentLine
}

Clear-Host
New-EncryptedJsonFile $Lines
