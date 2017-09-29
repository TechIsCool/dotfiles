# These components will be loaded for all PowerShell instances

Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...
Get-Item *.ps1 | ForEach-Object -process {Invoke-Expression ". $_"}

Pop-Location