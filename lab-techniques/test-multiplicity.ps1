# Fire Wazuh rule 100211 (MULTIPLICITY): two DIFFERENT RMM vendors on one host within 10 minutes.
# Gotcha: a tool already running may hand off to its running copy instead of creating a fresh
# process. Launch a fresh COPY from a no-space path so a new Event ID 1 is actually logged.
# Run elevated on the endpoint. Adjust paths.

$anydesk = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
$tv      = "C:\Program Files\TeamViewer\TeamViewer.exe"

# Vendor A
Start-Process $anydesk -ArgumentList "--control"; Start-Sleep 5
Stop-Process -Name AnyDesk -Force -ErrorAction SilentlyContinue

# Vendor B (fresh copy dodges the handoff)
Copy-Item $tv "$env:TEMP\tv-test.exe" -Force
Start-Process "$env:TEMP\tv-test.exe"; Start-Sleep 5
Remove-Item "$env:TEMP\tv-test.exe" -Force -ErrorAction SilentlyContinue

# NEGATIVE test (must NOT fire 100211): launch the SAME vendor twice instead of two vendors.
# Two 100210 hits, zero 100211. That precision is the edge over a plain "2 vendors in a window" rule.
