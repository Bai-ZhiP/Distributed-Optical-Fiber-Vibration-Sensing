create_clock -name sys_pl_50m -period 20.000 [get_ports sys_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks adc1_dco_250m] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks adc1_dco_250m] -group [get_clocks -include_generated_clocks -filter {PERIOD == 20.000}]
# ADC2 is used only by an asynchronous amplitude diagnostic in the PS-clock ILA.
# Its raw bus is not an atomic CDC transfer and must not drive acquisition logic.
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks adc2_dco_250m] -group [get_clocks -include_generated_clocks clk_fpga_0]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks adc2_dco_250m] -group [get_clocks -include_generated_clocks -filter {PERIOD == 20.000}]
