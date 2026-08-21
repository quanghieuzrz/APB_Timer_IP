module test_bench;

    parameter ADDR_TCR   = 12'h0;
    parameter ADDR_TDR0  = 12'h04;
    parameter ADDR_TDR1  = 12'h08;
    parameter ADDR_TCMP0 = 12'h0C;
    parameter ADDR_TCMP1 = 12'h10;
    parameter ADDR_TIER  = 12'h14;
    parameter ADDR_TISR  = 12'h18;
    parameter ADDR_THCSR = 12'h1C;

    parameter PSTRB0     = 4'b0001;
    parameter PSTRB1     = 4'b0010;
    parameter PSTRB2     = 4'b0100;
    parameter PSTRB3     = 4'b1000;
    parameter PSTRB_15_0 = 4'b0011;
    parameter PSTRB_31_16 = 4'b1100;

    reg        clk;
    reg        rst_n;
    reg        psel;
    reg        pwrite;
    reg        penable;
    reg [11:0] paddr;
    reg [31:0] pwdata;
    wire [31:0] prdata;
    reg [3:0]  pstrb;
    reg        dbg_mode;
    wire       pslverr;
    wire       pready;
    wire       tim_int;
    reg        pslverr_exp;
    reg        pslverr_flag;
    reg        golden_set;
    reg [63:0] golden_val;
    wire [63:0] golden_cnt;
    integer    err;
    reg        apb_err_psel;
    reg        apb_err_penable;
    reg        pready_chk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_bench);
    end

    timer_top u_timer_top (
        .sys_clk      (clk),
        .sys_rst_n    (rst_n),
        .tim_pwrite   (pwrite),
        .tim_psel     (psel),
        .tim_penable  (penable),
        .tim_paddr    (paddr),
        .tim_pwdata   (pwdata),
        .tim_prdata   (prdata),
        .tim_pready   (pready),
        .tim_pstrb    (pstrb),
        .tim_pslverr  (pslverr),
        .tim_int      (tim_int),
        .dbg_mode     (dbg_mode)
    );

    golden_test u_golden_cnt (
        .cnt_set (golden_set),
        .cnt_val (golden_val),
        .cnt     (golden_cnt),
        .*
    );

    `ifdef TC_ALIGNED
    `include "../testcase/aligned.v"
    `elsif TC_COUNTER
    `include "../testcase/counter.v"
    `elsif TC_COUNTER_CTRL
    `include "../testcase/counter_ctrl.v"
    `elsif TC_DEFAULT
    `include "../testcase/default.v"
    `elsif TC_INTERRUPT
    `include "../testcase/interrupt.v"
    `elsif TC_ONE_HOT
    `include "../testcase/one_hot.v"
    `elsif TC_RESERVED
    `include "../testcase/reserved.v"
    `elsif TC_HALT
    `include "../testcase/halt.v"
    `elsif TC_APB_PROTOCOL
    `include "../testcase/apb_protocol.v"
    `elsif TC_PSLVERR
    `include "../testcase/pslverr.v"
    `elsif TC_PSTRB
    `include "../testcase/pstrb.v"
    `elsif TC_BYTE_ACCESS
    `include "../testcase/byte_access.v"
    `elsif TC_APB_MULTI
    `include "../testcase/apb_multiple_access.v"
    `else
    `include "../testcase/default.v"
    `endif

    initial begin
        clk = 0;
        forever #25 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #25 rst_n = 1'b1;
    end

    initial begin
        #29;
        run_test();
        #25;
        $finish;
    end

    initial begin
        paddr           = 0;
        pwdata          = 0;
        psel            = 0;
        penable         = 0;
        pwrite          = 0;
        dbg_mode        = 0;
        pstrb           = 4'b1111;
        pslverr_exp     = 0;
        golden_set      = 0;
        golden_val      = 0;
        err             = 0;
        apb_err_psel    = 0;
        apb_err_penable = 0;
        pready_chk      = 0;
        #100;
    end

    task apb_wr;
        input [31:0] address;
        input [31:0] data_in;
        begin
            pstrb = 4'b1111;
            pslverr_flag = 0;

            @(posedge clk);
            #1;
            psel   = 1 & !apb_err_psel;
            pwrite = 1;
            paddr  = address;
            pwdata = data_in;

            @(posedge clk);
            #1;
            penable = 1 & !apb_err_penable;

            if (apb_err_psel || apb_err_penable) begin
            end else begin
            #1;
            if (pready_chk && (pready == 1)) begin
            $display("FAILED PREADY");
            err = err + 1;
            end
            wait (pready == 1);
            end

            #1;
            if (pslverr !== pslverr_exp) begin
            $display("----------------------------------------------");
            $display("t=%10d. FAILED PSLVERR: expected=%b, actual=%b", $time, pslverr_exp, pslverr);
            $display("----------------------------------------------");
            err = err + 1;
            end
            else if (pslverr_exp) begin
            pslverr_flag = 1;
            end

            @(posedge clk);
            pwrite  = 0;
            psel    = 0;
            penable = 0;
            paddr   = 0;
            pwdata  = 0;
        end
    endtask

    task apb_rd;
        input  [31:0] address;
        output [31:0] rdata_out;
        begin
            pslverr_flag = 0;

            @(posedge clk);
            #1;
            psel   = 1 & !apb_err_psel;
            pwrite = 0;
            paddr  = address;

            @(posedge clk);
            #1;
            penable = 1 & !apb_err_penable;

            if (apb_err_psel || apb_err_penable) begin
            end else begin
            #1;
            if (pready_chk && (pready == 1)) begin
            $display("FAILED PREADY");
            err = err + 1;
            end
            wait (pready == 1);
            end

            #1;
            rdata_out = prdata;
            $display("rdata = %h, address = %h", rdata_out, address);

            if (pslverr !== pslverr_exp) begin
            $display("----------------------------------------------");
            $display("t=%10d. FAILED PSLVERR: expected=%b, actual=%b", $time, pslverr_exp, pslverr);
            $display("----------------------------------------------");
            err = err + 1;
            end
            else if (pslverr_exp) begin
            pslverr_flag = 1;
            end

            @(posedge clk);
            pwrite  = 0;
            psel    = 0;
            penable = 0;
            paddr   = 0;
            pwdata  = 0;
        end
    endtask

    task apb_pstrb;
        input [31:0] address;
        input [31:0] data_in;
        input [3:0]  pstrb_in;
        begin
            pstrb = pstrb_in;
            pslverr_flag = 0;

            $display("t=%10d. address = %x, data= %x",
                     $time, address, data_in);

            @(posedge clk);
            #1;
            psel   = 1 & !apb_err_psel;
            pwrite = 1;
            paddr  = address;
            pwdata = data_in;

            @(posedge clk);
            #1;
            penable = 1 & !apb_err_penable;

            if (apb_err_psel || apb_err_penable) begin
            end
            else begin
            #1;
            if (pready_chk && (pready == 1)) begin
            $display("FAILED PREADY");
            err = err + 1;
            end
            wait (pready == 1);
            end

             #1;
            if (pslverr !== pslverr_exp) begin
            $display("----------------------------------------------");
            $display("t=%10d. FAILED PSLVERR: expected=%b, actual=%b", $time, pslverr_exp, pslverr);
            $display("----------------------------------------------");
            err = err + 1;
            end
            else if (pslverr_exp) begin
            pslverr_flag = 1;
            end

            @(posedge clk);
            pstrb   = 0;
            pwrite  = 0;
            psel    = 0;
            penable = 0;
            paddr   = 0;
            pwdata  = 0;
        end
    endtask

    task cmp_data;
        input [31:0] address;
        input [31:0] data_in;
        input [31:0] data_exp;
        input [31:0] mask;

        if ((data_in & mask) !== (data_exp & mask)) begin
            $display("----------------------------------------------");
            $display("t=%10d. FAILED: data_exp = %x, data_in = %x", $time, data_exp, data_in);
            $display("----------------------------------------------");
            err = err + 1;
            #10;
        end
        else begin
            $display("----------------------------------------------");
            $display("t=%10d. PASSED: data_exp = %x, data_in = %x", $time, data_exp, data_in);
            $display("----------------------------------------------");
            #10;
        end
    endtask

    task set_golden;
        input [63:0] val;
        begin
            @(posedge clk);
            #1;
            golden_set = 1;
            golden_val = val;

            @(posedge clk);
            #1;
            golden_set = 0;
            golden_val = 0;

            @(posedge clk);
        end
    endtask

endmodule


module golden_test (
    input wire        clk,
    input wire        rst_n,
    input wire        psel,
    input wire        penable,
    input wire        pwrite,
    input wire [11:0] paddr,
    input wire [31:0] pwdata,
    input wire        cnt_set,
    input wire [63:0] cnt_val,
    input wire        dbg_mode,
    output reg [63:0] cnt
);

    parameter ADDR_TCR   = 12'h0;
    parameter ADDR_THCSR = 12'h1C;

    wire [63:0] cnt_nxt;
    wire timer_en_set;
    wire timer_en_clr;
    wire halt_set;
    wire halt_clr;

    reg timer_en;
    reg timer_en_tmp;
    reg halt_req_reg;
    reg halt_tmp;

    assign timer_en_set = psel & penable & pwrite & (paddr == ADDR_TCR) & pwdata[0];
    assign timer_en_clr = psel & penable & pwrite & (paddr == ADDR_TCR) & ~pwdata[0];

    assign halt_set = psel & penable & pwrite & (paddr == ADDR_THCSR) & pwdata[0];
    assign halt_clr = psel & penable & pwrite & (paddr == ADDR_THCSR) & ~pwdata[0];

    assign cnt_nxt = cnt_set ? cnt_val :
                    (timer_en_tmp & !halt_tmp) ? cnt + 1'b1 :
                     cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            timer_en <= 1'b0;
        else if (timer_en_clr)
            timer_en <= 1'b0;
        else if (timer_en_set)
            timer_en <= 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            halt_req_reg <= 1'b0;
        else if (halt_clr)
            halt_req_reg <= 1'b0;
        else if (halt_set)
            halt_req_reg <= 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt          <= 64'h0;
            timer_en_tmp <= 1'b0;
            halt_tmp     <= 1'b0;
        end
        else begin
            cnt          <= cnt_nxt;
            timer_en_tmp <= timer_en;
            halt_tmp     <= halt_req_reg & dbg_mode;
        end
    end

endmodule
