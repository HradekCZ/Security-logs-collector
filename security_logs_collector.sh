#!/bin/sh

# macOS Security Logs Collector
# Copyright (c) 2025 Yannick Housseau - HEP Vaud
# Licensed under MIT License
# https://github.com/yourusername/macos-security-logs-collector

# Error handling
set -e
trap cleanup EXIT

cleanup() {
    if [ -d "$tmpDir" ]; then
        rm -rf "$tmpDir"
    fi
}

# Get current user
currUser=$( who | awk '/console/{ print $1 }' )

# Validation
if [ -z "$currUser" ]; then
    echo "ERROR: Unable to determine current user"
    exit 1
fi

timestamp=$(date +"%Y%m%d_%H%M%S")
zipFile="/Users/$currUser/Desktop/security_logs_${currUser}_${timestamp}.zip"

# Check disk space (minimum 500MB)
availableSpace=$(df -k /Users/$currUser/Desktop | awk 'NR==2 {print $4}')
if [ "$availableSpace" -lt 512000 ]; then
    sudo -u $currUser osascript <<EOF
tell application "System Events"
    display dialog "Insufficient disk space on Desktop to create logs.

Contact support immediately:
Your_Phone_Number" buttons {"OK"} default button "OK" with icon caution
end tell
EOF
    exit 1
fi

# Create temporary folder to collect logs
tmpDir="/tmp/security_logs_$$"
mkdir -p "$tmpDir"

echo "=== SECURITY LOGS COLLECTION ==="
echo "User: $currUser"
echo "Date: $(date)"

# === SYSTEM INFORMATION ===
echo "Collecting system information..."
mkdir -p "$tmpDir/system_info"

system_profiler SPSoftwareDataType SPHardwareDataType > "$tmpDir/system_info/system_profile.txt" 2>/dev/null
sw_vers > "$tmpDir/system_info/macos_version.txt" 2>/dev/null
hostname > "$tmpDir/system_info/hostname.txt" 2>/dev/null
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate > "$tmpDir/system_info/firewall_status.txt" 2>/dev/null

# === SYSTEM LOGS ===
echo "Collecting DiagnosticReports logs..."
mkdir -p "$tmpDir/logs"
cp -R /Library/Logs/DiagnosticReports/ "$tmpDir/logs/DiagnosticReports/" 2>/dev/null || true
cp /var/log/system.log "$tmpDir/logs/system.log" 2>/dev/null || true
cp -R /Users/$currUser/Library/Logs/ "$tmpDir/logs/UserLogs/" 2>/dev/null || true

# === LAUNCHAGENTS & LAUNCHDAEMONS ===
echo "Collecting LaunchAgents and LaunchDaemons..."
mkdir -p "$tmpDir/launch_items"
cp -R /Library/LaunchAgents/ "$tmpDir/launch_items/LaunchAgents_System/" 2>/dev/null || true
cp -R /Library/LaunchDaemons/ "$tmpDir/launch_items/LaunchDaemons_System/" 2>/dev/null || true
cp -R /Users/$currUser/Library/LaunchAgents/ "$tmpDir/launch_items/LaunchAgents_User/" 2>/dev/null || true

# Formatted list of Launch Items
ls -la /Library/LaunchAgents/ > "$tmpDir/launch_items/LaunchAgents_System_list.txt" 2>/dev/null || true
ls -la /Library/LaunchDaemons/ > "$tmpDir/launch_items/LaunchDaemons_System_list.txt" 2>/dev/null || true
ls -la /Users/$currUser/Library/LaunchAgents/ > "$tmpDir/launch_items/LaunchAgents_User_list.txt" 2>/dev/null || true

# === PROCESSES AND NETWORK ===
echo "Collecting processes and network connections..."
mkdir -p "$tmpDir/processes_network"

ps aux > "$tmpDir/processes_network/active_processes.txt"
top -l 1 -n 20 > "$tmpDir/processes_network/top_processes.txt" 2>/dev/null || true
netstat -an > "$tmpDir/processes_network/network_connections.txt" 2>/dev/null || true
lsof -i > "$tmpDir/processes_network/open_ports.txt" 2>/dev/null || true
lsof -n > "$tmpDir/processes_network/open_files.txt" 2>/dev/null || true

# === USERS AND GROUPS ===
echo "Collecting users and groups..."
mkdir -p "$tmpDir/users"

dscl . -list /Users > "$tmpDir/users/users_list.txt" 2>/dev/null || true
dscl . -list /Groups > "$tmpDir/users/groups_list.txt" 2>/dev/null || true
last > "$tmpDir/users/recent_logins.txt" 2>/dev/null || true

# === APPLICATIONS ===
echo "Collecting installed applications..."
mkdir -p "$tmpDir/applications"

