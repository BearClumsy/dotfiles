# Windows setup script for dotfiles (Alacritty + WSL)
# Run from PowerShell as Administrator:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#   .\setup-windows.ps1

$ErrorActionPreference = "Stop"

# --- 1. Check winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install App Installer from the Microsoft Store and re-run."
    exit 1
}

# --- 2. Install Alacritty ---
Write-Host "Installing Alacritty..."
winget install --id Alacritty.Alacritty -e --accept-package-agreements --accept-source-agreements

# --- 3. Install Hack Nerd Font ---
Write-Host "Installing Hack Nerd Font..."
$fontZip = "$env:TEMP\HackNerdFont.zip"
$fontDir = "$env:TEMP\HackNerdFont"
$fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -OutFile $fontZip
Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force

if (-not (Test-Path $fontsFolder)) { New-Item -ItemType Directory -Path $fontsFolder | Out-Null }

Get-ChildItem "$fontDir\*.ttf" | ForEach-Object {
    $dest = "$fontsFolder\$($_.Name)"
    Copy-Item $_.FullName $dest -Force
    # Register font in registry for current user
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontName = $_.BaseName + " (TrueType)"
    Set-ItemProperty -Path $regPath -Name $fontName -Value $dest
}

Remove-Item $fontZip, $fontDir -Recurse -Force
Write-Host "Hack Nerd Font installed."

# --- 4. Copy Alacritty config ---
Write-Host "Copying Alacritty config..."
$alacrittyConfigDir = "$env:APPDATA\alacritty"
if (-not (Test-Path $alacrittyConfigDir)) {
    New-Item -ItemType Directory -Path $alacrittyConfigDir | Out-Null
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcConfig = Join-Path $scriptDir "alacritty\alacritty.toml"

if (Test-Path $srcConfig) {
    Copy-Item $srcConfig "$alacrittyConfigDir\alacritty.toml" -Force
    Write-Host "Alacritty config copied to $alacrittyConfigDir\alacritty.toml"
} else {
    Write-Warning "alacritty\alacritty.toml not found next to this script. Skipping."
}

# --- 5. Check WSL ---
Write-Host ""
$wslCheck = wsl --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL does not appear to be installed."
    Write-Host "Run in PowerShell (Admin): wsl --install"
    Write-Host "Then reboot and re-run this script."
} else {
    Write-Host "WSL is installed."
    Write-Host ""
    Write-Host "Next: open Alacritty, then inside WSL run:"
    Write-Host "  git clone https://github.com/BearClumsy/dotfiles ~/.dotfiles"
    Write-Host "  bash ~/.dotfiles/setup-linux.sh"
}

Write-Host ""
Write-Host "Done! Open Alacritty to launch WSL."
