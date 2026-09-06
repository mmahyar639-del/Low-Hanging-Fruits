#!/bin/bash
# ============================================
# LHF - Automated Installation Script
# ============================================

echo -e "\e[1;34m[+] Starting Low-Hanging Fruits (LHF) Installation...\e[0m"

# 1. Update System & Install Base Dependencies
echo -e "\e[1;33m[*] Updating system and installing base dependencies...\e[0m"
sudo apt update && sudo apt install -y git curl wget python3 build-essential

# 2. Install Go (if not already installed)
if ! command -v go &> /dev/null; then
    echo -e "\e[1;33m[*] Installing Go language...\e[0m"
    wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
    source ~/.bashrc
    rm -f go1.21.0.linux-amd64.tar.gz
else
    echo -e "\e[1;32m[✓] Go is already installed.\e[0m"
fi

# 3. Install Security Tools via Go
echo -e "\e[1;33m[*] Installing ProjectDiscovery & other security tools...\e[0m"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/tomnomnom/anew@latest

# 4. Update Nuclei Templates
echo -e "\e[1;33m[*] Updating Nuclei templates...\e[0m"
nuclei -ut > /dev/null 2>&1

# 5. Create Default Configuration File (if it doesn't exist)
if [ ! -f "config.conf" ]; then
    echo -e "\e[1;33m[*] Creating default config.conf...\e[0m"
    cat << 'EOF' > config.conf
PROFILE="VPS"
THREADS=50
TIMEOUT=10
RATE_LIMIT=150
WEB_PORTS="80,443,8080,8443,8000,8888,3000,9090"
EOF
else
    echo -e "\e[1;32m[✓] config.conf already exists.\e[0m"
fi

# 6. Set Permissions
chmod +x bb-scan.sh

echo -e "\e[1;32m\n[✓] Installation Completed Successfully!\e[0m"
echo -e "\e[1;36m[i] You can now run: ./bb-scan.sh -h\e[0m\n"
