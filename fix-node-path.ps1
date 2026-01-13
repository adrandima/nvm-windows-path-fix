# Script to permanently fix Node.js PATH with nvm-windows
# Run this script as Administrator
# Usage: .\fix-node-path.ps1 [username]
#        If username is not provided, it will use the current user

param(
    [string]$Username = $env:USERNAME
)

Write-Host "Fixing Node.js PATH for nvm-windows..." -ForegroundColor Cyan
Write-Host "Using username: $Username" -ForegroundColor Gray

# Get current Machine PATH
$machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$machinePathArray = $machinePath -split ';' | Where-Object { 
    $_ -ne 'C:\Program Files\nodejs' -and 
    $_ -ne 'C:\Program Files\nodejs\' -and
    $_ -ne '' 
}

# Remove duplicates and rebuild
$cleanedMachinePath = ($machinePathArray | Sort-Object -Unique) -join ';'

# Update Machine PATH
try {
    [System.Environment]::SetEnvironmentVariable("PATH", $cleanedMachinePath, "Machine")
    Write-Host "[OK] Machine PATH updated (removed old Node.js)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to update Machine PATH: $_" -ForegroundColor Red
    Write-Host "Make sure you're running as Administrator!" -ForegroundColor Yellow
    exit 1
}

# Ensure User PATH has nvm symlink directory
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$nvmSymlink = "C:\Users\$Username\AppData\Local\nvm\nodejs"

if ($userPath -notlike "*$nvmSymlink*") {
    $userPathArray = ($userPath -split ';' | Where-Object { $_ -ne '' }) + $nvmSymlink
    $cleanedUserPath = ($userPathArray | Sort-Object -Unique) -join ';'
    [System.Environment]::SetEnvironmentVariable("PATH", $cleanedUserPath, "User")
    Write-Host "[OK] User PATH updated (added nvm symlink)" -ForegroundColor Green
} else {
    Write-Host "[OK] User PATH already contains nvm symlink" -ForegroundColor Green
}

# Verify NVM_SYMLINK environment variable
$currentSymlink = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "User")
if ($currentSymlink -ne $nvmSymlink) {
    [System.Environment]::SetEnvironmentVariable("NVM_SYMLINK", $nvmSymlink, "User")
    Write-Host "[OK] NVM_SYMLINK updated to: $nvmSymlink" -ForegroundColor Green
} else {
    Write-Host "[OK] NVM_SYMLINK is already correct" -ForegroundColor Green
}

Write-Host ""
Write-Host "Setup complete! Please:" -ForegroundColor Cyan
Write-Host "1. Close and reopen all terminal windows" -ForegroundColor Yellow
Write-Host "2. Run: nvm use <version> (e.g., nvm use 25.2.1)" -ForegroundColor Yellow
Write-Host "3. Verify with: node --version" -ForegroundColor Yellow
