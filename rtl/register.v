module register(
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [31:0] wdata,
    input wire [31:0] addr,
    input wire [3:0] pstrb,
    output wire pslverr,
    input wire debug_mode,
    input wire [63:0] cnt,
    output wire div_en,
    output wire [3:0] div_val,
    output wire halt_req,
    output wire timer_en,
    output wire tdr0_wr_sel,
    output wire tdr1_wr_sel,
    output wire [31:0] wdata_out,
    output wire interrupt,
    output wire [31:0] rdata,
    output wire timer_en_reset
);

parameter ADDR_TCR   = 12'h0;
parameter ADDR_TDR0  = 12'h04;
parameter ADDR_TDR1  = 12'h08;
parameter ADDR_TCMP0 = 12'h0C;
parameter ADDR_TCMP1 = 12'h10;
parameter ADDR_TIER  = 12'h14;
parameter ADDR_TISR  = 12'h18;
parameter ADDR_THCSR = 12'h1C;

//addr

wire [11:0] addr_tmp;
reg [7:0] reg_en;

assign addr_tmp = addr[11:0];

always @(*) begin
    case(addr_tmp)
        ADDR_TCR   : reg_en = 8'b00000001;
        ADDR_TDR0  : reg_en = 8'b00000010;
        ADDR_TDR1  : reg_en = 8'b00000100;
        ADDR_TCMP0 : reg_en = 8'b00001000;
        ADDR_TCMP1 : reg_en = 8'b00010000;
        ADDR_TIER  : reg_en = 8'b00100000;
        ADDR_TISR  : reg_en = 8'b01000000;
        ADDR_THCSR : reg_en = 8'b10000000;
        default    : reg_en = 8'b00000000;
    endcase
end

//timer H->L

reg timer_en_pre;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        timer_en_pre <= 1'b0;
    else
        timer_en_pre <= timer_en;
end

assign timer_en_reset = ~timer_en & timer_en_pre; //timer_en: H->L

//tdr0

wire [31:0] count_low;
wire [31:0] count_high;

assign count_low = cnt[31:0];
assign count_high = cnt[63:32];

wire [31:0] tdr0_nxt;
wire [31:0] tdr0_val;
reg [31:0] tdr0_tmp;

assign tdr0_val[7:0]   = (wr_en & reg_en[1]) & pstrb[0] ? wdata[7:0]   : count_low[7:0];
assign tdr0_val[15:8]  = (wr_en & reg_en[1]) & pstrb[1] ? wdata[15:8]  : count_low[15:8];
assign tdr0_val[23:16] = (wr_en & reg_en[1]) & pstrb[2] ? wdata[23:16] : count_low[23:16];
assign tdr0_val[31:24] = (wr_en & reg_en[1]) & pstrb[3] ? wdata[31:24] : count_low[31:24];

assign tdr0_nxt = ~timer_en_reset ? tdr0_val : 32'h0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tdr0_tmp <= 32'h0;
    end
    else begin
        tdr0_tmp <= tdr0_nxt;
    end
end

///tdr1

wire [31:0] tdr1_nxt;
wire [31:0] tdr1_val;
reg [31:0] tdr1_tmp;

assign tdr1_val[7:0]   = (wr_en && reg_en[2]) & pstrb[0] ? wdata[7:0]   : count_high[7:0];
assign tdr1_val[15:8]  = (wr_en && reg_en[2]) & pstrb[1] ? wdata[15:8]  : count_high[15:8];
assign tdr1_val[23:16] = (wr_en && reg_en[2]) & pstrb[2] ? wdata[23:16] : count_high[23:16];
assign tdr1_val[31:24] = (wr_en && reg_en[2]) & pstrb[3] ? wdata[31:24] : count_high[31:24];

assign tdr1_nxt = ~timer_en_reset ? tdr1_val : 32'h0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tdr1_tmp <= 32'h0;
    end
    else begin
        tdr1_tmp <= tdr1_nxt;
    end
end

assign tdr0_wr_sel = (wr_en && reg_en[1]);
assign tdr1_wr_sel = (wr_en && reg_en[2]);

assign wdata_out = tdr0_wr_sel ? tdr0_val:
                   tdr1_wr_sel ? tdr1_val:
                   32'h0;

//tcr timer_en

wire timer_en_tmp;
reg [31:0] tcr;

assign timer_en = tcr[0];
assign timer_en_tmp = (wr_en & reg_en[0]) & ~pslverr & pstrb[0] ? wdata[0] : timer_en;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tcr[0] <= 1'b0;
    end else begin
        tcr[0] <= timer_en_tmp;
    end
end

//div_en

wire div_en_tmp;
wire div_en_err;

assign div_en = tcr[1];
assign div_en_tmp = (wr_en & reg_en[0]) & pstrb[0] & ~pslverr ? wdata[1] : div_en;

assign div_en_err = (wr_en & reg_en[0]) & timer_en & (wdata[1] != div_en) & pstrb[0]; //timer_en = 1, cant change div_en

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tcr[1] <= 1'b0;
    end else begin
        tcr[1] <= div_en_tmp;
    end
end

//div_val

wire [3:0] div_val_tmp;
wire div_val_chk;
wire div_val_err_1;
wire div_val_err_2;

assign div_val = tcr[11:8];

