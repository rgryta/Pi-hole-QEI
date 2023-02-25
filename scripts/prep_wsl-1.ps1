$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$hyperv = (Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State -ne "Enabled"

if($hyperv) {
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V-All
}

if ((winget list -n 1 --id 9P9TQF7MRM4R | Measure-Object -line).Lines -eq 3) {
	winget install 9P9TQF7MRM4R --source msstore --accept-source-agreements --accept-package-agreements
}

$command = "powershell.exe ""Start-Process pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -file $scriptPath\install-2.ps1'"""
$command = ""
if($hyperv) {
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
	-Name SDINSTALL -PropertyType String `
	-Value $command  | Out-Null

	Write-ColorOutput red ('Your computer will restart in 15 seconds and resume right after...')
	Start-Sleep -Seconds 15

	Restart-Computer -Force
}
else {
	powershell.exe "Start-Process pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -file $scriptPath\prep_wsl-2.ps1'"
}