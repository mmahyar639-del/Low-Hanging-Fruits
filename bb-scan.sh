#!/bin/bash
# ============================================
# Low-Hanging Fruits (LHF) - Main Scanner
# Final Production-Ready Version (v1.1)
# Complete with All Features
# ============================================

set +H

# ---------- Global Variables ----------
LOG_FILE=""
SCAN_DIR=""
CLEAN_TARGET=""
LHF_HOME="$HOME/Low-Hanging-Fruits"

# ---------- Colors ----------
R='\e[1;31m'; G='\e[1;32m'; Y='\e[1;33m'
C='\e[1;36m'; B='\e[1;34m'; M='\e[1;35m'; N='\e[0m'

# ---------- Banner Function ----------
print_banner() {
    local target=$1
    echo -e "${M}"
    echo "  _     ____    ____  _  __       _____ _   _ _____ "
    echo " | |   |  _ \  / ___|| |/ /      |  ___| | | |_   _|"
    echo " | |   | | | | \___ \| ' /  _____| |_  | | | | | |  "
    echo " | |___| |_| |  ___) | . \ |_____|  _| | |_| | | |  "
    echo " |_____|____/  |____/|_|\_\      |_|    \___/  |_|  "
    echo -e "${N}"
    echo -e "${C}  Low-Hanging Fruits - Automated Bug Bounty Recon${N}"
    echo -e "${Y}  Target: ${B}${target}${N}"
    echo ""
}

# ---------- Help Function (COMPREHENSIVE) ----------
show_help() {
    print_banner "Help & Usage"
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "${B}USAGE:${N}"
    echo -e "  $0 <target.com>          Run scan on a specific target"
    echo -e "  $0 -b <target.com>       Run scan in the background (Recommended for VPS)"
    echo -e "  $0 -v, --view-report     View the latest scan report in browser"
    echo -e "  $0 -h, --help            Show this help message"
    echo ""
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "${B}EXAMPLES:${N}"
    echo -e "  $0 example.com"
    echo -e "  $0 https://api.example.com"
    echo -e "  $0 -b target.com"
    echo -e "  $0 -v"
    echo ""
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "${B}SCAN PHASES:${N}"
    echo -e "  ${G}1.${N} Subdomain Enumeration (subfinder, assetfinder)"
    echo -e "  ${G}2.${N} DNS Resolution & Filtering (dnsx)"
    echo -e "  ${G}3.${N} Smart Port Scanning (naabu)"
    echo -e "  ${G}4.${N} HTTP Probing & Tech Detection (httpx)"
    echo -e "  ${G}5.${N} Endpoint Discovery (gau, katana)"
    echo -e "  ${G}6.${N} Secret & API Key Detection (nuclei)"
    echo -e "  ${G}7.${N} Vulnerability Scanning (nuclei)"
    echo -e "  ${G}8.${N} Professional HTML Report Generation"
    echo ""
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "${B}BACKGROUND MODE:${N}"
    echo -e "  ${C}•${N} Use ${Y}-b${N} flag for long scans on VPS"
    echo -e "  ${C}•${N} Check progress: ${Y}tail -f ~/Low-Hanging-Fruits/logs/lhf_<target>_background.log${N}"
    echo -e "  ${C}•${N} Stop scan: ${Y}kill \$(cat ~/Low-Hanging-Fruits/tmp/lhf_<target>.pid)${N}"
    echo ""
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "${B}OUTPUT DIRECTORIES:${N}"
    echo -e "  ${C}•${N} Results: ${Y}~/Low-Hanging-Fruits/scans/<target>_<timestamp>/${N}"
    echo -e "  ${C}•${N} Reports: ${Y}~/Low-Hanging-Fruits/scans/<target>_<timestamp>/reports/${N}"
    echo -e "  ${C}•${N} Logs: ${Y}~/Low-Hanging-Fruits/logs/${N}"
    echo ""
    exit 0
}