ls -la /Applications/ > "$tmpDir/applications/installed_applications.txt" 2>/dev/null || true
ls -la /Users/$currUser/Applications/ > "$tmpDir/applications/user_applications.txt" 2>/dev/null || true

# Recently modified applications (last 7 days)
find /Applications/ -type f -mtime -7 -ls 2>/dev/null > "$tmpDir/applications/recently_modified_apps.txt" || true

# === CONFIGURATION PROFILES ===
echo "Collecting configuration profiles..."
profiles -P -o stdout-xml > "$tmpDir/system_info/configuration_profiles.xml" 2>/dev/null || true
profiles -L > "$tmpDir/system_info/profiles_list.txt" 2>/dev/null || true

# === BROWSER EXTENSIONS ===
echo "Collecting browser extensions..."
mkdir -p "$tmpDir/browser_extensions"

# Chrome
if [ -d "/Users/$currUser/Library/Application Support/Google/Chrome/Default/Extensions" ]; then
    ls -la "/Users/$currUser/Library/Application Support/Google/Chrome/Default/Extensions/" > "$tmpDir/browser_extensions/chrome_extensions.txt" 2>/dev/null || true
fi

# Safari
if [ -d "/Users/$currUser/Library/Safari/Extensions" ]; then
    ls -la "/Users/$currUser/Library/Safari/Extensions/" > "$tmpDir/browser_extensions/safari_extensions.txt" 2>/dev/null || true
fi

# Firefox
if [ -d "/Users/$currUser/Library/Application Support/Firefox/Profiles" ]; then
    find "/Users/$currUser/Library/Application Support/Firefox/Profiles" -name "extensions.json" -exec cat {} \; > "$tmpDir/browser_extensions/firefox_extensions.json" 2>/dev/null || true
fi

# === RECENT DOWNLOADS ===
echo "Collecting recent downloads..."
mkdir -p "$tmpDir/downloads"

find /Users/$currUser/Downloads -type f -mtime -7 -ls 2>/dev/null > "$tmpDir/downloads/downloads_last_7_days.txt" || true
ls -lath /Users/$currUser/Downloads/ 2>/dev/null | head -50 > "$tmpDir/downloads/downloads_list.txt" || true

# === SHELL HISTORY ===
echo "Collecting shell history..."
mkdir -p "$tmpDir/shell_history"

cp /Users/$currUser/.zsh_history "$tmpDir/shell_history/zsh_history.txt" 2>/dev/null || true
cp /Users/$currUser/.bash_history "$tmpDir/shell_history/bash_history.txt" 2>/dev/null || true

# === CRONTABS ===
echo "Collecting crontabs..."
crontab -l > "$tmpDir/system_info/crontab.txt" 2>/dev/null || echo "No crontab" > "$tmpDir/system_info/crontab.txt"

# === METADATA ===
echo "Creating metadata file..."
cat > "$tmpDir/METADATA.txt" <<METADATA
=== LOGS COLLECTION REPORT ===
Collection date: $(date)
User: $currUser
Hostname: $(hostname)
macOS Version: $(sw_vers -productVersion)
Build: $(sw_vers -buildVersion)
Model: $(system_profiler SPHardwareDataType | grep "Model Name" | awk -F: '{print $2}' | xargs)

Script executed from: Jamf Self Service
Reason: Suspected breach / Security incident

=== COLLECTED FILES ===
$(cd "$tmpDir" && find . -type f | wc -l) total files
Total size: $(du -sh "$tmpDir" | awk '{print $1}')

=== NEXT STEPS ===
1. Contact IT support immediately: Your_Phone_Number
2. Send this ZIP file to support: email_adress
3. Do not restart your Mac
4. Keep the Mac powered on
METADATA

# === COMPRESSION ===
echo "Compressing logs..."
cd /tmp
zip -9 -r "$zipFile" "security_logs_$$" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    zipSize=$(du -h "$zipFile" | awk '{print $1}')
    echo "Logs compressed successfully: $zipFile ($zipSize)"
    
    # Display success popup
    sudo -u $currUser osascript <<EOF
tell application "System Events"
    activate
    display dialog "Log files saved on your Desktop

File created: security_logs_${currUser}_${timestamp}.zip
Size: ${zipSize}

System logs have been collected and compressed for analysis by the IT team.

Contact support IMMEDIATELY:
Your_Phone_Number
email_adress

Support will provide the next steps.

Do not restart your Mac and keep it powered on." buttons {"OK"} default button "OK" with title "Security Logs" with icon caution
end tell
EOF
else
    echo "ERROR: Compression failed"
    sudo -u $currUser osascript <<EOF
tell application "System Events"
    display dialog "Error creating logs

Contact support immediately:
Your_Phone_Number" buttons {"OK"} default button "OK" with icon stop
end tell
EOF
    exit 1
fi

echo "=== COLLECTION COMPLETED ==="
