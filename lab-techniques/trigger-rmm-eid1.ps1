# Fire Wazuh rule 100210: a known RMM launches and gets tagged by its embedded Company.
# Bonus: the rename-proof anchor - the Company field survives a rename, the filename does not.
# Run elevated on the endpoint. Adjust the path to your AnyDesk install.

$anydesk = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"

# Normal launch -> Event ID 1 with Company = AnyDesk Software GmbH -> rule 100210 fires.
Start-Process $anydesk -ArgumentList "--control"; Start-Sleep 4
Stop-Process -Name AnyDesk -Force -ErrorAction SilentlyContinue

# Rename-proof demo: copy to a fake name; the embedded Company is unchanged.
Copy-Item $anydesk "$env:TEMP\totally_legit.exe" -Force
(Get-Item "$env:TEMP\totally_legit.exe").VersionInfo.CompanyName   # still AnyDesk Software GmbH
Remove-Item "$env:TEMP\totally_legit.exe" -Force
