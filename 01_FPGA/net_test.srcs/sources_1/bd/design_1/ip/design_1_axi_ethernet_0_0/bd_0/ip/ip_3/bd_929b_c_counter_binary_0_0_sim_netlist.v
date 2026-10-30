// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Mon Aug 31 17:25:36 2026
// Host        : fight_unfair running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top bd_929b_c_counter_binary_0_0 -prefix
//               bd_929b_c_counter_binary_0_0_ bd_929b_c_counter_binary_0_0_sim_netlist.v
// Design      : bd_929b_c_counter_binary_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z035ffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_929b_c_counter_binary_0_0,c_counter_binary_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_counter_binary_v12_0_14,Vivado 2020.1" *) 
(* NotValidForBitStream *)
module bd_929b_c_counter_binary_0_0
   (CLK,
    SCLR,
    THRESH0,
    Q);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:thresh0_intf:l_intf:load_intf:up_intf:sinit_intf:sset_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 thresh0_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME thresh0_intf, LAYERED_METADATA undef" *) output THRESH0;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency bitwidth format long minimum {} maximum {}} value 24} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} DATA_WIDTH 24}" *) output [23:0]Q;

  wire CLK;
  wire [23:0]Q;
  wire SCLR;
  wire THRESH0;

  (* C_AINIT_VAL = "0" *) 
  (* C_CE_OVERRIDES_SYNC = "0" *) 
  (* C_FB_LATENCY = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_WIDTH = "24" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* c_count_by = "1" *) 
  (* c_count_mode = "0" *) 
  (* c_count_to = "1100000000000000000000" *) 
  (* c_has_load = "0" *) 
  (* c_has_thresh0 = "1" *) 
  (* c_latency = "1" *) 
  (* c_load_low = "0" *) 
  (* c_restrict_count = "1" *) 
  (* c_thresh0_value = "1100000000000000000000" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_929b_c_counter_binary_0_0_c_counter_binary_v12_0_14 U0
       (.CE(1'b1),
        .CLK(CLK),
        .L({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LOAD(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0),
        .THRESH0(THRESH0),
        .UP(1'b1));
endmodule

(* C_AINIT_VAL = "0" *) (* C_CE_OVERRIDES_SYNC = "0" *) (* C_COUNT_BY = "1" *) 
(* C_COUNT_MODE = "0" *) (* C_COUNT_TO = "1100000000000000000000" *) (* C_FB_LATENCY = "0" *) 
(* C_HAS_CE = "0" *) (* C_HAS_LOAD = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_SINIT = "0" *) (* C_HAS_SSET = "0" *) (* C_HAS_THRESH0 = "1" *) 
(* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "1" *) (* C_LOAD_LOW = "0" *) 
(* C_RESTRICT_COUNT = "1" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_THRESH0_VALUE = "1100000000000000000000" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "24" *) 
(* C_XDEVICEFAMILY = "zynq" *) (* downgradeipidentifiedwarnings = "yes" *) 
module bd_929b_c_counter_binary_0_0_c_counter_binary_v12_0_14
   (CLK,
    CE,
    SCLR,
    SSET,
    SINIT,
    UP,
    LOAD,
    L,
    THRESH0,
    Q);
  input CLK;
  input CE;
  input SCLR;
  input SSET;
  input SINIT;
  input UP;
  input LOAD;
  input [23:0]L;
  output THRESH0;
  output [23:0]Q;

  wire CLK;
  wire [23:0]Q;
  wire SCLR;
  wire THRESH0;

  (* C_AINIT_VAL = "0" *) 
  (* C_CE_OVERRIDES_SYNC = "0" *) 
  (* C_FB_LATENCY = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_WIDTH = "24" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* c_count_by = "1" *) 
  (* c_count_mode = "0" *) 
  (* c_count_to = "1100000000000000000000" *) 
  (* c_has_load = "0" *) 
  (* c_has_thresh0 = "1" *) 
  (* c_latency = "1" *) 
  (* c_load_low = "0" *) 
  (* c_restrict_count = "1" *) 
  (* c_thresh0_value = "1100000000000000000000" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_929b_c_counter_binary_0_0_c_counter_binary_v12_0_14_viv i_synth
       (.CE(1'b0),
        .CLK(CLK),
        .L({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LOAD(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0),
        .THRESH0(THRESH0),
        .UP(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2020.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
EJFZwtxl4g9/OL6+bopUV8BP4e67HNukCIy7Ih3E75y7soa6GhqEucPXMiOy+mJrcrNwD+HjZ0/I
BwEKIiA4mA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
rZCGWdmPJXoOuANoS8fyUXk7SyF+uTNJL18BfeKc+fxcyRrCB++WrM02adxoUdICz4/92yY8TQgj
xyPC0eaHZcjSLepbnHHgSReIQ1PL0hmufLbye7QTD0ygUXC4MvFVY8s3KeW9cPCqOxkyCSziJQzs
J5OT9XLQno1e9rIBr9M=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
I7Zo4frj3tO6FFzeDhpSENS0yd34dQZBtiyIrI/GMASFBUeny6muOD2l0HK69ImRJIOyobvK1+9O
DhxptAc4NzRpY4xUZvr4ix1AhM1Kars1OkrQCWz4a7ciGU/XDblidF3IL0Fa7c41gHIZR9c/Usa6
XL7UEu3aSPQYbZLSDOzeao4VtSSn+dCcjsH4X8zVjSqXg8dcN3fd5C15JaMYg00F2yOFtxwWwZWq
Yvwe1q1PG/wcA1cKAOscANbj4o3O4LjfylNIB6L+Mssxosh+e0+oobWNk/ouBa4k1c3/IzXGSCAs
hEvbI+iqkWJJKZrSb9PZk7S7XSJcScrJO/DGkQ==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DDRecdVJcCPEpbUqhuwKtKWXteF7XhGc5d+lQn2uiREzbHyuZvQ1wDwAGGrPwE75gjqc7CdHPMOY
8+3nqcEwR4Q5USgQcou3Cyc6C0TnzzDD/dLKPHDWA1s52x8Rx+LBH9WCvBpD5BKkE4o1s3rN1tL2
wTdCqzzKD8YlryKQ4U0lr2bX6Mlf4/nIt2K1eyPKbIrHIvKDThmaIF/qLnLnkE04pksWJ9Af1OVB
46iqBssrR5p6wZc241D4CqSRCRamfP/s1JrTi8bBNCcXhC0f0Aa35UAoG8vnFngHlFd3G2J88cas
Fo7UH4k1BTTfgbQ35ec0XfSbS/qQWS+EgAF+wA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
L11p2bsABDhO9HvT3IM+HulCClFvs/UPexuAVExicKtzrLN7tNvUjSouZSn9KwAjR2hg5ZIJ23uy
1elB+eyEl65vQnoH4+s6Q5K4EIcMo5WVKfIKwgu5Q3Sg/jYW+aWT/kGuc7CazRsTxJ7XPFndpMIM
cxYWx2DLps320t+Be0c=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Uublhc2r9VmPPq1tMATsd3XJltn9QRg1/PdCtSlxgFBDDAk13md52Fz+h+DOWptR3Q4i+Sx5IhIP
QIONVNTf1DnoK/wa1lkbd1dROJam8/cZQFiIxnsnSPGXzOGoc0c04xDSCJCCDxiDMF1YTtAqt6nw
yZh1RwOhPpgwUKjeJ4o4TY6/i0xuYAYVc83O6KwI9Ywk9UsfyIQQS8UXFo8zA9eniU2n2NcyAVNj
Y8xZ9PYJfzfDo6dHWsj4Ik588uhfO/bmsf2/ZuY5HCAMQpnda9XzPkVomNjRfsUghko7KipIl2ur
aHh+4i2kI/+cHaihhw3z14aGidBkuYKaopasbA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
VYqlyQSuRywWcSrUprXX2UzoaWsJXTTbptzDY9ycgFR91H2uYfY43f80gn0E87Gvj90Qmn0Dl6ck
2VjO2Zn9yATmqtuzi/Etuf29dkl3uyKtk02OitZJEhD1CDyUJHDXKHkPMXOZCBU5CfkrIWw2SsSq
YuQKmvxp4BrhcwXypr+vRSsYd1liMxxuXOdBN5AIyzibGfcR4YUeOokIoP05xZoQOfPQkotMC1B6
SHVKEaBxe37YkyKAkQ0f9eKfnPPLG/G5qeLrFPAiIar0HHpOvdCOO69vi3RG1XqoxtTm/wGwRb5J
ZqzZyTn1Fm55PXyKhlElzXXAv1xPOTbkJXRZNQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
EktM4icAEVQRmfzXBBFeRr7d3ZTOU9f+J40sQAiff114nDU+fxlewcv+twlytUk9LMSR67RJlLt4
+ZBTwcuSPZ2Cvrommkp++7rNze0VCD8pSAdj4uo1ZnYWVWmPMQaRIqI88lnAzc5+T/LxEiXKn4ji
AYGs9fja4ME8C0CHbBsg+jfUryleVk1D8jEMCetM7qDx64s/7AGfwzDqMiW2DPCPLKNUsdlOlBYT
JAOnfy6deN7/o7BYxBsE1P4Pib1x1hvR8RwEm38pBOLKGade6KL/1SHmz5N1KGLPSXQXlK53RLTI
Exc4wN04Kg72tf503oGq6Vp90c5pksQ9cc0M+w==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qzYsaSn6YzxyfrxIwv3eyowRK7ZyzZmQHzUmV2AITf6g43c7IV/fwNBDik+XFhLScW2SxsyaGGI7
5n6kAt9uM3GerkCXA+LJQrqshcEyjuvm17vWVovBURqxhTARgZaTs5OtXdhc/wLi5e6lsdyyLtQo
bt66ubjErMgf5+tD8rpn0HkjUYmGv/MBZ0i4bGui735H12aK+wTfhGVOOiuWHCk2zCJJSx3vH4sl
dKtlpg4W0hPEM3TBPHaLnOpIDkrIUaGGN5fm6NJL6US59+Lr8/3mplbD8ld21OKzgLH+5YPRMoo4
1Pbjxkawu5Kk60AsuaR/OxngawaRMd9N4niRfQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oFA83yaytkfAGLFTValYqojqEyYgLzrVQ0tcWrLu2fTcHnEVvvwiw/e0kqbqrvct0oN5X/cEkNpA
OjmMJbsbSmnd4FmqdFJ/nsYGkZEu/8rp1RZdhUv5hk7kdp9suFG4fsCoQximWJYoIUfm0bOVmcrk
nDYLHRWwJ6f+9f2LsiGj1Mj6KSVTv0tJYl3cTg+gQB7iumvGEa/j8mXGEoGTYCtRN2j7FrIb+CVp
D+KNICtczVGvSpvAMbUI2YUzXGqhgNrjsSaPPZY7aWni0oIUMrm91S5ffHEdNLeUZXk7o+FSWrhJ
2+is2LSuk+Lx4SJnDIvV+gvMkOlKq+DrRgho2A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
C+C3KUZyAzmOvChJdhGoVkzvfBuuinDcpYgZ1mTJnumj2f11FmWeGRQ1pdQXRybPmIdX4bn4Brpv
c3zcZGm0egvV2hCzRTgNOcM/OVMC/rLq37f2/f2VYcyZ0LPu39jG9A5HZi5eiMLCPwB7fUWc9KPl
0/jCNVml13SOxPtfhglOfc4FFgLdWfRcHzbzLi1Z9bZTh2yzU6w6DR3IdMFzWwA2CUUV/HsvNjaZ
qVhChHSZpXbfztr/dEZQb+KHf+tyXa3LEoRQd8MektOJ9b/Go7ZBY15l8c9Uo1PgYXAnIEzQtz//
94dVvaYRTSmIzYRVMhvw7wkh95lKbXFlR+b49A==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 12320)
`pragma protect data_block
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
8FngRrgLayg=
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
