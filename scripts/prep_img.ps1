if (-not (Get-Module -ListAvailable -Name WSLTools)) {
    Install-Module -Name WSLTools -Force
} 

Import-Module WSLTools -WarningAction SilentlyContinue
if (-not (Ensure-WSL)) {
	return $false
}

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$distro = 'alpine-raspi-qei'
$ignr = wsl --unregister $distro

WSL-Alpine-Install -DistroAlias $distro -InstallPath $scriptPath

wsl -d $distro -e sh -c "apk add sudo bash curl xz file openssl"

$wp = wsl wslpath -a ($scriptPath -replace '[\\]', '\\\\')

wsl -d $distro -e sh -c "sudo $wp/prep_img.sh"

wsl --unregister $distro