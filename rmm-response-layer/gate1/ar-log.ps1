param([string]$InvocationId = '')
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$proofDir  = 'C:\Lab\response'
$scriptLog = Join-Path $proofDir 'ar-script.log'

function Write-ScriptEvent {
    param([string]$Line)
    try {
        if (-not (Test-Path -LiteralPath $proofDir -PathType Container)) { $null = New-Item -ItemType Directory -Force -Path $proofDir }
        Add-Content -LiteralPath $scriptLog -Encoding ascii -Value ("{0} {1}" -f (Get-Date).ToUniversalTime().ToString('o'), $Line)
    } catch {}
}

try {
    $raw = [Console]::In.ReadLine()
    $sha = if ($raw) { [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($raw))).Replace('-','') } else { 'none' }
    Write-ScriptEvent ("script-received invocation={0} payload_sha256={1}" -f $InvocationId, $sha)
    if ([string]::IsNullOrWhiteSpace($raw)) { throw 'empty stdin' }

    $message = $raw | ConvertFrom-Json
    $command = [string]$message.command
    $alert   = $message.parameters.alert
    $ruleId  = [string]$alert.rule.id
    $agent   = [string]$alert.agent.name

    if ($command -ne 'add')    { throw "unsupported command '$command'" }
    if ($ruleId  -ne '100212') { throw "unexpected rule '$ruleId'" }
    if ([string]::IsNullOrWhiteSpace($agent)) { throw 'missing agent name' }
    if ($raw -notmatch 'RUN-[0-9A-Za-z-]{1,64}') { throw 'missing or invalid RunId' }
    $runId = $Matches[0]
    Write-ScriptEvent ("script-parsed invocation={0} run={1} rule={2}" -f $InvocationId, $runId, $ruleId)

    $proofFile = Join-Path -Path $proofDir -ChildPath ("ar-{0}.log" -f $runId)
    if (Test-Path -LiteralPath $proofFile) { throw "proof already exists for '$runId'" }

    $line = "{0} host={1} rule={2} run={3} action={4} invocation={5}" -f (Get-Date).ToUniversalTime().ToString('o'), $agent, $ruleId, $runId, $command, $InvocationId
    Add-Content -LiteralPath $proofFile -Encoding ascii -Value $line

    exit 0
}
catch {
    Write-ScriptEvent ("script-error invocation={0} msg={1}" -f $InvocationId, (($_.Exception.Message -replace '[\r\n\t]+',' ').Trim()))
    exit 1
}