# ---------- View Report Function ----------
view_report() {
    local last_scan_file="$LHF_HOME/tmp/last_scan_dir.txt"
    
    if [ ! -f "$last_scan_file" ]; then
        echo -e "${R}[✗] No previous scan found. Please run a scan first.${N}"
        exit 1
    fi
    
    local last_scan_dir=$(cat "$last_scan_file")
    local reports_dir="$last_scan_dir/reports"
    
    if [ ! -d "$reports_dir" ] || [ -z "$(ls -A "$reports_dir" 2>/dev/null)" ]; then
        echo -e "${R}[✗] No reports found in: $reports_dir${N}"
        exit 1
    fi
    
    # Get VPS IP
    local VPS_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || hostname -I | awk '{print $1}')
    
    print_banner "Report Viewer"
    echo -e "${B}[+] Starting HTTP server for report viewing...${N}"
    echo -e "${C}    Reports Directory: $reports_dir${N}"
    echo -e "${C}    Server Port: 8080${N}"
    echo ""
    echo -e "${G}[✓] Open this URL in your browser:${N}"
    echo -e "${Y}    http://$VPS_IP:8080${N}"
    echo ""
    echo -e "${C}[i] Press Ctrl+C to stop the server when done.${N}"
    echo ""
    
    # Start Python HTTP server
    cd "$reports_dir" && python3 -m http.server 8080
}

# ---------- Logging Function ----------
log() {
    local level=$1
    local msg=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local formatted_msg="[${timestamp}] [${level}] ${msg}"
    
    case $level in
        "INFO")    echo -e "${G}[+]${N} ${msg}" ;;
        "WARN")    echo -e "${Y}[!]${N} ${msg}" ;;
        "ERROR")   echo -e "${R}[✗]${N} ${msg}" ;;
        "STEP")    echo -e "${B}[*]${N} ${msg}" ;;
        "SUCCESS") echo -e "${M}[✓]${N} ${msg}" ;;
    esac
    
    if [ -n "$LOG_FILE" ]; then
        echo "$formatted_msg" >> "$LOG_FILE"
    fi
}

# ---------- Cleanup Function ----------
cleanup() {
    log "WARN" "Script interrupted! Running cleanup..."
    if [ -n "$SCAN_DIR" ]; then
        log "INFO" "Partial results are safely saved in: $SCAN_DIR"
    fi
    exit 0
}

# ---------- Load Configuration Function ----------
load_config() {
    local config_path="$LHF_HOME/config.conf"
    if [ -f "$config_path" ]; then
        source "$config_path"
        log "SUCCESS" "Configuration loaded from $config_path"
    else
        log "ERROR" "config.conf not found at $config_path"
        exit 1
    fi
}

# ---------- Setup Scan Directory Function ----------
setup_scan_dir() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local safe_target=$(echo "$CLEAN_TARGET" | sed 's/[^a-zA-Z0-9._-]/_/g')
    
    SCAN_DIR="$LHF_HOME/scans/${safe_target}_${timestamp}"
    mkdir -p "$SCAN_DIR"/{subs,ports,http,urls,vulns,secrets,screenshots,takeover,reports,tmp}
    
    LOG_FILE="$SCAN_DIR/execution.log"
    touch "$LOG_FILE"
    
    log "SUCCESS" "Scan directory created: $SCAN_DIR"
    echo "$SCAN_DIR" > "$LHF_HOME/tmp/last_scan_dir.txt"
}

# ---------- Domain Sanitization Function ----------
sanitize_domain() {
    local input=$1
    local clean=$(echo "$input" | sed -e 's|^http[s]*://||' -e 's|^www\.||' -e 's|/.*||')
    echo "$clean"
}

# ---------- Subdomain Enumeration Function ----------
run_subdomain_enum() {
    local domain=$1
    log "STEP" "Starting Subdomain Enumeration for: $domain"
    local subs_dir="$SCAN_DIR/subs"
    local master_subs="$subs_dir/all_subs.txt"
    
    # Always include root domain
    echo "$domain" | anew "$master_subs" > /dev/null
    
    log "INFO" "Running subfinder..."
    subfinder -d "$domain" -silent -o "$subs_dir/subfinder.txt" > /dev/null 2>&1
    cat "$subs_dir/subfinder.txt" 2>/dev/null | anew "$master_subs" > /dev/null
    
    log "INFO" "Running assetfinder..."
    assetfinder --subs-only "$domain" > "$subs_dir/assetfinder.txt" 2>/dev/null
    cat "$subs_dir/assetfinder.txt" 2>/dev/null | anew "$master_subs" > /dev/null
    
    if [ -f "$master_subs" ] && [ -s "$master_subs" ]; then
        log "SUCCESS" "Found $(wc -l < "$master_subs") unique targets (including root domain)."
    else
        log "WARN" "No targets found."
    fi
}

