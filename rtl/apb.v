module apb(
    input  wire clk,
    input  wire rst_n,
    input  wire pwrite,
    input  wire penable,
    input  wire psel,
    output wire rd_en,
    output wire wr_en,
    output wire  pready
);

    reg pready_pre;
    always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pready_pre <= 1'b0;
    else if (psel & penable & !pready_pre)
        pready_pre <= 1'b1;
    else
        pready_pre <= 1'b0;
    end
    
    assign pready = pready_pre & penable;

    assign wr_en =  pwrite & psel & penable;
    assign rd_en = ~pwrite & psel & penable;

endmodule