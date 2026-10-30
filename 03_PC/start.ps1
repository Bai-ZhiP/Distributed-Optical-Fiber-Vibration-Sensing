param([string]$Python='python',[string]$Matlab='matlab')
$ErrorActionPreference='Stop';$root=$PSScriptRoot;$data=Join-Path $root 'data'
New-Item -ItemType Directory -Force $data|Out-Null
foreach($flag in @('STOP','SELECTED_STOP','PROCESSOR_STOP','VIEWER_STOP')){$f=Join-Path $data $flag;if(Test-Path -LiteralPath $f){Remove-Item -LiteralPath $f}}
foreach($script in @('rbs_iq_receiver.py','rbs_selected_stream.py')){
 Start-Process -FilePath $Python -ArgumentList @('-X','utf8',('"'+(Join-Path $root $script)+'"'),'--directory',('"'+$data+'"')) -WindowStyle Hidden
}
$r=$root.Replace('\','/').Replace("'","''");$d=$data.Replace('\','/').Replace("'","''")
Start-Process -FilePath $Matlab -ArgumentList @('-batch',('"addpath('''+$r+''');rbs_iq_processor(Inf,'''+$d+''');"')) -WindowStyle Hidden
Start-Process -FilePath $Matlab -ArgumentList @('-nosplash','-r',('"addpath('''+$r+''');rbs_fast_iq_live(Inf,'''+$d+''');"')) -WindowStyle Hidden
