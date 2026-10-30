set h [file join [file dirname [file normalize [info script]]] 04_Firmware]
set elf [file join $h rbs_iq_capture.elf]
if {$argc == 1} {set elf [file normalize [lindex $argv 0]]}
if {$argc > 1 || ![file exists $elf]} {error "Expected one existing ELF path"}
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~ "ARM*#0"}
catch {stop}
targets -set -nocase -filter {name =~ "ARM*#1"}
catch {stop}
targets -set -nocase -filter {name =~ "APU*" && level==0} -index 0
configparams force-mem-accesses 1
mwr 0xf8000008 0xdf0d
mwr 0xf8000900 0
mwr 0xf8000240 0xf
rst -system
targets -set -nocase -filter {name =~ "ARM*#0"}
catch {stop}
targets -set -nocase -filter {name =~ "ARM*#1"}
catch {stop}
targets -set -nocase -filter {name =~ "APU*" && level==0} -index 0
configparams force-mem-accesses 1
mwr 0xf8000008 0xdf0d
mwr 0xf8000900 0
mwr 0xf8000240 0xf
source [file join $h ps7_init.tcl]
ps7_init
puts CLEAN_PS_INITIALIZED
targets -set -nocase -filter {name =~ "xc7z035*"}
fpga -file [file join $h rbs250_ad2b.bit]
after 3000
targets -set -nocase -filter {name =~ "APU*" && level==0} -index 0
ps7_post_config
puts "AFI_FIFO_BEFORE_ARM=[mrd -value 0xf8008020]"
targets -set -nocase -filter {name =~ "ARM*#0"}
dow -force $elf
configparams force-mem-accesses 0
con
puts RBS250_RUNNING
exit
