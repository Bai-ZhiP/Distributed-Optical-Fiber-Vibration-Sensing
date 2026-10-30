# PL clock / trigger / FIFO diagnostics, sampled by the independent PS clock.
set prefix design_1_i/adc_capture_axis_0/inst
create_debug_core u_ila_das_status ila
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_das_status]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_das_status]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_das_status]
set clknet [get_nets -of_objects [get_pins $prefix/aclk]]
connect_debug_port u_ila_das_status/clk $clknet
set signals {aresetn trig_in u_adc_frontend/sys_pll_m0/locked u_adc_frontend/ad9518_pll_locked u_adc_frontend/clk_lut_index* u_adc_frontend/spi_config_adc1/lut_index_reg_n_0_* adc_ticks* trigger_count* sample_count* frame_wr_active frame_toggle_wr fifo_full fifo_empty fifo_wr_rst_busy fifo_rd_rst_busy rd_active beat_count* m_axis_tready m_axis_tvalid u_adc_frontend/adc1_data_a_d0* u_adc_frontend/adc1_data_b_d0* u_adc_frontend/adc2_data_a_d0* u_adc_frontend/adc2_data_b_d0*}
set i 0
foreach signal $signals {
 set ns [lsort -dictionary [get_nets -hier -filter "NAME =~ $prefix/$signal"]]
 if {[string index $signal end] eq "*"} {
  set exact {}
  foreach n $ns {if {[regexp {\[[0-9]+\]$} $n]} {lappend exact $n}}
  set ns $exact
 }
 if {![llength $ns]} {
  set ns [get_nets -quiet -of_objects [get_pins -quiet $prefix/$signal]]
 }
 if {![llength $ns]} {
  puts "DIAGNOSTIC_MISSING=$signal"
  continue
 }
 puts "DIAGNOSTIC_PROBE_$i=$ns"
 if {$i>0} {create_debug_port u_ila_das_status probe}
 set_property port_width [llength $ns] [get_debug_ports u_ila_das_status/probe$i]
 connect_debug_port u_ila_das_status/probe$i $ns
 incr i
}
set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk $clknet
