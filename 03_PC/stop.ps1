$data=Join-Path $PSScriptRoot 'data'
New-Item -ItemType Directory -Force $data|Out-Null
foreach($flag in @('STOP','SELECTED_STOP','PROCESSOR_STOP','VIEWER_STOP')){Set-Content -LiteralPath (Join-Path $data $flag) -Value 'Stop requested'}
