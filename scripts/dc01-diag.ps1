# DC01 full pipeline diagnostic (agent side). Read-only. Output: C:\dc01-diag.txt
$r = @()
$r += "================================================================"
$r += "DC01 DIAGNOSTIC  $(Get-Date)"
$r += "host: $(hostname)   user: $(whoami)"
$r += "================================================================"

$r += ""
$r += "### 1. WAZUH AGENT SERVICE ###"
$svc = Get-Service WazuhSvc -ErrorAction SilentlyContinue
if ($svc) { $r += ("WazuhSvc: " + $svc.Status) } else { $r += "WazuhSvc NOT INSTALLED" }
$verFile = "C:\Program Files (x86)\ossec-agent\VERSION.json"
$verOld  = "C:\Program Files (x86)\ossec-agent\VERSION"
if (Test-Path $verFile) { $r += ("agent version: " + (Get-Content $verFile -Raw).Trim()) } elseif (Test-Path $verOld) { $r += ("agent version: " + (Get-Content $verOld -Raw).Trim()) } else { $r += "agent version file not found" }

$r += ""
$r += "### 2. MANAGER ADDRESS IN ossec.conf (should be 10.10.10.5) ###"
$r += (Select-String -Path "C:\Program Files (x86)\ossec-agent\ossec.conf" -Pattern "<address>","<server>" | ForEach-Object { $_.Line.Trim() })

$r += ""
$r += "### 3. SYSMON SERVICE ###"
$sm = Get-Service -Name "Sysmon*" -ErrorAction SilentlyContinue
if ($sm) { foreach ($s in $sm) { $r += ($s.Name + ": " + $s.Status) } } else { $r += "Sysmon service NOT FOUND" }

$r += ""
$r += "### 4. SYSMON localfile BLOCK IN ossec.conf (agent must read the channel) ###"
$sysline = Select-String -Path "C:\Program Files (x86)\ossec-agent\ossec.conf" -Pattern "Sysmon/Operational"
if ($sysline) { $r += "PRESENT: $($sysline.Line.Trim())" } else { $r += "MISSING - agent is NOT collecting Sysmon" }

$r += ""
$r += "### 5. AGENT LOG: last manager connect + Sysmon subscription ###"
$log = "C:\Program Files (x86)\ossec-agent\ossec.log"
$r += (Select-String -Path $log -Pattern "Connected to" | Select-Object -Last 1 | ForEach-Object { $_.Line.Trim() })
$r += (Select-String -Path $log -Pattern "Sysmon" | Select-Object -Last 2 | ForEach-Object { $_.Line.Trim() })

$r += ""
$r += "### 6. LOCAL SYSMON EID1 (Sysmon sees process creates at all?) ###"
try { $ev = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';Id=1} -MaxEvents 5 -ErrorAction Stop; $r += ("last 5 EID1 times: " + (($ev | ForEach-Object { $_.TimeCreated.ToString('HH:mm:ss') }) -join ', ')) } catch { $r += "NO EID1 EVENTS (Sysmon not logging process creates)" }

$r += ""
$r += "### 7. LOCAL SYSMON EID1 FOR ANYDESK (the RMM test event) ###"
try { $ad = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';Id=1} -MaxEvents 50 -ErrorAction Stop | Where-Object { $_.Message -like '*AnyDesk*' } | Select-Object -First 1; if ($ad) { $r += ("AnyDesk EID1 found at " + $ad.TimeCreated) } else { $r += "no recent AnyDesk EID1 (launch it to generate one)" } } catch { $r += "query failed" }

$r += ""
$r += "### 8. ANYDESK INSTALL + COMPANY METADATA (the rule anchor) ###"
$adexe = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
if (Test-Path $adexe) { $vi = (Get-Item $adexe).VersionInfo; $r += ("AnyDesk.exe present  CompanyName: " + $vi.CompanyName + "  OriginalFilename: " + $vi.OriginalFilename) } else { $r += "AnyDesk.exe NOT at $adexe (rule anchor untestable)" }

$r += ""
$r += "### 9. CONNECTIVITY TO MANAGER (1514 stream, 1515 enroll) ###"
$c14 = (Test-NetConnection 10.10.10.5 -Port 1514 -WarningAction SilentlyContinue).TcpTestSucceeded
$c15 = (Test-NetConnection 10.10.10.5 -Port 1515 -WarningAction SilentlyContinue).TcpTestSucceeded
$r += ("1514 (event stream): " + $c14)
$r += ("1515 (enrollment):   " + $c15)

$r += ""
$r += "================================================================"
$r += "DC01 DIAGNOSTIC COMPLETE"
$r += "================================================================"

$r | Tee-Object -FilePath C:\dc01-diag.txt