# ---------- DNS Resolution Function ----------
run_dns_resolution() {
    local domain=$1
    log "STEP" "Starting DNS Resolution & Filtering..."
    local subs_dir="$SCAN_DIR/subs"
    local master_subs="$subs_dir/all_subs.txt"
    local resolvers="$LHF_HOME/wordlists/resolvers.txt"
    
    if [ ! -s "$master_subs" ]; then
        log "WARN" "No targets to resolve. Skipping."
        return 1
    fi
    
    log "INFO" "Resolving subdomains using high-performance resolvers..."
    dnsx -l "$master_subs" -r "$resolvers" -silent -a -o "$subs_dir/resolved_subs.txt" > /dev/null 2>&1
    awk '{print $1}' "$subs_dir/resolved_subs.txt" | anew "$subs_dir/alive_subs.txt" > /dev/null
    
    if [ -s "$subs_dir/alive_subs.txt" ]; then
        log "SUCCESS" "DNS Resolution complete: $(wc -l < "$subs_dir/alive_subs.txt") targets are ALIVE."
    else
        log "WARN" "No alive targets found."
    fi
}

# ---------- Smart Port Scanning Function ----------
run_port_scanning() {
    local domain=$1
    log "STEP" "Starting Smart Port Scanning with naabu..."
    local subs_dir="$SCAN_DIR/subs"
    local ports_dir="$SCAN_DIR/ports"
    local alive_subs="$subs_dir/alive_subs.txt"
    
    if [ ! -s "$alive_subs" ]; then
        log "WARN" "No alive targets to scan. Skipping."
        return 1
    fi
    
    log "INFO" "Scanning for common web ports: $WEB_PORTS"
    naabu -l "$alive_subs" -p "$WEB_PORTS" -silent -o "$ports_dir/naabu_output.txt" > /dev/null 2>&1
    
    if [ -s "$ports_dir/naabu_output.txt" ]; then
        log "SUCCESS" "Port scan complete: Found $(wc -l < "$ports_dir/naabu_output.txt") open web ports."
    else
        log "WARN" "No open web ports found on alive targets."
    fi
}

# ---------- HTTP Probing Function ----------
run_http_probing() {
    local domain=$1
    log "STEP" "Starting HTTP Probing & Technology Detection..."
    local subs_dir="$SCAN_DIR/subs"
    local ports_dir="$SCAN_DIR/ports"
    local http_dir="$SCAN_DIR/http"
    
    local http_target="$subs_dir/alive_subs.txt"
    if [ -s "$ports_dir/naabu_output.txt" ]; then
        http_target="$ports_dir/naabu_output.txt"
        log "INFO" "Using naabu port results as target for httpx..."
    fi
    
    if [ ! -s "$http_target" ]; then
        log "WARN" "No targets to probe. Skipping HTTP probing."
        return 1
    fi
    
    log "INFO" "Probing targets with httpx (Status, Title, Tech)..."
    httpx -l "$http_target" -silent -status-code -title -tech-detect -content-length -threads "$THREADS" -timeout "$TIMEOUT" -o "$http_dir/httpx_full_output.txt" > /dev/null 2>&1
    
    if [ -s "$http_dir/httpx_full_output.txt" ]; then
        log "SUCCESS" "HTTP Probing complete: Found $(wc -l < "$http_dir/httpx_full_output.txt") active endpoints."
        
        log "INFO" "Filtering valid HTTP URLs for further scanning..."
        httpx -l "$http_target" -silent -mc 200,301,302,403,404,500 -threads "$THREADS" -timeout "$TIMEOUT" -o "$http_dir/valid_http_urls.txt" > /dev/null 2>&1
        log "SUCCESS" "Filtered $(wc -l < "$http_dir/valid_http_urls.txt") valid HTTP URLs."
    else
        log "WARN" "No HTTP/HTTPS services found."
    fi
}

