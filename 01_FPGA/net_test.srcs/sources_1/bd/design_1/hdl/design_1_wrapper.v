//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
//Date        : Mon Oct 26 10:58:30 2026
//Host        : fight_unfair running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    ad_sync,
    adc1_clk_n,
    adc1_clk_p,
    adc1_data_n,
    adc1_data_p,
    adc1_spi_ce,
    adc1_spi_io,
    adc1_spi_sclk,
    adc2_clk_n,
    adc2_clk_p,
    adc2_data_n,
    adc2_data_p,
    adc2_spi_ce,
    adc2_spi_io,
    adc2_spi_sclk,
    clk_resetn,
    clk_spi_ce,
    clk_spi_sclk,
    clk_spi_sdio,
    clk_spi_sdo,
    clk_sync,
    fan_pwm,
    mdio_mdc,
    mdio_mdio_io,
    phy_rst_n,
    rgmii_rd,
    rgmii_rx_ctl,
    rgmii_rxc,
    rgmii_td,
    rgmii_tx_ctl,
    rgmii_txc,
    sys_clk,
    trig_in);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output ad_sync;
  input adc1_clk_n;
  input adc1_clk_p;
  input [11:0]adc1_data_n;
  input [11:0]adc1_data_p;
  output adc1_spi_ce;
  inout adc1_spi_io;
  output adc1_spi_sclk;
  input adc2_clk_n;
  input adc2_clk_p;
  input [11:0]adc2_data_n;
  input [11:0]adc2_data_p;
  output adc2_spi_ce;
  inout adc2_spi_io;
  output adc2_spi_sclk;
  output clk_resetn;
  output clk_spi_ce;
  output clk_spi_sclk;
  inout clk_spi_sdio;
  input clk_spi_sdo;
  output clk_sync;
  output [0:0]fan_pwm;
  output mdio_mdc;
  inout mdio_mdio_io;
  output [0:0]phy_rst_n;
  input [3:0]rgmii_rd;
  input rgmii_rx_ctl;
  input rgmii_rxc;
  output [3:0]rgmii_td;
  output rgmii_tx_ctl;
  output rgmii_txc;
  input sys_clk;
  input trig_in;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire ad_sync;
  wire adc1_clk_n;
  wire adc1_clk_p;
  wire [11:0]adc1_data_n;
  wire [11:0]adc1_data_p;
  wire adc1_spi_ce;
  wire adc1_spi_io;
  wire adc1_spi_sclk;
  wire adc2_clk_n;
  wire adc2_clk_p;
  wire [11:0]adc2_data_n;
  wire [11:0]adc2_data_p;
  wire adc2_spi_ce;
  wire adc2_spi_io;
  wire adc2_spi_sclk;
  wire clk_resetn;
  wire clk_spi_ce;
  wire clk_spi_sclk;
  wire clk_spi_sdio;
  wire clk_spi_sdo;
  wire clk_sync;
  wire [0:0]fan_pwm;
  wire mdio_mdc;
  wire mdio_mdio_i;
  wire mdio_mdio_io;
  wire mdio_mdio_o;
  wire mdio_mdio_t;
  wire [0:0]phy_rst_n;
  wire [3:0]rgmii_rd;
  wire rgmii_rx_ctl;
  wire rgmii_rxc;
  wire [3:0]rgmii_td;
  wire rgmii_tx_ctl;
  wire rgmii_txc;
  wire sys_clk;
  wire trig_in;

  design_1 design_1_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .ad_sync(ad_sync),
        .adc1_clk_n(adc1_clk_n),
        .adc1_clk_p(adc1_clk_p),
        .adc1_data_n(adc1_data_n),
        .adc1_data_p(adc1_data_p),
        .adc1_spi_ce(adc1_spi_ce),
        .adc1_spi_io(adc1_spi_io),
        .adc1_spi_sclk(adc1_spi_sclk),
        .adc2_clk_n(adc2_clk_n),
        .adc2_clk_p(adc2_clk_p),
        .adc2_data_n(adc2_data_n),
        .adc2_data_p(adc2_data_p),
        .adc2_spi_ce(adc2_spi_ce),
        .adc2_spi_io(adc2_spi_io),
        .adc2_spi_sclk(adc2_spi_sclk),
        .clk_resetn(clk_resetn),
        .clk_spi_ce(clk_spi_ce),
        .clk_spi_sclk(clk_spi_sclk),
        .clk_spi_sdio(clk_spi_sdio),
        .clk_spi_sdo(clk_spi_sdo),
        .clk_sync(clk_sync),
        .fan_pwm(fan_pwm),
        .mdio_mdc(mdio_mdc),
        .mdio_mdio_i(mdio_mdio_i),
        .mdio_mdio_o(mdio_mdio_o),
        .mdio_mdio_t(mdio_mdio_t),
        .phy_rst_n(phy_rst_n),
        .rgmii_rd(rgmii_rd),
        .rgmii_rx_ctl(rgmii_rx_ctl),
        .rgmii_rxc(rgmii_rxc),
        .rgmii_td(rgmii_td),
        .rgmii_tx_ctl(rgmii_tx_ctl),
        .rgmii_txc(rgmii_txc),
        .sys_clk(sys_clk),
        .trig_in(trig_in));
  IOBUF mdio_mdio_iobuf
       (.I(mdio_mdio_o),
        .IO(mdio_mdio_io),
        .O(mdio_mdio_i),
        .T(mdio_mdio_t));
endmodule
