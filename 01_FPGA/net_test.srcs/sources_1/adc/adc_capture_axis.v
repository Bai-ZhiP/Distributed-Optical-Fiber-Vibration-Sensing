`timescale 1ns/1ps
// 640 us AD1_B capture on external TRIG; whole triggers are skipped when busy.
module adc_capture_axis #(
    parameter integer FRAME_SAMPLES = 160000,
    parameter integer PERIOD_CYCLES = 100000,
    parameter integer TEST_PATTERN = 0,
    parameter integer AXI_TEST = 0
)(
    input                       sys_clk,
    input                       trig_in,

    // ALINX clock/ADC configuration signals
    output                      clk_spi_ce,
    output                      clk_spi_sclk,
    inout                       clk_spi_sdio,
    input                       clk_spi_sdo,
    output                      clk_resetn,
    output                      clk_sync,
    output                      ad_sync,
    output                      adc1_spi_ce,
    output                      adc1_spi_sclk,
    inout                       adc1_spi_io,
    input                       adc1_clk_p,
    input                       adc1_clk_n,
    input       [11:0]          adc1_data_p,
    input       [11:0]          adc1_data_n,
    output                      adc2_spi_ce,
    output                      adc2_spi_sclk,
    inout                       adc2_spi_io,
    input                       adc2_clk_p,
    input                       adc2_clk_n,
    input       [11:0]          adc2_data_p,
    input       [11:0]          adc2_data_n,

    // AXI4-Stream S2MM input to the tutorial AXI DMA
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
    output      [31:0]          m_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TKEEP" *)
    output       [3:0]          m_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *)
    output                      m_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
    output                      m_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *)
    input                       m_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXIS, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000" *)
    input                       aclk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input                       aresetn
);

wire                    adc1_sample_clk;
wire [11:0]             adc1_sample_a;
wire [11:0]             adc1_sample_b;

adc_frontend u_adc_frontend (
    .sys_clk       (sys_clk),
    .clk_spi_ce    (clk_spi_ce),
    .clk_spi_sclk  (clk_spi_sclk),
    .clk_spi_sdio  (clk_spi_sdio),
    .clk_spi_sdo   (clk_spi_sdo),
    .clk_resetn    (clk_resetn),
    .clk_sync      (clk_sync),
    .ad_sync       (ad_sync),
    .adc1_spi_ce  (adc1_spi_ce),
    .adc1_spi_sclk(adc1_spi_sclk),
    .adc1_spi_io  (adc1_spi_io),
    .adc1_clk_p   (adc1_clk_p),
    .adc1_clk_n   (adc1_clk_n),
    .adc1_data_p  (adc1_data_p),
    .adc1_data_n  (adc1_data_n),
    .adc2_spi_ce  (adc2_spi_ce),
    .adc2_spi_sclk(adc2_spi_sclk),
    .adc2_spi_io  (adc2_spi_io),
    .adc2_clk_p   (adc2_clk_p),
    .adc2_clk_n   (adc2_clk_n),
    .adc2_data_p  (adc2_data_p),
    .adc2_data_n  (adc2_data_n),
    .adc1_sample_clk(adc1_sample_clk),
    .adc1_sample_a  (adc1_sample_a),
    .adc1_sample_b  (adc1_sample_b)
);

localparam integer FRAME_BEATS = FRAME_SAMPLES/2;
wire fifo_full, fifo_empty, fifo_wr_rst_busy, fifo_rd_rst_busy;
wire [31:0] fifo_dout;
reg frame_wr_active, frame_toggle_wr;
reg [31:0] sample_count;
reg [31:0] trigger_count, skipped_count;
reg [63:0] adc_ticks;
reg c16,c32,c48;
reg [31:0] saved_id, saved_skipped;
reg [63:0] saved_ticks;
reg saved_overflow;
(* ASYNC_REG="TRUE" *) reg [2:0] trig_sync;
wire trig_rise = trig_sync[1] & ~trig_sync[2];
reg frame_ack;
(* ASYNC_REG="TRUE" *) reg [1:0] ack_sync;
(* ASYNC_REG="TRUE" *) reg [1:0] done_sync;
reg rd_active;
reg [31:0] beat_count;
wire fifo_wr_en = frame_wr_active && !fifo_full && !fifo_wr_rst_busy;
wire fifo_rd_en = rd_active && beat_count>=8 && m_axis_tvalid && m_axis_tready;
// AD9613 register 0x14=0x05 selects 12-bit two's complement.
wire [15:0] fifo_din = {{4{adc1_sample_b[11]}},adc1_sample_b};
// Only one whole frame occupies the FIFO. The writer cannot overrun it even
// if DMA stalls forever; the next trigger is accepted only after drain ACK.
xpm_fifo_async #(
 .CDC_SYNC_STAGES(4), .DOUT_RESET_VALUE("0"), .ECC_MODE("no_ecc"),
 .FIFO_MEMORY_TYPE("block"), .FIFO_READ_LATENCY(0), .FIFO_WRITE_DEPTH(262144),
 .FULL_RESET_VALUE(0), .PROG_EMPTY_THRESH(10), .PROG_FULL_THRESH(262128),
 .RD_DATA_COUNT_WIDTH(18), .READ_DATA_WIDTH(32), .READ_MODE("fwft"),
 .RELATED_CLOCKS(0), .USE_ADV_FEATURES("0000"), .WAKEUP_TIME(0),
 .WRITE_DATA_WIDTH(16), .WR_DATA_COUNT_WIDTH(19)
) u_adc_fifo (
 .almost_empty(), .almost_full(), .data_valid(), .dbiterr(), .dout(fifo_dout),
 .empty(fifo_empty), .full(fifo_full), .overflow(), .prog_empty(), .prog_full(),
 .rd_data_count(), .rd_rst_busy(fifo_rd_rst_busy), .sbiterr(), .underflow(),
 .wr_ack(), .wr_data_count(), .wr_rst_busy(fifo_wr_rst_busy), .din(fifo_din),
 .injectdbiterr(1'b0), .injectsbiterr(1'b0), .rd_clk(aclk), .rd_en(fifo_rd_en),
 .rst(~aresetn), .sleep(1'b0), .wr_clk(adc1_sample_clk), .wr_en(fifo_wr_en)
);
always @(posedge adc1_sample_clk or negedge aresetn) begin
 if(!aresetn) begin
  trig_sync<=0; ack_sync<=0; adc_ticks<=0; c16<=0;c32<=0;c48<=0; trigger_count<=0; skipped_count<=0;
  frame_wr_active<=0; frame_toggle_wr<=0; sample_count<=0;
  saved_id<=0; saved_skipped<=0; saved_ticks<=0; saved_overflow<=0;
 end else begin
  trig_sync <= {trig_sync[1:0],trig_in};
  ack_sync <= {ack_sync[0],frame_ack};
  c16 <= adc_ticks[15:0]==16'hfffe;
  c32 <= adc_ticks[31:0]==32'hfffffffe;
  c48 <= adc_ticks[47:0]==48'hfffffffffffe;
  adc_ticks[15:0]<=adc_ticks[15:0]+1'b1;
  adc_ticks[31:16]<=adc_ticks[31:16]+c16;
  adc_ticks[47:32]<=adc_ticks[47:32]+c32;
  adc_ticks[63:48]<=adc_ticks[63:48]+c48;
  if (trig_rise) begin
   trigger_count<=trigger_count+1'b1;
   if (!frame_wr_active && frame_toggle_wr==ack_sync[1] && !fifo_wr_rst_busy) begin
    frame_wr_active<=1; sample_count<=0; saved_id<=trigger_count;
    saved_ticks<=adc_ticks; saved_skipped<=skipped_count; saved_overflow<=0;
   end else skipped_count<=skipped_count+1'b1;
  end
  if (frame_wr_active) begin
   // Never pause time when full. Flag any impossible overflow and reject it
   // at the host; the fixed-size FIFO and drain handshake prevent this case.
   if (fifo_full || fifo_wr_rst_busy) saved_overflow<=1;
   if(sample_count==FRAME_SAMPLES-1) begin
    frame_wr_active<=0; frame_toggle_wr<=~frame_toggle_wr; sample_count<=0;
   end else sample_count<=sample_count+1'b1;
  end
 end
end
// Metadata remains stable from trigger through the final beat handshake.
// It settles >640 us before the synchronized completion toggle is consumed.
reg [31:0] header_word;
always @* begin
 case(beat_count)
  0: header_word=32'h32534252; // RBS2
  1: header_word=saved_id;
  2: header_word=saved_ticks[31:0];
  3: header_word=saved_ticks[63:32];
  4: header_word=32'd250000000;
  5: header_word=FRAME_SAMPLES;
  6: header_word=32'd4 | (saved_overflow ? 32'd8 : 32'd0);
  7: header_word=saved_skipped;
  default: header_word=0;
 endcase
end
always @(posedge aclk or negedge aresetn) begin
 if(!aresetn) begin done_sync<=0; frame_ack<=0; rd_active<=0; beat_count<=0; end
 else begin
  done_sync<={done_sync[0],frame_toggle_wr};
  if(!rd_active && done_sync[1]!=frame_ack && !fifo_rd_rst_busy) begin
   rd_active<=1; beat_count<=0;
  end
  if(m_axis_tvalid && m_axis_tready) begin
   if(beat_count==FRAME_BEATS+7) begin
    rd_active<=0; frame_ack<=done_sync[1]; beat_count<=0;
   end else beat_count<=beat_count+1'b1;
  end
 end
end
assign m_axis_tdata=beat_count<8 ? header_word : fifo_dout;
assign m_axis_tkeep=4'hf;
assign m_axis_tvalid=rd_active && !fifo_rd_rst_busy && (beat_count<8 || !fifo_empty);
assign m_axis_tlast=m_axis_tvalid && beat_count==FRAME_BEATS+7;
endmodule