# ---------- Endpoint Discovery Function ----------
run_endpoint_discovery() {
    local domain=$1
    log "STEP" "Starting URL & Endpoint Discovery..."
    local http_dir="$SCAN_DIR/http"
    local urls_dir="$SCAN_DIR/urls"
    local valid_urls="$http_dir/valid_http_urls.txt"
    
    if [ ! -s "$valid_urls" ]; then
        log "WARN" "No valid HTTP URLs found. Skipping endpoint discovery."
        return 1
    fi
    
    log "INFO" "Running passive discovery with gau..."
    cat "$valid_urls" | gau --subs -o "$urls_dir/gau_urls.txt" > /dev/null 2>&1
    
    log "INFO" "Running active crawling with katana..."
    katana -l "$valid_urls" -d 2 -jc -silent -o "$urls_dir/katana_urls.txt" > /dev/null 2>&1
    
    log "INFO" "Merging and deduplicating URLs..."
    cat "$urls_dir/gau_urls.txt" "$urls_dir/katana_urls.txt" 2>/dev/null | anew "$urls_dir/all_urls.txt" > /dev/null
    
    if [ -s "$urls_dir/all_urls.txt" ]; then
        log "SUCCESS" "Endpoint discovery complete: Found $(wc -l < "$urls_dir/all_urls.txt") unique URLs."
        grep -iE '\.js$|\.json$|\.env$|\.bak$|api/|admin/|config\.|\.git/' "$urls_dir/all_urls.txt" | anew "$urls_dir/interesting_urls.txt" > /dev/null
        
        if [ -s "$urls_dir/interesting_urls.txt" ]; then
            log "SUCCESS" "Found $(wc -l < "$urls_dir/interesting_urls.txt") potentially interesting URLs (JS, API, Configs)."
        fi
    else
        log "INFO" "No new URLs discovered by gau or katana. Proceeding with base URLs."
    fi
}

# ---------- Secret Detection Function ----------
run_secret_detection() {
    local domain=$1
    log "STEP" "Starting Secret & API Key Detection..."
    local http_dir="$SCAN_DIR/http"
    local urls_dir="$SCAN_DIR/urls"
    local secrets_dir="$SCAN_DIR/secrets"
    local valid_urls="$http_dir/valid_http_urls.txt"
    
    if [ ! -s "$valid_urls" ]; then
        log "WARN" "No valid HTTP URLs to scan for secrets. Skipping."
        return 1
    fi
    
    log "INFO" "Searching specifically for JavaScript files..."
    katana -l "$valid_urls" -d 2 -jc -silent -ext js -o "$urls_dir/js_files.txt" > /dev/null 2>&1
    
    cat "$valid_urls" "$urls_dir/js_files.txt" 2>/dev/null | anew "$secrets_dir/nuclei_targets.txt" > /dev/null
    
    log "INFO" "Running Nuclei for Secret, Token & Exposure detection..."
    nuclei -l "$secrets_dir/nuclei_targets.txt" -tags secret,exposure,token -silent -timeout "$TIMEOUT" -o "$secrets_dir/nuclei_secrets.txt" > /dev/null 2>&1
    
    if [ -s "$secrets_dir/nuclei_secrets.txt" ]; then
        log "SUCCESS" "🚨 Found $(wc -l < "$secrets_dir/nuclei_secrets.txt") potential secrets/exposures!"
        log "INFO" "Check results at: $secrets_dir/nuclei_secrets.txt"
    else
        log "INFO" "No obvious secrets or exposures found by Nuclei."
    fi
}