assign div_val_chk = (wdata[11:8] <= 4'h8) & (wr_en & reg_en[0]) & pstrb[1];

assign div_val_tmp = div_val_chk & ~pslverr ? wdata[11:8] : div_val;

assign div_val_err_1 = (wr_en & reg_en[0]) & pstrb[1] & (wdata[11:8] > 8);
assign div_val_err_2 = (wr_en & reg_en[0]) & pstrb[1] & (wdata[11:8] != div_val) & timer_en;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tcr[11:8] <= 1'b1;
    else
        tcr[11:8] <= div_val_tmp;
end

//tcr

wire [31:0] tcr_tmp;

assign tcr_tmp = {20'h0, div_val_tmp, 6'h0, div_en_tmp, timer_en_tmp};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tcr <= 32'h0000_0100;
    else
        tcr <= tcr_tmp;
end

//tcmp0

reg [31:0] tcmp0;
wire [31:0] tcmp0_tmp;

assign tcmp0_tmp[7:0]   = (wr_en && reg_en[3]) & pstrb[0] ? wdata[7:0]   : tcmp0[7:0];
assign tcmp0_tmp[15:8]  = (wr_en && reg_en[3]) & pstrb[1] ? wdata[15:8]  : tcmp0[15:8];
assign tcmp0_tmp[23:16] = (wr_en && reg_en[3]) & pstrb[2] ? wdata[23:16] : tcmp0[23:16];
assign tcmp0_tmp[31:24] = (wr_en && reg_en[3]) & pstrb[3] ? wdata[31:24] : tcmp0[31:24];

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tcmp0 <= 32'hffff_ffff;
    else
        tcmp0 <= tcmp0_tmp;
end

//tcmp1

reg [31:0] tcmp1;
wire [31:0] tcmp1_tmp;

assign tcmp1_tmp[7:0]   = (wr_en && reg_en[4]) & pstrb[0] ? wdata[7:0]   : tcmp1[7:0];
assign tcmp1_tmp[15:8]  = (wr_en && reg_en[4]) & pstrb[1] ? wdata[15:8]  : tcmp1[15:8];
assign tcmp1_tmp[23:16] = (wr_en && reg_en[4]) & pstrb[2] ? wdata[23:16] : tcmp1[23:16];
assign tcmp1_tmp[31:24] = (wr_en && reg_en[4]) & pstrb[3] ? wdata[31:24] : tcmp1[31:24];

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tcmp1 <= 32'hffff_ffff;
    else
        tcmp1 <= tcmp1_tmp;
end

//tcmp

wire [63:0] tcmp;
wire tcmp_compare;

assign tcmp = {tcmp1, tcmp0};
assign tcmp_compare = (tcmp == cnt);

//tier

reg [31:0] tier;
wire [31:0] tier_tmp;
wire int_en;
wire int_en_tmp;

assign int_en = tier[0];
assign int_en_tmp = (wr_en & reg_en[5]) & pstrb[0] ? wdata[0] : int_en;

assign tier_tmp = {31'h0, int_en_tmp};

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tier <= 32'h0;
    else
        tier <= tier_tmp;
end

//tisr

wire [31:0] tisr_tmp;
reg [31:0] tisr;
wire int_clr;
wire int_st;
wire int_st_tmp;

assign int_st = tisr[0];
assign int_clr = (wr_en & reg_en[6]) & pstrb[0] & (wdata[0] == 1'b1); //write 1 clear int_st
assign int_st_tmp = int_clr ? 1'b0 :
                    tcmp_compare ? 1'b1 :
                    int_st;

assign tisr_tmp = {31'h0, int_st_tmp};

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tisr <= 32'h0;
    else
        tisr <= tisr_tmp;
end

//thcsr

assign interrupt = int_en_tmp & int_st_tmp;

wire halt_ack_tmp;
wire halt_reg_tmp;
reg [31:0] thcsr;
wire [31:0] thcsr_tmp;

assign halt_req = thcsr[0];
assign halt_req_tmp = (wr_en & reg_en[7]) & pstrb[0] ? wdata[0] : halt_req;

assign halt_ack = thcsr[1];
assign halt_ack_tmp = debug_mode & halt_req_tmp;
assign thcsr_tmp = {30'h0, halt_ack_tmp, halt_req_tmp};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        thcsr <= 32'h0;
    else
        thcsr <= thcsr_tmp;
end

assign pslverr = div_val_err_1 | div_val_err_2 | div_en_err;

//read logic

reg [31:0] rdata_tmp;
always @(*) begin
    if(rd_en) begin
        case (addr_tmp)
            ADDR_TCR   : rdata_tmp = tcr;
            ADDR_TDR0  : rdata_tmp = tdr0_tmp;
            ADDR_TDR1  : rdata_tmp = tdr1_tmp;
            ADDR_TCMP0 : rdata_tmp = tcmp0;
            ADDR_TCMP1 : rdata_tmp = tcmp1;
            ADDR_TIER  : rdata_tmp = tier;
            ADDR_TISR  : rdata_tmp = tisr;
            ADDR_THCSR : rdata_tmp = thcsr;
            default    : rdata_tmp = 32'h0;
        endcase
    end else begin
        rdata_tmp = 32'h0;
    end
end

assign rdata = rdata_tmp;

endmodule