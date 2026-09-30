[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$serviceName = 'rmm-g6-service'
$paths = @('C:\Users\Public\g6masq', 'C:\Users\Public\g6service')

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($service) {
    if ($service.Status -ne 'Stopped') {
        Stop-Service -Name $serviceName -Force
    }
    & sc.exe delete $serviceName | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "sc.exe delete returned exit code $LASTEXITCODE"
    }
}

foreach ($path in $paths) {
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
    }
}

Start-Sleep -Seconds 1
[pscustomobject]@{
    ServiceAbsent = -not [bool](Get-Service -Name $serviceName -ErrorAction SilentlyContinue)
    MasqueradeDirectoryAbsent = -not (Test-Path -LiteralPath $paths[0])
    ServiceDirectoryAbsent = -not (Test-Path -LiteralPath $paths[1])
} | ConvertTo-Json -Compress
