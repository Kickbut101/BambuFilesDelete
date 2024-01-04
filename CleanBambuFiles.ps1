# Quick simple script to connect, then delete all files locally on bambu printer (Works so far on my P1S)
# Andrew Lund
# 01-04-24

$configDir = "C:\temp"
$setupDir = "C:\temp\BambuPrinterClearSetupDir\"
$winSCPExe = "$setupDir\WinSCP.com"

if (Test-Path -Path $winSCPExe) { <# Do nothing #> }
Else {
    # Acquire and unzip winSCP files
    mkdir -Path $setupDir -Force
    Write-host "Grabbing winscp portable..."
    $ProgressPreference = 'SilentlyContinue' # Speeds up downloads
    Invoke-WebRequest -uri "https://zenlayer.dl.sourceforge.net/project/winscp/WinSCP/6.1.2/WinSCP-6.1.2-Portable.zip" -OutFile "$setupDir\WinscpPort.zip"
    Expand-Archive -Path "$setupDir\WinscpPort.zip" -DestinationPath $setupDir
}

# Read saved password and IP address of printer if already entered and saved locally
if (Test-Path "$configDir\bambuprinterInfo.txt") {
    $bambuPrinterInfo = cat "$configDir\bambuprinterInfo.txt"
}
Else {
    $IP = Read-Host -Prompt "IP of printer?: "
    $AccessCode = Read-Host "Password/Access code for printer?: "
    $Username = Read-Host "Username? (Default is bblp): "
    $IP, $AccessCode, $Username | Out-File -FilePath "$configDir\bambuprinterInfo.txt" -Force

    $bambuPrinterInfo = cat "$configDir\bambuprinterInfo.txt" # Lazy
}

Start-Process -FilePath $winSCPExe -ArgumentList @("/command", "`"open ftp://$($bambuPrinterinfo[2]):$($bambuPrinterInfo[1])@$($bambuPrinterInfo[0]):990/ -hostkey=`"`"*`"`" -implicit`"", "`"rm `"`"*.gcode`"`"`"", "`"rm `"`"*.3mf`"`"`"", "`"exit`"") -wait
