module counter_control(
    input wire clk,            
    input wire rst_n,           // Active-low asynchronous reset
    input wire div_en,          // Clock divider enable
    input wire [3:0] div_val,   // Clock divider selection value
    input wire halt_req,        // Halt request signal
    input wire timer_en,        // Global timer enable
    input wire debug_mode,      // Debug mode status flag
    output wire cnt_en          // Final counter enable signal
);

// Internal wire declarations
wire default_mode;
wire control_mode_pre;
wire control_mode;

// Default mode active when divider is disabled but timer is enabled
assign default_mode = (!div_en) & timer_en;

// Pre-control mode when divider is enabled with zero division factor
assign control_mode_pre = div_en & timer_en & (div_val == 1'b0); // same default_mode

// Internal register for divider threshold value
reg [7:0] div_val_value;

// Combinational logic to decode divider value to tick threshold
always @(*) begin
    case (div_val)
        4'b0000: div_val_value = 8'd0;
        4'b0001: div_val_value = 8'd1;
        4'b0010: div_val_value = 8'd3;
        4'b0011: div_val_value = 8'd7;
        4'b0100: div_val_value = 8'd15;
        4'b0101: div_val_value = 8'd31;
        4'b0110: div_val_value = 8'd63;
        4'b0111: div_val_value = 8'd127;
        4'b1000: div_val_value = 8'd255;
        default: div_val_value = 8'd1;
    endcase
end

// Internal signals for internal prescaler counter
reg  [7:0] count;
wire cnt_res;
wire [7:0] cnt_tmp;

// Reset trigger condition for internal prescaler counter
assign cnt_res = !timer_en | !div_en | (count == div_val_value);

// Next value logic for internal prescaler counter
assign cnt_tmp = (halt_req & debug_mode) ? count :
                                cnt_res  ? 8'h0 : count + 1'b1;

// Prescaler counter register update
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 1'b0;
    end else begin
        count <= cnt_tmp;
    end
end

// Divider match condition (tick pulse generation)
assign control_mode = (count == div_val_value) & timer_en & div_en & (div_val != 0);

// Final counter enable generation with halt and debug conditions
assign cnt_en = (default_mode | control_mode_pre | control_mode) & ((!halt_req) | (!debug_mode));

endmodule