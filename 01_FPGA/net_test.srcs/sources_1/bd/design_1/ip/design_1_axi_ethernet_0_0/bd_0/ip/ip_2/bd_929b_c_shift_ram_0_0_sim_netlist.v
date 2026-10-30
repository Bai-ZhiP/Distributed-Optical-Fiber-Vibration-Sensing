// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Mon Aug 31 17:26:24 2026
// Host        : fight_unfair running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top bd_929b_c_shift_ram_0_0 -prefix
//               bd_929b_c_shift_ram_0_0_ bd_929b_c_shift_ram_0_0_sim_netlist.v
// Design      : bd_929b_c_shift_ram_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z035ffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_929b_c_shift_ram_0_0,c_shift_ram_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_14,Vivado 2020.1" *) 
(* NotValidForBitStream *)
module bd_929b_c_shift_ram_0_0
   (D,
    CLK,
    CE,
    SCLR,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef" *) input [0:0]D;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:clockenable:1.0 ce_intf CE" *) (* x_interface_parameter = "XIL_INTERFACENAME ce_intf, POLARITY ACTIVE_HIGH" *) input CE;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency data_bitwidth format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} DATA_WIDTH 1}" *) output [0:0]Q;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "1" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "1" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_929b_c_shift_ram_0_0_c_shift_ram_v12_0_14 U0
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(CE),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADDR_WIDTH = "4" *) (* C_AINIT_VAL = "0" *) (* C_DEFAULT_DATA = "0" *) 
(* C_DEPTH = "1" *) (* C_ELABORATION_DIR = "./" *) (* C_HAS_A = "0" *) 
(* C_HAS_CE = "1" *) (* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_MEM_INIT_FILE = "no_coe_file_loaded" *) (* C_OPT_GOAL = "0" *) 
(* C_PARSER_TYPE = "0" *) (* C_READ_MIF = "0" *) (* C_REG_LAST_BIT = "1" *) 
(* C_SHIFT_TYPE = "0" *) (* C_SINIT_VAL = "0" *) (* C_SYNC_ENABLE = "0" *) 
(* C_SYNC_PRIORITY = "1" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "1" *) 
(* C_XDEVICEFAMILY = "zynq" *) (* downgradeipidentifiedwarnings = "yes" *) 
module bd_929b_c_shift_ram_0_0_c_shift_ram_v12_0_14
   (A,
    D,
    CLK,
    CE,
    SCLR,
    SSET,
    SINIT,
    Q);
  input [3:0]A;
  input [0:0]D;
  input CLK;
  input CE;
  input SCLR;
  input SSET;
  input SINIT;
  output [0:0]Q;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "1" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "1" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_929b_c_shift_ram_0_0_c_shift_ram_v12_0_14_viv i_synth
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(CE),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2020.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
EbXZS4y9cLjOTv9aN2dDC1sJBVVR3T6cbmKAVT9lmEHVIdHGCTfu8iy7QkwIs1KmhdwMqwdjQdXK
KX59vPzAEw==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
svosYlCBRVGey6v4WrNTTJ/a5E95XJFz56V4Zc0YljtTgqhYJjaDcp0yGul9TGC5O3yPB4RfWGyi
btg6o3Dcl+FOWudpxsWABJlvSnbhUeNY+1OKCV5sW4s8s0XiKCJje0Ckn8Rp6OvgxUpP6PcdRMvZ
/iOZAbfkFtowP72szm0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bkZxbcKN0VCVZ8Sn45uafqVYQYk99p4mTYGqhmN6rGL2wN71zIp7oyvjrZ5+IkYIHjaRPVw6MFHU
01i0/bnlUJiW8yu2wC0IWq+Qr+7tToxb6o9RWnXK0n99HX1QMXGzkrlEpdmtBZrVGvgv4FixWWZQ
dodQluVohp21teUBqa8WcGsxqwaf1e28uNmi0DepWjqMe9id/BduXSphJGM1DlXD21S42kAcvg1F
rd0pAgZ6lhG9/NzFbvb2jrcNLh6ifBCr2yjVd33eQU68fnkIGCXAggzWpyR3yOvnmG/zCHLWi4gb
PMOlEmzrjfeM8zl2NP1wqpFDnlaPnYEIcaR53A==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uYdetOP0NrAC/6FuAtYFxT5Pr7xP1xI60RhX9Ysmg000CklbBe3op1FJo9+N93iKzuAQn8/dUzat
ZR36c3yAxvWyYey+XkDfh+7aMlphnj5vggVXK9DqeVsHakNPxVCao7RCkkSR5x9XCYQXJlARvh9C
RhB/l2sQN5DF9bDt9yCKJlWeBEbbcjDJ34WronEFGxp/E9TbIEVWGB4V7jnlgc0oxMMYU40V0d4i
oAADER64AUPfYZ+0e97lsHeETWrkCE5+mE0OLxvjypqZXIFAINmnYsr5zMzToF2CiK/NT3DIL+hM
q6OlPRN1R85uBOCDP7qHtxj+CdoOVPKhdBfsMg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
mo9oRLIx4kH0M86v4sywZvgPz5p30+mzb2H1aU6fkraIKHMy5ue8V7ysmq55k9NVOSXTmYoCdFml
rPPuT8ktqPXADjRPNUmPsenolR9+96Fta26fIQSUqMHuwI/y88nM10meyCjIBjD3+oIqsgrFqbaG
saQSaPJ/MMnei2igUfM=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MqMRozeQ+7B22v/pgqDAubmlkM+wpqpbsz6L+ntdBscEB6ki7vLly/oGOJTK4ju8/qS8LlggHRaO
xtd0voFIGd0icRz64Q8EBqol0lxXJPuQx4zOa4ucCqaUViJ8DL8xQgErcDHpb1p8W6mgaMCbp1Kn
SuN+ZfS1rS2R+r3eI2jOHh5EF/8a+cFR0oqrSsWzggfrGMzKWWsSLwd0s7UMDTtruNQTcAzYvm5V
RP9lHvvN8So5DeLrtLSl96n6SsbeObAAXX1i6fiyPV/C4IkPyx5F/L/IwAENNAvrINtYTWp3zjEx
G/xKzVTUEKeNs9XMESxa+4oJjG8+036ic0vnUw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
IMm39dcG+n5fcIDQcybfOguCUX3GDSDHnE0ukUt3z0GfgxGXQ4udN7KfIK0bhw+jASYUkEQOG82Z
jWNGyelrCJ7tpuvsm9YaIUYr2IJ2QT1Ynkbvb89to7fC2N8oJIj+CoBTtLC86KT5zZElgE6hbiEz
7BmQos82ixAQStfvYXzLNA28OuJ6lb2E0qmPHv4aIX8Fpurga4e+hsxFRIU3Z4ic/LvKJqpD4ezA
/K83dWOlScX9ZuWTi4mAGoqA+zlbNbFwBU8V+8K3oDzdsqo44Z/2l9hMNYUPYCk1/tnKaQd15Ehg
LrY/vRDu7I8Vy15n/vvtYw8+JsW+ZTjk06pwIA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
SsO3/u3pdnkO+dB+OKyx1QDt1mi6uw+plCPLC3gD5vGcT/Rw1DFHrlAIQTmqwHN5GzbPEGkjYmZY
9kwB9EjM2gIdSIdoYRB1RyY5bhp3JCgYfTzMPK5LNFIi+g7M+TtGYVMGT8Di35eaWdm5aaUgxJyR
rB3b4SCUL81yP7DQyIwpQFQa4PC7Xf7b/l1KQrz+rVnuLA25Y6pCjkhIHqPImKXB1AIZfdbma0kD
own9h+IJWBIJ2BjOJkXUROMuM/7PUU6G0C+o/q/qITJAS9HIja+EqxZMlLGXOml4m0pXrwayXWl6
J//yfLFAhoQveWL1I3f0/XvBrtcSUqNyZJThzQ==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rGUo/JqxXHI4LiroeJP/5v98epEBpyTzmJ7YInVFh76jqPQYqQwo7AVwoh9TgiUlhpU9Wb+qQU19
+qvTF/Gqn30nqqrVU/oVBHdlWt4Qs7hNLYOLL2vX0gnNrqLUKTwnZ21AvRsqNAIDdd1qtREs1EeS
42HSzbuUYLsGYNqM8uyFwr0jelHBt5LHDWvXN1qjep+TpbkIqq07XOteo6VssQFqpoz/YTd2B2WE
0lBQSolvgVtGwYzyvQpu1ZzLlU+b0f4KM2H2Ya3wcFnTGTJr+/5jFzS67ngtvo4QtGMsCXIVZ4g3
ExCDIk47At+SmE7ocd0zDTf64FowzSAMc5LF9w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
AMBH1w7BEiVxQ4QNfTrForTJuhtYwZd9mucultV97ObSgvo2kcY0USnUxEiN7Cm9psr9UOQnVQ39
WcZJG8nk14DdjOulQ/F9r23LJXENUJNfcTy1Jw+Z40kPqmKYgYzmFAnBcZo4N121c+SClMoQkvRC
nMtv7c2CxFZ13wgOe8M6x5ee05jvhlMW3SBKiSO/LmB0HNZjTdefoENclTrvu1TKbKBv4TS4VyBg
6pk9y/jLdtJs9PDgDowG55ri9lG8z5v632nK0dPzncSSLNHM9WcZa7APGKkSasVhO9SaiZVU7KYt
XXhfqgwW5wNoeaFZmHuyi/qlZj31I/5xi5lPYw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Nao7Bv2Rk5ArhWIAQ+kNXORmM8ac6WipB/ztLPnK52b9yyYQd7wzXsshp//p0Q/IWeKZ/bEYj0TL
HMWGqaVWCej1TxifyidqNFnuEHSJXsUimTZtLvDdpuiQ7sj24H5UZgAPsELSqMp3NM7bEEWApCTX
ZMrHEf8S8ZLfVgQJqbcmfTWXMzDxF1YHQby26pDxRGOq5w/OnSnVcL8sAB+ulJo5ak2KaFW/dOXp
x7KuI/If80vDZcU7Ox14/ieD3ZIpqqzVxCCrWz+f7/m01lK5kBA8FWi3wyAcex5szkqXTYVAFpFD
ebxL4A/7vJCXN8XmrPpuV0fDrNSCgcz3SLAFiw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 4576)
`pragma protect data_block
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
1yXvY/iyWXnSjC+YtTTHxg==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
