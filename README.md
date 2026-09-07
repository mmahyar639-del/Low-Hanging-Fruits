# ️ Low-Hanging Fruits (LHF)
### 🚀 Automated Bug Bounty Reconnaissance & Vulnerability Scanner

<div align="center">
  <img src="https://img.shields.io/badge/Version-1.1.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Bash-Automation-green?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/License-MIT-orange?style=for-the-badge" alt="License">
</div>

<br>

```text
  _     ____    ____  _  __       _____ _   _ _____ 
 | |   |  _ \  / ___|| |/ /      |  ___| | | |_   _|
 | |   | | | | \___ \| ' /  _____| |_  | | | | | |  
 | |___| |_| |  ___) | . \ |_____|  _| | |_| | | |  
 |_____|____/  |____/|_|\_\      |_|    \___/  |_|  
  Low-Hanging Fruits - Automated Bug Bounty Recon
```

---

## 📖 About The Project
**Low-Hanging Fruits (LHF)** is a modular, automated reconnaissance and vulnerability scanning engine written in Bash. Designed specifically for Bug Bounty Hunters and Penetration Testers, LHF focuses on quickly identifying "low-hanging fruits" such as exposed configuration files, leaked API keys, subdomain misconfigurations, and known CVEs.

By intelligently chaining together the best tools in the modern Go-based security ecosystem (ProjectDiscovery suite) and managing system resources efficiently, LHF provides a complete pipeline from initial subdomain enumeration to professional HTML report generation.

---

## ✨ Key Features
- 🔍 **Deep Subdomain Enumeration:** Combines `subfinder` and `assetfinder` with intelligent root-domain inclusion.
- 🌐 **Smart Port & HTTP Probing:** Uses `naabu` and `httpx` with custom web-port profiles and tech-detection.
- 🕸️ **Endpoint Discovery:** Active (`katana`) and passive (`gau`) crawling to find hidden API endpoints and JS files.
- 🔑 **Secret Hunting:** Automated scanning of JavaScript files and configurations for leaked tokens.
-  **Targeted Vulnerability Scanning:** Leverages `nuclei` with severity filtering (Medium+) and excludes noisy/DoS tags for safe scanning.
- 📊 **Automated HTML Reporting:** Generates clean, color-coded, and professional HTML reports ready for triage.
- 🛡️ **Background Mode (`-b`):** Run long scans on VPS without losing connection.
- 👁️ **Quick Report Viewer (`-v`):** Instantly spin up a local HTTP server to view results in your browser.
- ⚙️ **Centralized Configuration:** Manage threads, rate-limits, and scan profiles via a single `config.conf`.

---

## 🛠️ Prerequisites
- **OS:** Ubuntu 20.04+ or Kali Linux (Tested on VPS environments).
- **Privileges:** Root access (`sudo`) is required for installing dependencies and certain network scans.
- **Go Language:** Version 1.20 or higher (Setup script handles this).

---

## 🚀 Installation

Clone the repository and run the unified installation script. It will automatically install Go, all required tools, and set up the default configuration.


```bash
# 1. Clone the repository
git clone https://github.com/mmahyar639-del/Low-Hanging-Fruits.git
cd Low-Hanging-Fruits

# 2. Grant execution permissions
chmod +x install.sh bb-scan.sh
./install.sh

# 3. Run the foundation and setup scripts sequentially
./Foundation.sh
./GoSetup.sh
./StructureSetup.sh
./ToolsInstall.sh
./WordlistStep1.sh
./WordlistStep2.sh
./WordlistOptimize.sh
./NucleiSetup.sh
./NotifySetup.sh
```

---

## 💻 Usage

LHF comes with a built-in help menu. Run `./bb-scan.sh -h` to see all options.

### 1. Normal Scan (Interactive)
Best for quick scans where you want to watch the progress in real-time.
```bash
./bb-scan.sh target.com
```

### 2. Background Mode (Recommended for VPS)
Runs the scan in the background, allowing you to safely close your SSH session.
```bash
./bb-scan.sh -b target.com

# To monitor progress:
tail -f ~/lhf/logs/lhf_target.com_background.log

# To stop the scan:
kill $(cat ~/lhf/tmp/lhf_target.com.pid)
```

### 3. Quick Report Viewer
Instantly view the generated HTML report in your local browser via a temporary Python HTTP server.
```bash
./bb-scan.sh -v
```

---

##  Project Architecture
```text
~/lhf/
├── bb-scan.sh          # 🧠 Main Scanning Engine
├── config.conf         # ⚙️ Central Configuration File
── utils/              # 🛠️ Helper Scripts
├── wordlists/          #  Optimized Wordlists (Resolvers, Paths, etc.)
├── scans/              #  Isolated Scan Directories
│   └── {target}_{timestamp}/
│       ├── subs/       # Subdomains
│       ├── ports/      # Open Ports
│       ├── http/       # HTTP Probing Results
│       ├── urls/       # Crawled Endpoints
│       ├── secrets/    # Leaked API Keys & Tokens
│       ├── vulns/      # Nuclei Findings
│       └── reports/    #  HTML Reports
└── logs/               # 📝 Background Execution Logs
```

---

## ⚠️ Disclaimer & Ethics
This tool is developed strictly for **educational purposes, authorized penetration testing, and legitimate Bug Bounty programs**. 
- **DO NOT** use this tool against targets without explicit written permission.
- The developers assume no liability and are not responsible for any misuse or damage caused by this program.
- Always respect the `Scope` and `Rules of Engagement` defined by the Bug Bounty platform.
- Rate limiting and safe scanning tags are enabled by default to prevent service disruption.

---

## 🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.

<div align="center">
  <b>Built by the Cybersecurity Community</b>
</div>

