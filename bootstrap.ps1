$MyDocuments = [environment]::getfolderpath(“mydocuments”)
$ScriptFolder = Split-Path $SCRIPT:MyInvocation.MyCommand.Path -parent
$Table = @{}

$Table.Add($Table.Count,(@{'local' = ('powershell\WindowsPowerShell'); 'remote' = ("$MyDocuments\WindowsPowerShell");}))
$Table.Add($Table.Count,(@{'local' = ('vim\.vimrc'); 'remote' = ("$MyDocuments\.vimrc");}))
$Table.Add($Table.Count,(@{'local' = ('vim\vimfiles'); 'remote' = ("$MyDocuments\vimfiles");}))


foreach ($t in $Table.Keys) {
  $remote = $($Table.Item($t).remote)
  $local = $($ScriptFolder + '\' + $Table.Item($t).local)
  if(!(Test-Path -Path $remote )){
    New-Item -Value $local -ItemType SymbolicLink -Path $remote | Out-Null
  }
}



