# Fire rule 100212 (one RMM launched a DIFFERENT one). Add -AsSystem to also fire 100214
# (the spawn ran as SYSTEM - the "a service deployed it, not a person" tell).
# Trick: a stand-in parent (cmd renamed to AnyDesk.exe) launches a fresh copy of TeamViewer,
# so Sysmon records the parent-child as RMM-A -> RMM-B. No-space paths so cmd does not mangle it.
# Run elevated on the endpoint. Adjust the TeamViewer source path.
param([switch]$AsSystem)

$parent = "C:\Windows\Temp\AnyDesk.exe"      # really cmd, wearing an AnyDesk name (the "parent RMM")
$child  = "C:\Windows\Temp\TeamViewer.exe"   # fresh copy of a real RMM (the "child")
Copy-Item C:\Windows\System32\cmd.exe $parent -Force
Copy-Item "C:\Program Files\TeamViewer\TeamViewer.exe" $child -Force

if ($AsSystem) {
  if (-not (Test-Path "$env:TEMP\PsExec64.exe")) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest "https://live.sysinternals.com/PsExec64.exe" -OutFile "$env:TEMP\PsExec64.exe" -UseBasicParsing
  }
  & "$env:TEMP\PsExec64.exe" -accepteula -s -d $parent /c $child   # -s = run as SYSTEM
} else {
  Start-Process -FilePath $parent -ArgumentList '/c',$child         # parent launches child
}
Start-Sleep 5

# Cleanup - a cmd renamed AnyDesk.exe in Temp is itself suspicious; do not leave it.
Remove-Item $parent,$child -Force -ErrorAction SilentlyContinue
if ($AsSystem) { sc.exe stop PSEXESVC | Out-Null; sc.exe delete PSEXESVC | Out-Null }
