$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

wsl --set-default-version 2
Start-Sleep -Seconds 2

$completed = $false
$distro = 'alpine-raspi'
$ignr = wsl --unregister $distro

Write-Output 'Downloading...'
Remove-Item -Force alias:curl -ErrorAction SilentlyContinue
while (-not $completed) {
	try {
		$response = curl -L -C - -o $scriptPath\alpine.tar.gz -w "%{http_code}\n" -s https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/x86_64/alpine-minirootfs-3.17.2-x86_64.tar.gz
		if ($response -ne 200) {
			throw "Expecting reponse code 200, was: $response"
		}
	} catch {
	}
	
	if ($response -eq 200) {
		$completed = $true
	}
}
wsl --import $distro $scriptPath/install-dir/ $scriptPath\alpine.tar.gz 

wsl -d $distro -e sh -c "apk add sudo bash curl xz file openssl"

$wp = wsl wslpath -a ($scriptPath -replace '[\\]', '\\\\')

wsl -d $distro -e sh -c "sudo $wp/prep_img.sh"

wsl --unregister $distro
Remove-Item -Path $scriptPath\install-dir -Recurse
Remove-Item -Path $scriptPath\alpine.tar.gz