# ---------- Vulnerability Scanning Function ----------
run_vulnerability_scanning() {
    local domain=$1
    log "STEP" "Starting General Vulnerability Scanning..."
    local http_dir="$SCAN_DIR/http"
    local vulns_dir="$SCAN_DIR/vulns"
    local valid_urls="$http_dir/valid_http_urls.txt"
    
    if [ ! -s "$valid_urls" ]; then
        log "WARN" "No valid HTTP URLs to scan. Skipping vulnerability scan."
        return 1
    fi
    
    log "INFO" "Running Nuclei (Medium, High, Critical) excluding noisy tags..."
    nuclei -l "$valid_urls" -severity medium,high,critical -exclude-tags fuzz,dos,intrusive,network -silent -timeout "$TIMEOUT" -rate-limit "$RATE_LIMIT" -o "$vulns_dir/nuclei_vulns.txt" > /dev/null 2>&1
    
    if [ -s "$vulns_dir/nuclei_vulns.txt" ]; then
        local total=$(wc -l < "$vulns_dir/nuclei_vulns.txt")
        local high_crit=$(grep -iE '\[high\]|\[critical\]' "$vulns_dir/nuclei_vulns.txt" | wc -l)
        local medium=$(grep -i '\[medium\]' "$vulns_dir/nuclei_vulns.txt" | wc -l)
        log "SUCCESS" "🚨 Vulnerability scan complete: Found $total potential issues!"
        log "INFO" "Breakdown: $high_crit High/Critical, $medium Medium."
        log "INFO" "Detailed results saved to: $vulns_dir/nuclei_vulns.txt"
    else
        log "INFO" "No medium/high/critical vulnerabilities found. Target appears secure against automated checks."
    fi
}

# ---------- Professional HTML Report Generation ----------
generate_report() {
    local target=$1
    log "STEP" "Generating Professional HTML Report..."
    local reports_dir="$SCAN_DIR/reports"
    local vulns_file="$SCAN_DIR/vulns/nuclei_vulns.txt"
    local secrets_file="$SCAN_DIR/secrets/nuclei_secrets.txt"
    local report_file="$reports_dir/LHF_Report_${CLEAN_TARGET}.html"
    local date_now=$(date +"%Y-%m-%d %H:%M:%S")
    
    cat << EOF > "$report_file"
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>LHF Scan Report - ${target}</title>
<style>body{font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background-color:#f4f7f6;color:#333;margin:0;padding:20px}.container{max-width:1000px;margin:0 auto;background:#fff;padding:30px;border-radius:8px;box-shadow:0 4px 6px rgba(0,0,0,0.1)}h1{color:#2c3e50;border-bottom:2px solid #3498db;padding-bottom:10px}h2{color:#2980b9;margin-top:30px}.meta{background:#ecf0f1;padding:15px;border-radius:5px;margin-bottom:20px}.meta p{margin:5px 0}table{width:100%;border-collapse:collapse;margin-top:15px}th,td{padding:12px;text-align:left;border-bottom:1px solid #ddd}th{background-color:#34495e;color:white}.severity-critical{color:#e74c3c;font-weight:bold}.severity-high{color:#e67e22;font-weight:bold}.severity-medium{color:#f1c40f;font-weight:bold}.severity-low{color:#3498db;font-weight:bold}.severity-info{color:#95a5a6}.footer{margin-top:40px;text-align:center;color:#7f8c8d;font-size:0.9em}</style>
</head><body><div class="container"><h1>🛡️ Low-Hanging Fruits (LHF) Security Report</h1>
<div class="meta"><p><strong>Target:</strong> ${target}</p><p><strong>Scan Date:</strong> ${date_now}</p><p><strong>Scanner Version:</strong> LHF v1.1 (Automated Recon)</p></div>
<h2>📊 Executive Summary</h2><p>This report was automatically generated by the LHF automation engine.</p>
EOF

    if [ -s "$vulns_file" ] || [ -s "$secrets_file" ]; then
        echo "<h2>🚨 Identified Findings</h2><table><tr><th>Severity</th><th>Template</th><th>Type</th><th>URL</th></tr>" >> "$report_file"
        cat "$vulns_file" "$secrets_file" 2>/dev/null | sort | while read -r line; do
            severity=$(echo "$line" | awk -F'[][]' '{print $4}' | tr '[:upper:]' '[:lower:]')
            template=$(echo "$line" | awk -F'[][]' '{print $2}')
            rest=$(echo "$line" | sed 's/^\[[^]]*\][^[]*\[[^]]*\][^[]*\[[^]]*\] //')
            url=$(echo "$rest" | awk '{print $NF}')
            type=$(echo "$rest" | sed "s/ $url//")
            case "$severity" in critical) sev_class="severity-critical" ;; high) sev_class="severity-high" ;; medium) sev_class="severity-medium" ;; low) sev_class="severity-low" ;; *) sev_class="severity-info" ;; esac
            echo "<tr><td class=\"$sev_class\">${severity^^}</td><td>${template}</td><td>${type}</td><td><a href=\"${url}\" target=\"_blank\">${url}</a></td></tr>" >> "$report_file"
        done
        echo "</table>" >> "$report_file"
    else
        echo "<h2>✅ Security Posture</h2><p style=\"color: green; font-weight: bold;\">No medium, high, or critical vulnerabilities detected.</p>" >> "$report_file"
    fi

    cat << EOF >> "$report_file"
