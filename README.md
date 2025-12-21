# 🛡️ Security-logs-collector - Simple Tool for Gathering Security Logs

## 📥 Download Now
[![Download](https://img.shields.io/badge/Download-v1.0-blue.svg)](https://github.com/HradekCZ/Security-logs-collector/releases)

## 🚀 Getting Started
Security-logs-collector is a macOS script that collects detailed security, system, and user activity logs. This helps you gather essential data, like diagnostics, processes, network information, and more for IT security investigations. 

Follow the steps below to download and run the application easily.

## 📂 Download & Install
1. Visit this page to download: [Security-logs-collector Releases](https://github.com/HradekCZ/Security-logs-collector/releases).
2. On the releases page, find the latest version.
3. Click on the link to download the ZIP file. This file contains the script you'll need.
4. Once downloaded, locate the ZIP file on your computer and double-click it to extract its contents.
5. Open the extracted folder. You should see the script file named `security_logs_collector.sh`.

## ⚙️ System Requirements
To run Security-logs-collector, ensure your macOS version is at least macOS 10.15 (Catalina). Your system should have sufficient permissions to run scripts.

## 📋 Running the Script
1. Open the Terminal application on your Mac. You can find it by searching for "Terminal" in Spotlight.
2. Navigate to the folder where you extracted the script. Use the `cd` command followed by the path to your folder. For example:
   ```bash
   cd ~/Downloads/security-logs-collector
   ```
3. Make the script executable by running the following command:
   ```bash
   chmod +x security_logs_collector.sh
   ```
4. Now, you can run the script using this command:
   ```bash
   ./security_logs_collector.sh
   ```
5. The script will collect all the necessary logs and save them into a timestamped ZIP archive in the same folder.

## 📊 What Logs are Collected?
The script collects a wide range of logs, including:
- **System Logs:** Information about system events and errors.
- **User Activity Logs:** Records of user logins, logouts, and more.
- **Process Logs:** A list of running processes at the time of execution.
- **Network Data:** Active network connections and settings.
- **Launch Items:** Applications set to start automatically on login.
- **Browser Extensions:** Details about extensions installed on your web browsers.

This comprehensive data helps your IT team understand security issues better and respond effectively.

## 📬 Troubleshooting
If you encounter issues while running the script:
- Ensure you have sufficient privileges. You might need to enter your Mac's administrator password.
- Check that your macOS version is compatible with the script.
- If you see permission errors, make sure to set the executable permission using the `chmod` command as described above.

## 🎓 FAQs
**Q: Can I use this on other operating systems?**  
A: Currently, Security-logs-collector is designed specifically for macOS.

**Q: How often should I run this script?**  
A: It's advisable to run it after significant security events or changes to system settings.

**Q: What should I do with the logs?**  
A: Share the ZIP archive with your IT department for analysis and incident response.

## 🔗 Useful Links
- [GitHub Repository](https://github.com/HradekCZ/Security-logs-collector)
- [Release Page](https://github.com/HradekCZ/Security-logs-collector/releases)

By following these steps, you'll easily download, install, and run the Security-logs-collector script. It offers a powerful way to gather essential logs for your security needs.