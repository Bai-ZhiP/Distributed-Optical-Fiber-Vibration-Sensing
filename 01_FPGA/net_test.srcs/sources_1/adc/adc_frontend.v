//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2018/2/24     meisq         1.0         Original
//*******************************************************************************/
module adc_frontend(
    //reference clock
    input                     sys_clk,
 
    //ad9518 signals
	output                    clk_spi_ce,	
	output                    clk_spi_sclk,
	inout                     clk_spi_sdio,
	input                     clk_spi_sdo,
	output                    clk_resetn,
	output                    clk_sync,
    //ad9613 AD1 signals
    output                    ad_sync,
	output                    adc1_spi_ce,
	output                    adc1_spi_sclk,
	inout                     adc1_spi_io,
	input                     adc1_clk_p,
	input                     adc1_clk_n,	
	input[11:0]               adc1_data_p,	
	input[11:0]               adc1_data_n,
	//ad9613 AD2 signals
	output                    adc2_spi_ce,
	output                    adc2_spi_sclk,
	inout                     adc2_spi_io,
	input                     adc2_clk_p,
	input                     adc2_clk_n,
	input[11:0]               adc2_data_p,
	input[11:0]               adc2_data_n
    ,output                  adc1_sample_clk
    ,output[11:0]            adc1_sample_a
    ,output[11:0]            adc1_sample_b
    );
                                 
(* KEEP = "TRUE" *) wire 							clk_50m;

wire 							locked;
wire[9:0]                       clk_lut_index;
wire[24:0]                      clk_lut_data;
wire[9:0]                       adc1_lut_index;
wire[24:0]                      adc1_lut_data;
wire[9:0]                       adc2_lut_index;
wire[24:0]                      adc2_lut_data;
wire                            adc1_clk;
wire                            adc2_clk;
wire                            adc1_clk_ibuf;
wire                            adc2_clk_ibuf;
wire[11:0]                      adc1_data;
wire[11:0]                      adc1_data_a;
wire[11:0]                      adc1_data_b;
wire[11:0]                      adc2_data;
wire[11:0]                      adc2_data_a;
wire[11:0]                      adc2_data_b;
(* MARK_DEBUG="true" *)reg[11:0] adc1_data_a_d0;
(* MARK_DEBUG="true" *)reg[11:0] adc1_data_b_d0;
(* MARK_DEBUG="true" *)reg[11:0] adc2_data_a_d0;
(* MARK_DEBUG="true" *)reg[11:0] adc2_data_b_d0;

(* MARK_DEBUG="true" *)wire				ad9518_pll_locked ;

wire               adc1_spi_dir  ;
wire			   adc1_spi_in   ;
wire			   adc1_spi_out  ;
wire               adc2_spi_dir  ;
wire			   adc2_spi_in   ;
wire			   adc2_spi_out  ;

wire               clk_spi_dir  ;
wire			   clk_spi_in   ;
wire			   clk_spi_out  ;

wire 				adc2_clk_bufio ;
wire 				adc2_clk_bufr ;

wire 				adc1_clk_bufio ;
wire 				adc1_clk_bufr ;

// Explicit pad buffers preserve SPI readback through module-reference OOC
// synthesis, where inferred internal tristates otherwise become LUTs.
IOBUF adc1_spi_iobuf (
    .IO(adc1_spi_io), .I(adc1_spi_out),
    .O(adc1_spi_in), .T(adc1_spi_dir)
);
IOBUF adc2_spi_iobuf (
    .IO(adc2_spi_io), .I(adc2_spi_out),
    .O(adc2_spi_in), .T(adc2_spi_dir)
);
IOBUF clk_spi_iobuf (
    .IO(clk_spi_sdio), .I(clk_spi_out),
    .O(clk_spi_in), .T(clk_spi_dir)
);

assign clk_resetn = 1'b1 ;
assign clk_sync = 1'b1 ;
assign ad_sync = 1'b0 ;

IBUFDS IBUFDS_adc1_clk (
	.O   (adc1_clk_ibuf),  // Buffer output
	.I   (adc1_clk_p),  // Diff_p buffer input (connect directly to top-level port)
	.IB  (adc1_clk_n) // Diff_n buffer input (connect directly to top-level port)
);

