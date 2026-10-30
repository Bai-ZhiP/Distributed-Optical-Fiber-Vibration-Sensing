param([string]$ToolchainBin=$env:ARM_GCC_BIN)
$ErrorActionPreference='Stop'
if(!$ToolchainBin){throw 'Set ARM_GCC_BIN to the ARM GNU toolchain bin directory.'}
$cc=Join-Path $ToolchainBin 'arm-none-eabi-gcc.exe'
$src=Join-Path $PSScriptRoot 'src';$bsp=Join-Path $PSScriptRoot 'bsp/ps7_cortexa9_0'
$out=Join-Path $PSScriptRoot '../build/arm';New-Item -ItemType Directory -Force $out|Out-Null
$files=@('main.c','das_udp.c','platform.c','platform_mb.c','platform_ppc.c','platform_zynq.c','platform_zynqmp.c','sfp.c','si5324.c','i2c_access.c','iic_phyreset.c','ctype_compat.c')
$objs=@()
foreach($f in $files){
 $obj=Join-Path $out ($f -replace '\.c$','.o')
 & $cc -Wall -O3 -g3 -c -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard ('-I'+(Join-Path $bsp 'include')) ('-I'+$src) -o $obj (Join-Path $src $f)
 if($LASTEXITCODE -ne 0){throw "Compile failed: $f"};$objs+=$obj
}
& $cc -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard '-Wl,-build-id=none' ('-specs='+(Join-Path $src 'Xilinx.spec')) ('-Wl,-T,'+(Join-Path $src 'lscript.ld')) ('-L'+(Join-Path $bsp 'lib')) -o (Join-Path $out 'rbs_iq_capture.elf') @objs '-Wl,--start-group' -lxil -llwip4 -lgcc -lc '-Wl,--end-group'
if($LASTEXITCODE -ne 0){throw 'Link failed'}
