// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:adc_capture_axis:1.0
// IP Revision: 1

(* X_CORE_INFO = "adc_capture_axis,Vivado 2020.1" *)
(* CHECK_LICENSE_TYPE = "design_1_adc_capture_axis_0_0,adc_capture_axis,{}" *)
(* CORE_GENERATION_INFO = "design_1_adc_capture_axis_0_0,adc_capture_axis,{x_ipProduct=Vivado 2020.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=adc_capture_axis,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,FRAME_SAMPLES=80000,PERIOD_CYCLES=100000,TEST_PATTERN=0,AXI_TEST=0}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_adc_capture_axis_0_0 (
  sys_clk,
  trig_in,
  clk_spi_ce,
  clk_spi_sclk,
  clk_spi_sdio,
  clk_spi_sdo,
  clk_resetn,
  clk_sync,
  ad_sync,
  adc1_spi_ce,
  adc1_spi_sclk,
  adc1_spi_io,
  adc1_clk_p,
  adc1_clk_n,
  adc1_data_p,
  adc1_data_n,
  adc2_spi_ce,
  adc2_spi_sclk,
  adc2_spi_io,
  adc2_clk_p,
  adc2_clk_n,
  adc2_data_p,
  adc2_data_n,
  m_axis_tdata,
  m_axis_tkeep,
  m_axis_tlast,
  m_axis_tvalid,
  m_axis_tready,
  aclk,
  aresetn
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_1_sys_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk CLK" *)
input wire sys_clk;
input wire trig_in;
output wire clk_spi_ce;
output wire clk_spi_sclk;
inout wire clk_spi_sdio;
input wire clk_spi_sdo;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk_resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 clk_resetn RST" *)
output wire clk_resetn;
output wire clk_sync;
output wire ad_sync;
output wire adc1_spi_ce;
output wire adc1_spi_sclk;
inout wire adc1_spi_io;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc1_clk_p, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc1_clk_p CLK" *)
input wire adc1_clk_p;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc1_clk_n, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc1_clk_n CLK" *)
input wire adc1_clk_n;
input wire [11 : 0] adc1_data_p;
input wire [11 : 0] adc1_data_n;
output wire adc2_spi_ce;
output wire adc2_spi_sclk;
inout wire adc2_spi_io;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc2_clk_p, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc2_clk_p CLK" *)
input wire adc2_clk_p;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc2_clk_n, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 adc2_clk_n CLK" *)
input wire adc2_clk_n;
input wire [11 : 0] adc2_data_p;
input wire [11 : 0] adc2_data_n;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
output wire [31 : 0] m_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TKEEP" *)
output wire [3 : 0] m_axis_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *)
output wire m_axis_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
output wire m_axis_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *)
input wire m_axis_tready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF M_AXIS, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
input wire aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
input wire aresetn;

  adc_capture_axis #(
    .FRAME_SAMPLES(80000),
    .PERIOD_CYCLES(100000),
    .TEST_PATTERN(0),
    .AXI_TEST(0)
  ) inst (
    .sys_clk(sys_clk),
    .trig_in(trig_in),
    .clk_spi_ce(clk_spi_ce),
    .clk_spi_sclk(clk_spi_sclk),
    .clk_spi_sdio(clk_spi_sdio),
    .clk_spi_sdo(clk_spi_sdo),
    .clk_resetn(clk_resetn),
    .clk_sync(clk_sync),
    .ad_sync(ad_sync),
    .adc1_spi_ce(adc1_spi_ce),
    .adc1_spi_sclk(adc1_spi_sclk),
    .adc1_spi_io(adc1_spi_io),
    .adc1_clk_p(adc1_clk_p),
    .adc1_clk_n(adc1_clk_n),
    .adc1_data_p(adc1_data_p),
    .adc1_data_n(adc1_data_n),
    .adc2_spi_ce(adc2_spi_ce),
    .adc2_spi_sclk(adc2_spi_sclk),
    .adc2_spi_io(adc2_spi_io),
    .adc2_clk_p(adc2_clk_p),
    .adc2_clk_n(adc2_clk_n),
    .adc2_data_p(adc2_data_p),
    .adc2_data_n(adc2_data_n),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .aclk(aclk),
    .aresetn(aresetn)
  );
endmodule
