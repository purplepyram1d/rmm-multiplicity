[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^RUN-[0-9]{8}-G6[A-Z0-9-]+$')]
    [string]$RunId,

    [Parameter(Mandatory)]
    [string]$SourceFile,

    [Parameter(Mandatory)]
    [string]$CloudflaredFile
)

$ErrorActionPreference = 'Stop'
$serviceName = 'rmm-g6-service'
$masqDirectory = 'C:\Users\Public\g6masq'
$serviceDirectory = 'C:\Users\Public\g6service'
$masqBinary = Join-Path $masqDirectory 'svchost.exe'
$serviceBinary = Join-Path $serviceDirectory 'cloudflared.exe'

if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    throw "Refusing to continue because service $serviceName already exists."
}

foreach ($path in @($masqDirectory, $serviceDirectory)) {
    if (Test-Path -LiteralPath $path) {
        throw "Refusing to continue because fixture path already exists: $path"
    }
}

if (-not (Test-Path -LiteralPath $SourceFile -PathType Leaf)) {
    throw "Fixture source is missing: $SourceFile"
}

if (-not (Test-Path -LiteralPath $CloudflaredFile -PathType Leaf)) {
    throw "Cloudflared fixture is missing: $CloudflaredFile"
}

New-Item -ItemType Directory -Path $masqDirectory, $serviceDirectory | Out-Null
Copy-Item -LiteralPath $SourceFile -Destination (Join-Path $masqDirectory 'svchostfix.cs')
Copy-Item -LiteralPath $CloudflaredFile -Destination $serviceBinary

$compiler = Join-Path ([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) 'csc.exe'
if (-not (Test-Path -LiteralPath $compiler -PathType Leaf)) {
    throw "C# compiler is missing: $compiler"
}

Push-Location $masqDirectory
try {
    & $compiler /nologo /target:exe /platform:x64 /out:svchost.exe svchostfix.cs
    if ($LASTEXITCODE -ne 0) {
        throw "csc.exe returned exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

$masqHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $masqBinary).Hash
$serviceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $serviceBinary).Hash

& $masqBinary $RunId
if ($LASTEXITCODE -ne 0) {
    throw "Masquerade fixture returned exit code $LASTEXITCODE"
}

$binaryPath = ('"{0}" {1}' -f $serviceBinary, $RunId)
New-Service -Name $serviceName -BinaryPathName $binaryPath -DisplayName 'Gate 6 Service Registration Fixture' -StartupType Manual | Out-Null

$service = Get-CimInstance Win32_Service -Filter "Name='$serviceName'"
[pscustomobject]@{
    RunId = $RunId
    Hostname = $env:COMPUTERNAME
    MasqueradePath = $masqBinary
    MasqueradeSha256 = $masqHash
    MasqueradeExitCode = 0
    ServiceName = $serviceName
    ServicePath = $service.PathName
    ServiceStartMode = $service.StartMode
    ServiceState = $service.State
    ServiceAccount = $service.StartName
    ServiceBinarySha256 = $serviceHash
} | ConvertTo-Json -Depth 4
