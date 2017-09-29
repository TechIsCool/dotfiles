if (Test-Path variable:global:psISE) { 
  Write-Debug 'Skipping ISE since there are no WindowSize Settings'
  return; 
}

$max = $host.UI.RawUI.MaxPhysicalWindowSize

$height = $($max.Height / 2)
if ($height -le 50){ $height = 50 }

$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size($($max.Width-5),9999)
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($($max.Width-6),$height)