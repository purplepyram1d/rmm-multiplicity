$ErrorActionPreference = 'Stop'
$serviceName = 'rmm-g5-reversal'
$results = [System.Collections.Generic.List[object]]::new()

function Add-Result {
    param([string]$Step, [string]$Observed, [string]$Result)
    $results.Add([pscustomobject]@{
        TimeUtc = [DateTime]::UtcNow.ToString('o')
        Step = $Step
        Observed = $Observed
        Result = $Result
    })
}

try {
    if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
        throw "Refusing to reuse existing service $serviceName"
    }

    $create = & sc.exe create $serviceName binPath= 'C:\Windows\System32\cmd.exe /c exit 0' start= demand 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Create failed: $create" }
    Add-Result 'create' (($create -join ' ').Trim()) 'PASS'

    & sc.exe config $serviceName start= disabled | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Disable failed' }
    $disabledStart = (Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName").Start
    Add-Result 'disable' "Registry Start=$disabledStart" $(if ($disabledStart -eq 4) { 'PASS' } else { 'FAIL' })
    if ($disabledStart -ne 4) { throw 'Disabled state did not validate' }

    & sc.exe config $serviceName start= demand | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Restore to demand failed' }
    $restoredStart = (Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName").Start
    Add-Result 'restore' "Registry Start=$restoredStart" $(if ($restoredStart -eq 3) { 'PASS' } else { 'FAIL' })
    if ($restoredStart -ne 3) { throw 'Restored state did not validate' }
}
finally {
    if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
        & sc.exe delete $serviceName | Out-Null
        Start-Sleep -Milliseconds 500
    }
    $present = [bool](Get-Service -Name $serviceName -ErrorAction SilentlyContinue)
    Add-Result 'cleanup' "ServicePresent=$present" $(if (-not $present) { 'PASS' } else { 'FAIL' })
}

$results | ConvertTo-Json