<h2>📝 Recommendations</h2><ul><li><strong>Remediation:</strong> Review identified endpoints and apply appropriate security controls.</li><li><strong>False Positives:</strong> Manual verification is always recommended before remediation.</li></ul>
<div class="footer"><p>Generated by <strong>Low-Hanging Fruits (LHF) v1.1</strong></p></div></div></body></html>
EOF
    log "SUCCESS" "Professional HTML Report generated at: $report_file"
}

# ---------- Main Logic Function ----------
main() {
    # 1. Handle Help Flag
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
    fi

    # 2. Handle View Report Flag
    if [[ "$1" == "-v" || "$1" == "--view-report" ]]; then
        view_report
        exit 0
    fi

    # 3. Handle No Arguments
    if [ -z "$1" ]; then
        show_help
    fi

    # 4. Handle Background Flag
    if [[ "$1" == "-b" || "$1" == "--background" ]]; then
        shift
        TARGET="$1"
        if [ -z "$TARGET" ]; then
            echo -e "${R}[✗] Error: No target specified for background mode.${N}"
            echo -e "${Y}Usage: $0 -b <target.com>${N}"
            exit 1
        fi
        
        CLEAN_TARGET=$(echo "$TARGET" | sed -e 's|^http[s]*://||' -e 's|^www\.||' -e 's|/.*||')
        BG_LOG_FILE="$LHF_HOME/logs/lhf_${CLEAN_TARGET}_background.log"
        mkdir -p "$LHF_HOME/logs"
        mkdir -p "$LHF_HOME/tmp"
        
        print_banner "$TARGET"
        echo -e "${Y}[*] Starting LHF in background mode...${N}"
        echo -e "${Y}[*] Target: ${CLEAN_TARGET}${N}"
        echo -e "${Y}[*] Logs will be saved to: $BG_LOG_FILE${N}"
        echo -e "${G}[✓] Process started in background! You can safely close this terminal.${N}"
        echo -e "${C}[i] To check progress: tail -f $BG_LOG_FILE${N}"
        echo $$ > "$LHF_HOME/tmp/lhf_${CLEAN_TARGET}.pid"
        echo -e "${C}[i] To stop the scan: kill \$(cat $LHF_HOME/tmp/lhf_${CLEAN_TARGET}.pid)${N}"
        
        nohup "$0" "$TARGET" > "$BG_LOG_FILE" 2>&1 &
        exit 0
    fi

    # 5. Normal Execution Flow
    TARGET="$1"
    trap cleanup SIGINT SIGTERM
    
    print_banner "$TARGET"
    load_config
    
    CLEAN_TARGET=$(sanitize_domain "$TARGET")
    log "INFO" "Sanitized target for recon: $CLEAN_TARGET"
    setup_scan_dir
    
    echo ""
    log "STEP" "Engine initialized successfully."
    log "INFO" "Profile: $PROFILE | Threads: $THREADS"
    echo ""
    
    run_subdomain_enum "$CLEAN_TARGET"
    echo ""
    run_dns_resolution "$CLEAN_TARGET"
    echo ""
    run_port_scanning "$CLEAN_TARGET"
    echo ""
    run_http_probing "$CLEAN_TARGET"
    echo ""
    run_endpoint_discovery "$CLEAN_TARGET"
    echo ""
    run_secret_detection "$CLEAN_TARGET"
    echo ""
    run_vulnerability_scanning "$CLEAN_TARGET"
    echo ""
    
    generate_report "$CLEAN_TARGET"
    
    echo ""
    log "SUCCESS" "🎉 LHF Scan Completed Successfully!"
    log "INFO" "All results are saved in: $SCAN_DIR"
    echo ""
    echo -e "${C}[i] To view the report in your browser, run: $0 -v${N}"
}

main "$@"
