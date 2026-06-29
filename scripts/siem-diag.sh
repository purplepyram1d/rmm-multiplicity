#!/bin/bash
# SIEM01 full pipeline diagnostic (manager side). Read-only. Run: sudo bash /mnt/external/siem-diag.sh
OUT=/tmp/siem-diag.txt
exec > >(tee "$OUT") 2>&1
echo "================================================================"
echo "SIEM01 DIAGNOSTIC  $(date)"
echo "host: $(hostname)   user: $(whoami)"
echo "================================================================"

echo; echo "### 1. SERVICES (manager / indexer / dashboard / filebeat) ###"
for s in wazuh-manager wazuh-indexer wazuh-dashboard filebeat; do printf "%-20s %s\n" "$s" "$(systemctl is-active $s 2>/dev/null)"; done

echo; echo "### 2. LISTENERS (1514 agent, 1515 enroll, 9200 indexer, 55000 api, 443 dash) ###"
ss -tulpn 2>/dev/null | grep -E ':1514|:1515|:9200|:55000|:443' || echo "NO MATCHING LISTENERS"

echo; echo "### 3. ENROLLED AGENTS (agent_control -l) ###"
/var/ossec/bin/agent_control -l 2>/dev/null || echo "agent_control failed"

echo; echo "### 4. logall_json SETTING (should be yes while testing) ###"
grep -n "logall_json" /var/ossec/etc/ossec.conf || echo "logall_json NOT FOUND in ossec.conf"

echo; echo "### 5. ARCHIVES file (every event, needs logall_json=yes) ###"
ls -lh /var/ossec/logs/archives/archives.json 2>/dev/null || echo "archives.json MISSING"

echo; echo "### 6. ALERTS file (rule matches only) ###"
ls -lh /var/ossec/logs/alerts/alerts.json 2>/dev/null || echo "alerts.json MISSING"

echo; echo "### 7. CUSTOM RMM RULES (100210 base, 100211 multiplicity) ###"
if ls /var/ossec/etc/rules/rmm_detection.xml >/dev/null 2>&1; then echo "rmm_detection.xml PRESENT:"; grep -E 'rule id=' /var/ossec/etc/rules/rmm_detection.xml; else echo "rmm_detection.xml NOT DEPLOYED YET"; fi
echo "--- any 1002xx rule anywhere in rules dir ---"
grep -rlE 'rule id="1002' /var/ossec/etc/rules/ 2>/dev/null || echo "none"

echo; echo "### 8. RECENT DC01 SYSMON EID1 IN ARCHIVE (last 5 images, via jq) ###"
grep '"name":"DC01"' /var/ossec/logs/archives/archives.json 2>/dev/null | jq -rc 'select(.data.win.system.eventID=="1") | .data.win.eventdata.image' 2>/dev/null | tail -5 || echo "no DC01 EID1 found in archive"

echo; echo "### 9. DECODER FIELD CHECK (last DC01 EID1: company/image/computer extracted?) ###"
grep '"name":"DC01"' /var/ossec/logs/archives/archives.json 2>/dev/null | jq -rc 'select(.data.win.system.eventID=="1") | {company: .data.win.eventdata.company, image: .data.win.eventdata.image, computer: .data.win.system.computer}' 2>/dev/null | tail -1 || echo "decoder field extraction FAILED"

echo; echo "### 10. RMM EVENTS IN ARCHIVE (company-anchored, last 5 vendors seen) ###"
grep '"name":"DC01"' /var/ossec/logs/archives/archives.json 2>/dev/null | jq -rc 'select(.data.win.system.eventID=="1") | .data.win.eventdata.company' 2>/dev/null | grep -iE 'anydesk|screenconnect|teamviewer|atera' | tail -5 || echo "no RMM-vendor company values seen yet"

echo; echo "### 11. FIREWALL (ufw) ###"
ufw status 2>/dev/null || echo "ufw not active/installed"

echo; echo "### 12. DISK (80GB box, archives grow fast) ###"
df -h / 2>/dev/null

echo; echo "### 13. MEMORY (8GB box, indexer heap is the risk) ###"
free -h

echo; echo "### 14. INDEXER HEAP CONFIG ###"
grep -E '^-Xm' /etc/wazuh-indexer/jvm.options 2>/dev/null || echo "jvm.options heap lines not found"

echo; echo "================================================================"
echo "SIEM01 DIAGNOSTIC COMPLETE"
echo "================================================================"
cp /tmp/siem-diag.txt "/mnt/external/02 Lab Work/output/siem-diag.txt" 2>/dev/null && echo "report copied to 02 Lab Work/output/siem-diag.txt" || echo "share copy failed; report at /tmp/siem-diag.txt"