IBUFDS IBUFDS_adc2_clk (
	.O  (adc2_clk_ibuf),  // Buffer output
	.I  (adc2_clk_p),  // Diff_p buffer input (connect directly to top-level port)
	.IB (adc2_clk_n) // Diff_n buffer input (connect directly to top-level port)
);



   BUFIO adc2_BUFIO_inst (
      .O(adc2_clk_bufio), // 1-bit output: Clock output (connect to I/O clock loads).
      .I(adc2_clk_ibuf)  // 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );

    BUFG adc2_BUFG_inst (.O(adc2_clk_bufr), .I(adc2_clk_ibuf));


      BUFIO adc1_BUFIO_inst (
      .O(adc1_clk_bufio), // 1-bit output: Clock output (connect to I/O clock loads).
      .I(adc1_clk_ibuf)  // 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );

    // Global fabric clock permits the 130k-sample FIFO across BRAM regions.
    BUFG adc1_BUFG_inst (.O(adc1_clk_bufr), .I(adc1_clk_ibuf));
					
genvar i;
generate
	for (i = 0; i < 12; i = i + 1)

	 begin:ad_data
	
		  IBUFDS #(
           .DIFF_TERM("FALSE"),       // Differential Termination
           .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
           .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
		  ) adc_data1 (
           .O(adc1_data[i]),  // Buffer output
           .I(adc1_data_p[i]),  // Diff_p buffer input (connect directly to top-level port)
           .IB(adc1_data_n[i]) // Diff_n buffer input (connect directly to top-level port)
        );
   
		
		
	    IDDR #(
           .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                           //    or "SAME_EDGE_PIPELINED" 
           .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
           .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
           .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
		) ad1 (
           .Q1(adc1_data_a[i]), // 1-bit output for positive edge of clock 
           .Q2(adc1_data_b[i]), // 1-bit output for negative edge of clock
           .C(adc1_clk_bufio),   // 1-bit clock input
           .CE(1'b1), // 1-bit clock enable input
           .D(adc1_data[i]),   // 1-bit DDR data input
           .R(1'b0),   // 1-bit reset
           .S(1'b0)    // 1-bit set
        );
		
		  IBUFDS #(
           .DIFF_TERM("FALSE"),       // Differential Termination
           .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
           .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
		  ) adc_data2 (
           .O(adc2_data[i]),  // Buffer output
           .I(adc2_data_p[i]),  // Diff_p buffer input (connect directly to top-level port)
           .IB(adc2_data_n[i]) // Diff_n buffer input (connect directly to top-level port)
        );
		
	

	    IDDR #(
           .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                           //    or "SAME_EDGE_PIPELINED" 
           .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
           .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
           .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
		) ad2 (
           .Q1(adc2_data_a[i]), // 1-bit output for positive edge of clock 
           .Q2(adc2_data_b[i]), // 1-bit output for negative edge of clock
           .C(adc2_clk_bufio),   // 1-bit clock input
           .CE(1'b1), // 1-bit clock enable input
           .D(adc2_data[i]),   // 1-bit DDR data input
           .R(1'b0),   // 1-bit reset
           .S(1'b0)    // 1-bit set
        );
	end
endgenerate

always@(posedge adc1_clk_bufr)
begin
	adc1_data_a_d0 <= adc1_data_a;
	adc1_data_b_d0 <= adc1_data_b;
end
always@(posedge adc2_clk_bufr)
begin
	adc2_data_a_d0 <= adc2_data_a;
	adc2_data_b_d0 <= adc2_data_b;
end

// Expose the registered ADC1 samples to the acquisition/AXI-stream wrapper.
// Raw *_data_a_d0 / *_data_b_d0 names denote Q1 / Q2 DDR branches, not
// validated SMA connector labels. With the current 250 MHz clock and
// AD9613 DCO delay 0x91, the AD1_B connector was observed on Q1 by ILA
// (2026-09-15); Q2 stayed at the unconnected-channel noise floor.
// Expose the measured connector mapping to the acquisition wrapper.
// Revalidate this mapping whenever the ADC clock/DCO timing is changed.
assign adc1_sample_clk = adc2_clk_bufr;
assign adc1_sample_a   = adc2_data_b_d0;
assign adc1_sample_b   = adc2_data_a_d0;

  clk_wiz_0 sys_pll_m0
   (
    // Clock out ports
    .clk_out1(clk_50m),     // output clk_out1
    // Status and control signals
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1


	 
//configure look-up table
ad9613_lut_config lut_config_adc1(
	.lut_index                  (adc1_lut_index           ),
	.lut_data                   (adc1_lut_data            )
);
spi_config spi_config_adc1(
	.rst                        (~ad9518_pll_locked                  ),
	.clk                        (clk_50m                  ),
	.clk_div_cnt                (16'd500                  ),
	.lut_index                  (adc1_lut_index           ),
	.lut_reg_addr               (adc1_lut_data[23:8]      ),
	.lut_reg_data               (adc1_lut_data[7:0]       ),
	.pll_check                  ( 1'b0                   ),
	.error                      (                         ),
	.done                       (                         ),	
	.spi_ce                     (adc1_spi_ce              ),
	.spi_sclk                   (adc1_spi_sclk            ),
	.spi_dir                    (adc1_spi_dir              ),
	.spi_in          			(adc1_spi_in              ),
	.spi_out         			(adc1_spi_out              )
);
//configure look-up table
ad9613_lut_config lut_config_adc2(
	.lut_index                  (adc2_lut_index           ),
	.lut_data                   (adc2_lut_data            )
);
spi_config spi_config_adc2(
	.rst                        (~ad9518_pll_locked                  ),
	.clk                        (clk_50m                  ),
	.clk_div_cnt                (16'd500                  ),
	.lut_index                  (adc2_lut_index           ),
	.lut_reg_addr               (adc2_lut_data[23:8]      ),
	.lut_reg_data               (adc2_lut_data[7:0]       ),
	.pll_check                  ( 1'b0                   ),
	.error                      (                         ),
	.done                       (                         ),	
	.spi_ce                     (adc2_spi_ce              ),
	.spi_sclk                   (adc2_spi_sclk            ),
	.spi_dir                    (adc2_spi_dir              ),
	.spi_in          			(adc2_spi_in              ),
	.spi_out         			(adc2_spi_out              )
);

ad9518_lut_config lut_config_clk(
	.lut_index                  (clk_lut_index           ),
	.lut_data                   (clk_lut_data            )
);
spi_config spi_config_clk(
	.rst                        (~locked                  ),
	.clk                        (clk_50m                  ),
	.clk_div_cnt                (16'd500                  ),
	.lut_index                  (clk_lut_index           ),
	.lut_reg_addr               (clk_lut_data[23:8]      ),
	.lut_reg_data               (clk_lut_data[7:0]       ),
	.pll_check                  ( 1'b1                   ),
	.pll_locked                 ( ad9518_pll_locked       ),
	.error                      (                         ),
	.done                       (                         ),	
	.spi_ce                     (clk_spi_ce              ),
	.spi_sclk                   (clk_spi_sclk            ),
	.spi_dir          			(clk_spi_dir              ),
	.spi_in          			(clk_spi_in              ),
	.spi_out         			(clk_spi_out              )
);  

endmodule 

// The original AD example instantiated a generated 50 MHz -> 50 MHz clock
// wizard.  Keep a small synthesizable compatibility model here so the ADC
// module-reference OOC synthesis does not depend on that unrelated IP.
module clk_wiz_0(
    input  clk_in1,
    output clk_out1,
    output locked
);
wire clkfbout;
wire clkfb_buf;
wire clkout0;
wire [15:0] do_unused;
wire drdy_unused, psdone_unused;
wire clkinstopped_unused, clkfbstopped_unused;
wire clkout0b_unused;

// The BD also feeds this oscillator into the Ethernet reference-clock
// wizard, which owns the package IBUF.  Do not instantiate a second IBUF on
// the same top-level clock; the MMCM can take the shared clock net directly.
MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"), .CLKOUT4_CASCADE("FALSE"),
    .COMPENSATION("ZHOLD"), .STARTUP_WAIT("FALSE"),
    .DIVCLK_DIVIDE(1), .CLKFBOUT_MULT_F(20.000),
    .CLKFBOUT_PHASE(0.000), .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKOUT0_DIVIDE_F(20.000), .CLKOUT0_PHASE(0.000),
    .CLKOUT0_DUTY_CYCLE(0.500), .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(20.000)
) mmcm_adv_inst (
    .CLKFBOUT(clkfbout), .CLKFBOUTB(), .CLKOUT0(clkout0),
    .CLKOUT0B(clkout0b_unused), .CLKOUT1(), .CLKOUT1B(),
    .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(),
    .CLKOUT5(), .CLKOUT6(), .CLKFBIN(clkfb_buf), .CLKIN1(clk_in1),
    .CLKIN2(1'b0), .CLKINSEL(1'b1), .DADDR(7'h0), .DCLK(1'b0),
    .DEN(1'b0), .DI(16'h0), .DO(do_unused), .DRDY(drdy_unused),
    .DWE(1'b0), .PSCLK(1'b0), .PSEN(1'b0), .PSINCDEC(1'b0),
    .PSDONE(psdone_unused), .LOCKED(locked),
    .CLKINSTOPPED(clkinstopped_unused), .CLKFBSTOPPED(clkfbstopped_unused),
    .PWRDWN(1'b0), .RST(1'b0)
);
BUFG clkf_buf (.O(clkfb_buf), .I(clkfbout));
BUFG clkout1_buf (.O(clk_out1), .I(clkout0));
endmodule
    
    
