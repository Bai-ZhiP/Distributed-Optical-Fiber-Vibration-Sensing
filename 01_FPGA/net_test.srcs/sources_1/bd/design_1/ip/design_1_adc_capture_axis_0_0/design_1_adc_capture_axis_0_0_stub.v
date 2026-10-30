// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Mon Oct 26 10:59:25 2026
// Host        : fight_unfair running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/linsu/Documents/Codex/2026-09-09/new-chat/work/fl9613_ad2b_live/hw/net_test.srcs/sources_1/bd/design_1/ip/design_1_adc_capture_axis_0_0/design_1_adc_capture_axis_0_0_stub.v
// Design      : design_1_adc_capture_axis_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z035ffg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "adc_capture_axis,Vivado 2020.1" *)
module design_1_adc_capture_axis_0_0(sys_clk, trig_in, clk_spi_ce, clk_spi_sclk, 
  clk_spi_sdio, clk_spi_sdo, clk_resetn, clk_sync, ad_sync, adc1_spi_ce, adc1_spi_sclk, 
  adc1_spi_io, adc1_clk_p, adc1_clk_n, adc1_data_p, adc1_data_n, adc2_spi_ce, adc2_spi_sclk, 
  adc2_spi_io, adc2_clk_p, adc2_clk_n, adc2_data_p, adc2_data_n, m_axis_tdata, m_axis_tkeep, 
  m_axis_tlast, m_axis_tvalid, m_axis_tready, aclk, aresetn)
/* synthesis syn_black_box black_box_pad_pin="sys_clk,trig_in,clk_spi_ce,clk_spi_sclk,clk_spi_sdio,clk_spi_sdo,clk_resetn,clk_sync,ad_sync,adc1_spi_ce,adc1_spi_sclk,adc1_spi_io,adc1_clk_p,adc1_clk_n,adc1_data_p[11:0],adc1_data_n[11:0],adc2_spi_ce,adc2_spi_sclk,adc2_spi_io,adc2_clk_p,adc2_clk_n,adc2_data_p[11:0],adc2_data_n[11:0],m_axis_tdata[31:0],m_axis_tkeep[3:0],m_axis_tlast,m_axis_tvalid,m_axis_tready,aclk,aresetn" */;
  input sys_clk;
  input trig_in;
  output clk_spi_ce;
  output clk_spi_sclk;
  inout clk_spi_sdio;
  input clk_spi_sdo;
  output clk_resetn;
  output clk_sync;
  output ad_sync;
  output adc1_spi_ce;
  output adc1_spi_sclk;
  inout adc1_spi_io;
  input adc1_clk_p;
  input adc1_clk_n;
  input [11:0]adc1_data_p;
  input [11:0]adc1_data_n;
  output adc2_spi_ce;
  output adc2_spi_sclk;
  inout adc2_spi_io;
  input adc2_clk_p;
  input adc2_clk_n;
  input [11:0]adc2_data_p;
  input [11:0]adc2_data_n;
  output [31:0]m_axis_tdata;
  output [3:0]m_axis_tkeep;
  output m_axis_tlast;
  output m_axis_tvalid;
  input m_axis_tready;
  input aclk;
  input aresetn;
endmodule
