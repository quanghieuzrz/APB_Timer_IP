module apb(
    input  wire clk,
    input  wire rst_n,
    input  wire pwrite,
    input  wire penable,
    input  wire psel,
    output wire rd_en,
    output wire wr_en,
    output reg  pready
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pready <= 1'b0;
        else if (psel & penable & !pready)
            pready <= 1'b1;          // wait state: assert pready 1 cycle after SETUP->ACCESS
        else
            pready <= 1'b0;          // clears as soon as transaction completes or idle
    end

    assign wr_en =  pwrite & psel & penable & pready;
    assign rd_en = ~pwrite & psel & penable & pready;

endmodule