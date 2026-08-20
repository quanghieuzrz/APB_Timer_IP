module counter(
    input wire clk,             // System clock 
    input wire rst_n,           // Active-low asynchronous reset 
    input wire tdr0_wr_sel,     // Write select for lower 32-bit register (TDR0)
    input wire tdr1_wr_sel,     // Write select for upper 32-bit register (TDR1)
    input wire cnt_en,          // Counter enable signal from counter_control
    input wire [31:0] wdata,    // APB write data bus (tim_pwdata)
    input wire timer_en_reset,  // Timer disable/reset signal from TCR.timer_en
    output wire [63:0] cnt      // 64-bit counter output value
);

wire [31:0] cnt0;
reg [31:0] cnt0_tmp;
wire [31:0] cnt1;
reg [31:0] cnt1_tmp;
wire [63:0] count;

// Next-state logic for lower 32-bit counter (TDR0)
assign cnt0 = tdr0_wr_sel ? wdata:
              cnt_en ? count[31:0]:
                       cnt[31:0];

// Next-state logic for upper 32-bit counter (TDR1)
assign cnt1 = tdr1_wr_sel ? wdata:
              cnt_en ? count[63:32]:
                       cnt[63:32];

// Flip-Flop update for 64-bit counter registers
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        cnt0_tmp <= 32'h0;
        cnt1_tmp <= 32'h0;
    end else begin
        cnt0_tmp <= cnt0;
        cnt1_tmp <= cnt1;
    end
end

// 64-bit counter incrementer
assign count = cnt + 1;

// Clear counter to 0 when timer_en is Low (Advanced Level Spec)
assign cnt = timer_en_reset ? 64'h0 : {cnt1_tmp, cnt0_tmp};

endmodule