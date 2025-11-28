# macOS Security Logs Collector

A comprehensive macOS security and system diagnostics collector designed for incident response and forensic analysis.  
This script gathers system information, logs, launch items, processes, network activity, browser extensions, recent downloads and user session data, then packages everything into a timestamped ZIP archive on the Desktop.

## Features

- Collects system information (hardware, macOS version, profiles, firewall status)
- Gathers system and user logs, including DiagnosticReports and `system.log`
- Extracts LaunchAgents and LaunchDaemons (system and user)
- Captures running processes, open files, open ports and network connections
- Lists users, groups and recent login activity
- Extracts installed and recently modified applications
- Collects configuration profiles
- Retrieves browser extensions (Chrome, Safari, Firefox)
- Records recent Downloads items (last 7 days)
- Copies shell history (.zsh_history, .bash_history)
- Exports crontab configuration
- Generates a metadata summary (model, version, timestamp, context)
- Compresses all collected data into a ZIP archive with a timestamped filename
- Supports user notifications via macOS dialogs (osascript)

## Requirements

- macOS  
- Administrative privileges (for some logs and system areas)
- Sufficient disk space (minimum 500 MB on the Desktop)

## Output

The script creates a ZIP file named:

