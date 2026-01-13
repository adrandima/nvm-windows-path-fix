# Fix: Node.js Not Available in Terminal After Installing with nvm-windows

## Problem Description

After installing Node.js using **nvm-windows** (Node Version Manager for Windows), you may encounter an issue where:
- Node.js is installed but not recognized in terminals (PowerShell, CMD, Git Bash)
- Running `node --version` or `npm --version` returns "command not found" errors
- The `nvm list` command shows installed versions, but `nvm current` shows "No current version"

### Root Cause

This issue typically occurs when:
1. A standalone Node.js installation exists at `C:\Program Files\nodejs\` that takes precedence in the system PATH
2. The nvm-windows symlink directory is not properly configured in the PATH
3. The `NVM_SYMLINK` environment variable is pointing to an incorrect location
4. PATH environment variables contain duplicate or conflicting entries

## Solution

We've created a PowerShell script that automatically fixes all PATH-related issues for nvm-windows.

### Prerequisites

- Windows operating system
- nvm-windows installed (download from [nvm-windows releases](https://github.com/coreybutler/nvm-windows/releases))
- At least one Node.js version installed via nvm (e.g., `nvm install 20.11.0`)
- Administrator privileges (required to modify system PATH)

### Step-by-Step Fix

1. **Download the fix script**
   - Save `fix-node-path.ps1` to your computer

2. **Open PowerShell as Administrator**
   - Press `Win + X` and select "Windows PowerShell (Admin)" or "Terminal (Admin)"
   - Or right-click on PowerShell and select "Run as Administrator"

3. **Navigate to the script location**
   ```powershell
   cd C:\path\to\script
   ```

4. **Run the script**
   
   **Option A: Use current logged-in user (recommended)**
   ```powershell
   .\fix-node-path.ps1
   ```
   
   **Option B: Specify a different username**
   ```powershell
   .\fix-node-path.ps1 -Username "YourUsername"
   ```

5. **Verify the fix**
   - Close **all** terminal windows (PowerShell, CMD, VS Code terminals, etc.)
   - Open a new terminal window
   - Run: `nvm use <version>` (replace `<version>` with your installed version, e.g., `nvm use 20.11.0`)
   - Verify: `node --version` (should display the version you selected)
   - Verify: `npm --version` (should display npm version)

### What the Script Does

The script performs the following operations:

1. **Removes old Node.js from Machine PATH**
   - Removes `C:\Program Files\nodejs` entries from system PATH
   - Prevents conflicts with nvm-managed Node.js versions

2. **Adds nvm symlink to User PATH**
   - Adds `C:\Users\<YourUsername>\AppData\Local\nvm\nodejs` to user PATH
   - This is the symlink directory that nvm uses to switch between versions

3. **Updates NVM_SYMLINK environment variable**
   - Ensures `NVM_SYMLINK` points to the correct symlink directory
   - Required for nvm-windows to function properly

4. **Cleans up duplicate PATH entries**
   - Removes duplicate entries that can cause conflicts

### Manual Alternative (If Script Doesn't Work)

If you prefer to fix this manually or the script doesn't work:

1. **Remove old Node.js from System PATH:**
   - Open "System Properties" → "Environment Variables"
   - Under "System variables", find "Path" and click "Edit"
   - Remove any entries containing `C:\Program Files\nodejs`
   - Click "OK" to save

2. **Add nvm symlink to User PATH:**
   - Under "User variables", find "Path" and click "Edit"
   - Add: `C:\Users\<YourUsername>\AppData\Local\nvm\nodejs`
   - Replace `<YourUsername>` with your actual Windows username
   - Click "OK" to save

3. **Set NVM_SYMLINK environment variable:**
   - Under "User variables", click "New"
   - Variable name: `NVM_SYMLINK`
   - Variable value: `C:\Users\<YourUsername>\AppData\Local\nvm\nodejs`
   - Replace `<YourUsername>` with your actual Windows username
   - Click "OK" to save

4. **Restart your computer** or close all terminal windows and reopen them

5. **Activate a Node.js version:**
   ```powershell
   nvm use <version>
   ```

### Verification

After running the fix, verify everything works:

```powershell
# Check nvm is working
nvm list
nvm current

# Activate a version
nvm use 20.11.0

# Verify Node.js
node --version
npm --version

# Check which node is being used
where.exe node
# Should show: C:\Users\<YourUsername>\AppData\Local\nvm\nodejs\node.exe
```

### Troubleshooting

**Issue: Script fails with "Requested registry access is not allowed"**
- **Solution:** Make sure you're running PowerShell as Administrator

**Issue: Node.js still not found after running script**
- **Solution:** 
  1. Close ALL terminal windows completely
  2. Restart your computer (recommended)
  3. Open a new terminal and run `nvm use <version>`

**Issue: Wrong Node.js version is active**
- **Solution:** 
  1. Check: `nvm current`
  2. Run: `nvm use <desired-version>`
  3. Verify: `node --version`

**Issue: "nvm: command not found"**
- **Solution:** nvm-windows may not be installed. Download and install from [nvm-windows releases](https://github.com/coreybutler/nvm-windows/releases)

### Additional Notes

- The script is safe to share - it contains no personal information
- It uses `$env:USERNAME` to automatically detect the current user
- You can specify a different username as a parameter if needed
- The script only modifies PATH and NVM_SYMLINK environment variables
- It does not modify or delete any Node.js installations

### Contributing

If you encounter issues or have improvements, please:
1. Check if the issue is already documented
2. Verify you're using the latest version of nvm-windows
3. Provide details about your Windows version and nvm-windows version

### Related Resources

- [nvm-windows GitHub Repository](https://github.com/coreybutler/nvm-windows)
- [nvm-windows Documentation](https://github.com/coreybutler/nvm-windows/wiki)
- [Node.js Official Website](https://nodejs.org/)

---

**Last Updated:** 2024
**Tested on:** Windows 10, Windows 11
**nvm-windows Version:** 1.2.2+
