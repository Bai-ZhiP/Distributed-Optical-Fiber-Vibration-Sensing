-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Mon Oct 26 10:59:25 2026
-- Host        : fight_unfair running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/linsu/Documents/Codex/2026-09-09/new-chat/work/fl9613_ad2b_live/hw/net_test.srcs/sources_1/bd/design_1/ip/design_1_adc_capture_axis_0_0/design_1_adc_capture_axis_0_0_stub.vhdl
-- Design      : design_1_adc_capture_axis_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z035ffg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_adc_capture_axis_0_0 is
  Port ( 
    sys_clk : in STD_LOGIC;
    trig_in : in STD_LOGIC;
    clk_spi_ce : out STD_LOGIC;
    clk_spi_sclk : out STD_LOGIC;
    clk_spi_sdio : inout STD_LOGIC;
    clk_spi_sdo : in STD_LOGIC;
    clk_resetn : out STD_LOGIC;
    clk_sync : out STD_LOGIC;
    ad_sync : out STD_LOGIC;
    adc1_spi_ce : out STD_LOGIC;
    adc1_spi_sclk : out STD_LOGIC;
    adc1_spi_io : inout STD_LOGIC;
    adc1_clk_p : in STD_LOGIC;
    adc1_clk_n : in STD_LOGIC;
    adc1_data_p : in STD_LOGIC_VECTOR ( 11 downto 0 );
    adc1_data_n : in STD_LOGIC_VECTOR ( 11 downto 0 );
    adc2_spi_ce : out STD_LOGIC;
    adc2_spi_sclk : out STD_LOGIC;
    adc2_spi_io : inout STD_LOGIC;
    adc2_clk_p : in STD_LOGIC;
    adc2_clk_n : in STD_LOGIC;
    adc2_data_p : in STD_LOGIC_VECTOR ( 11 downto 0 );
    adc2_data_n : in STD_LOGIC_VECTOR ( 11 downto 0 );
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC
  );

end design_1_adc_capture_axis_0_0;

architecture stub of design_1_adc_capture_axis_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "sys_clk,trig_in,clk_spi_ce,clk_spi_sclk,clk_spi_sdio,clk_spi_sdo,clk_resetn,clk_sync,ad_sync,adc1_spi_ce,adc1_spi_sclk,adc1_spi_io,adc1_clk_p,adc1_clk_n,adc1_data_p[11:0],adc1_data_n[11:0],adc2_spi_ce,adc2_spi_sclk,adc2_spi_io,adc2_clk_p,adc2_clk_n,adc2_data_p[11:0],adc2_data_n[11:0],m_axis_tdata[31:0],m_axis_tkeep[3:0],m_axis_tlast,m_axis_tvalid,m_axis_tready,aclk,aresetn";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "adc_capture_axis,Vivado 2020.1";
begin
end;
