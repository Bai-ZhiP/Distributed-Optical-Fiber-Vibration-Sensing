set here [file dirname [file normalize [info script]]]
set out [file normalize [file join $here ../build/fpga]]
file mkdir $out
set_param general.maxThreads 4
open_project [file join $here net_test.xpr]
set_property ip_output_repo [file join $here net_test.cache/ip] [current_project]
set_property ip_user_files_dir [file join $here net_test.ip_user_files] [current_project]
set_property STEPS.OPT_DESIGN.TCL.PRE [file join $here scripts/das_debug_probes.tcl] [get_runs impl_1]
catch {set_property INCREMENTAL_CHECKPOINT {} [get_runs impl_1]}
open_bd_design [get_files design_1.bd]
update_compile_order -fileset sources_1
update_module_reference [get_ips design_1_adc_capture_axis_0_0]
set_property CONFIG.FRAME_SAMPLES 80000 [get_bd_cells adc_capture_axis_0]
validate_bd_design
save_bd_design
generate_target all [get_files design_1.bd]
make_wrapper -files [get_files design_1.bd] -top
set_property top design_1_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property STATUS [get_runs impl_1]] ne "write_bitstream Complete!"} {error "Implementation failed"}
open_run impl_1
report_timing_summary -file [file join $out timing.rpt]
write_bitstream -force [file join $out rbs250_ad2b.bit]
write_debug_probes -force [file join $out rbs250_ad2b.ltx]
close_project
