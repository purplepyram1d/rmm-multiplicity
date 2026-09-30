#Requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateSet('Positive','OneVendorNegative')]
    [string]$Mode = 'Positive',
    [string]$AnyDeskPath = 'C:\Program Files (x86)\AnyDesk\AnyDesk.exe',
    [string]$TeamViewerPath = 'C:\Program Files\TeamViewer\TeamViewer.exe'
)

foreach ($path in $AnyDeskPath,$TeamViewerPath) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required RMM binary not found: $path"
    }
}

Get-Process -Name AnyDesk,TeamViewer,tv_w32,tv_x64 -ErrorAction SilentlyContinue |
    Stop-Process -Force -ErrorAction SilentlyContinue

if ($Mode -eq 'Positive') {
    # Two vendors on one host inside 600 seconds: expect 100210 and then 100211.
    Start-Process -FilePath $AnyDeskPath -ArgumentList '--control'
    Start-Sleep -Seconds 5
    Start-Process -FilePath $TeamViewerPath
    Start-Sleep -Seconds 10
    Write-Host 'Expected: rule 100211. Several TeamViewer processes may produce several composite alerts.' -ForegroundColor Cyan
} else {
    # Prepare SIEM01 first: restart Wazuh and confirm WS01 reconnects so prior composite
    # state cannot satisfy the test. This endpoint helper cannot perform that manager step.
    Write-Warning 'Before this mode, clear Wazuh composite state on SIEM01 and confirm WS01 reconnects.'
    Start-Process -FilePath $TeamViewerPath
    Start-Sleep -Seconds 5
    Start-Process -FilePath $TeamViewerPath
    Start-Sleep -Seconds 10
    Write-Host 'Expected: one-vendor 100210 events and zero new 100211 alerts.' -ForegroundColor Cyan
}

Get-Process -Name AnyDesk,TeamViewer,tv_w32,tv_x64 -ErrorAction SilentlyContinue |
    Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host 'Verify the bounded UTC window in alerts.json; do not infer the result from process count.' -ForegroundColor Cyan
