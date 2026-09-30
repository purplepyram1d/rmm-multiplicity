#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$AnyDeskPath = 'C:\Program Files (x86)\AnyDesk\AnyDesk.exe',
    [string]$LabDirectory = 'C:\Lab'
)

if (-not (Test-Path -LiteralPath $AnyDeskPath -PathType Leaf)) {
    throw "AnyDesk binary not found: $AnyDeskPath"
}

$stagedPath = Join-Path $LabDirectory 'totally_legit.exe'
New-Item -ItemType Directory -Path $LabDirectory -Force | Out-Null

try {
    # Normal launch: rule 100210 should identify AnyDesk from PE Company metadata.
    $normal = Start-Process -FilePath $AnyDeskPath -ArgumentList '--control' -PassThru
    Start-Sleep -Seconds 4
    Get-Process -Name AnyDesk -ErrorAction SilentlyContinue | Stop-Process -Force

    # Rename-proof launch: the filesystem label changes, the embedded Company does not.
    Copy-Item -LiteralPath $AnyDeskPath -Destination $stagedPath -Force
    $metadata = (Get-Item -LiteralPath $stagedPath).VersionInfo
    [pscustomobject]@{
        StagedPath = $stagedPath
        Company = $metadata.CompanyName
        OriginalFilename = $metadata.OriginalFilename
        ExpectedRule = 100210
    }

    $renamed = Start-Process -FilePath $stagedPath -ArgumentList '--control' -PassThru
    Start-Sleep -Seconds 4
    Get-Process -Id $renamed.Id -ErrorAction SilentlyContinue | Stop-Process -Force
} finally {
    Remove-Item -LiteralPath $stagedPath -Force -ErrorAction SilentlyContinue
    if ((Test-Path -LiteralPath $LabDirectory) -and -not (Get-ChildItem -LiteralPath $LabDirectory -Force)) {
        Remove-Item -LiteralPath $LabDirectory -Force
    }
}

Write-Host 'Verify the named Sysmon Image/Company fields locally, then rule 100210 in Wazuh.' -ForegroundColor Cyan
