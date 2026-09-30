#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [switch]$AsSystem,
    [switch]$Cleanup,
    [string]$TeamViewerPath = 'C:\Program Files\TeamViewer\TeamViewer.exe',
    [string]$LabDirectory = 'C:\Lab',
    [string]$TaskName = 'RMM-Causal-System-Test'
)

$parent = Join-Path $LabDirectory 'AnyDesk.exe'
$child = Join-Path $LabDirectory 'TeamViewer.exe'

if ($Cleanup) {
    if ($PSCmdlet.ShouldProcess($TaskName,'Delete the lab scheduled task')) {
        & schtasks.exe /delete /tn $TaskName /f 2>$null | Out-Null
    }
    if ($PSCmdlet.ShouldProcess($LabDirectory,'Remove the causal-test staging directory')) {
        Remove-Item -LiteralPath $LabDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
    return
}

if (-not (Test-Path -LiteralPath $TeamViewerPath -PathType Leaf)) {
    throw "TeamViewer binary not found: $TeamViewerPath"
}

if (-not $PSCmdlet.ShouldProcess($LabDirectory,'Stage a renamed cmd.exe parent and genuine TeamViewer child for the causal test')) {
    return
}

New-Item -ItemType Directory -Path $LabDirectory -Force | Out-Null
Copy-Item -LiteralPath 'C:\Windows\System32\cmd.exe' -Destination $parent -Force
Copy-Item -LiteralPath $TeamViewerPath -Destination $child -Force

if ($AsSystem) {
    # Built-in scheduled-task execution creates the same SYSTEM integrity condition as
    # the published test without downloading external tooling.
    & schtasks.exe /create /tn $TaskName /tr "`"$parent`" /c `"$child`"" /sc once /st 00:00 /ru SYSTEM /rl HIGHEST /f | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "schtasks create failed with exit code $LASTEXITCODE" }
    & schtasks.exe /run /tn $TaskName | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "schtasks run failed with exit code $LASTEXITCODE" }
    Start-Sleep -Seconds 5
    & schtasks.exe /delete /tn $TaskName /f | Out-Null
    Write-Host 'Expected: rules 100212 and 100214.' -ForegroundColor Cyan
} else {
    Start-Process -FilePath $parent -ArgumentList '/c',$child
    Start-Sleep -Seconds 5
    Write-Host 'Expected: rule 100212. Rule 100214 must remain quiet at interactive integrity.' -ForegroundColor Cyan
}

Write-Warning "Artifacts remain in $LabDirectory so Velociraptor can verify signer and lineage. Collect first, then rerun with -Cleanup."
