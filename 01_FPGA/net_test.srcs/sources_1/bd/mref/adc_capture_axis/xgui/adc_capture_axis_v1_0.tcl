# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXI_TEST" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_SAMPLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PERIOD_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TEST_PATTERN" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXI_TEST { PARAM_VALUE.AXI_TEST } {
	# Procedure called to update AXI_TEST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_TEST { PARAM_VALUE.AXI_TEST } {
	# Procedure called to validate AXI_TEST
	return true
}

proc update_PARAM_VALUE.FRAME_SAMPLES { PARAM_VALUE.FRAME_SAMPLES } {
	# Procedure called to update FRAME_SAMPLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_SAMPLES { PARAM_VALUE.FRAME_SAMPLES } {
	# Procedure called to validate FRAME_SAMPLES
	return true
}

proc update_PARAM_VALUE.PERIOD_CYCLES { PARAM_VALUE.PERIOD_CYCLES } {
	# Procedure called to update PERIOD_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PERIOD_CYCLES { PARAM_VALUE.PERIOD_CYCLES } {
	# Procedure called to validate PERIOD_CYCLES
	return true
}

proc update_PARAM_VALUE.TEST_PATTERN { PARAM_VALUE.TEST_PATTERN } {
	# Procedure called to update TEST_PATTERN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TEST_PATTERN { PARAM_VALUE.TEST_PATTERN } {
	# Procedure called to validate TEST_PATTERN
	return true
}


proc update_MODELPARAM_VALUE.FRAME_SAMPLES { MODELPARAM_VALUE.FRAME_SAMPLES PARAM_VALUE.FRAME_SAMPLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_SAMPLES}] ${MODELPARAM_VALUE.FRAME_SAMPLES}
}

proc update_MODELPARAM_VALUE.PERIOD_CYCLES { MODELPARAM_VALUE.PERIOD_CYCLES PARAM_VALUE.PERIOD_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PERIOD_CYCLES}] ${MODELPARAM_VALUE.PERIOD_CYCLES}
}

proc update_MODELPARAM_VALUE.TEST_PATTERN { MODELPARAM_VALUE.TEST_PATTERN PARAM_VALUE.TEST_PATTERN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TEST_PATTERN}] ${MODELPARAM_VALUE.TEST_PATTERN}
}

proc update_MODELPARAM_VALUE.AXI_TEST { MODELPARAM_VALUE.AXI_TEST PARAM_VALUE.AXI_TEST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_TEST}] ${MODELPARAM_VALUE.AXI_TEST}
}

