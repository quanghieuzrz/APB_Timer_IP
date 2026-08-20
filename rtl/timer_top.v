module timer_top(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire tim_psel,
    input wire tim_pwrite,
    input wire tim_penable,
    input wire dbg_mode,
    input wire [11:0] tim_paddr,
    output wire [31:0] tim_prdata,
    input wire [31:0] tim_pwdata,
    input wire [3:0] tim_pstrb,
    output wire tim_pslverr,
    output wire tim_pready,
    output wire tim_int
);

    wire wr_en, rd_en;
    wire div_en, timer_en, cnt_en;
    wire [3:0] div_val;
    wire [63:0] cnt;
    wire [31:0] wdata_out;
    wire [31:0] addrr;
    wire timer_en_reset, tdr0_wr_sel, tdr1_wr_sel, halt_req;

    assign addrr = {20'h4000_1, tim_paddr};

    apb u_apb(
        .clk        (sys_clk    ),
        .rst_n      (sys_rst_n  ),
        .psel       (tim_psel   ),
        .pwrite     (tim_pwrite ),
        .penable    (tim_penable),
        .pready     (tim_pready ),
        .wr_en      (wr_en      ),
        .rd_en      (rd_en      )
    );

    register u_register(
        .clk            (sys_clk        ),
        .rst_n          (sys_rst_n      ),
        .wdata          (tim_pwdata     ),
        .rdata          (tim_prdata     ),
        .pstrb          (tim_pstrb      ),
        .pslverr        (tim_pslverr    ),
        .cnt            (cnt            ),
        .div_en         (div_en         ),
        .timer_en       (timer_en       ),
        .div_val        (div_val        ),
        .interrupt      (tim_int        ),
        .debug_mode     (dbg_mode       ),
        .timer_en_reset (timer_en_reset ),
        .tdr0_wr_sel    (tdr0_wr_sel    ),
        .tdr1_wr_sel    (tdr1_wr_sel    ),
        .halt_req       (halt_req       ),
        .wdata_out      (wdata_out      ),
        .wr_en          (wr_en          ),
        .rd_en          (rd_en          ),
        .addr           (addrr          )
    );

    counter u_cnt(
        .clk            (sys_clk        ),
        .rst_n          (sys_rst_n      ),
        .cnt_en         (cnt_en         ),
        .tdr0_wr_sel    (tdr0_wr_sel    ),
        .tdr1_wr_sel    (tdr1_wr_sel    ),
        .timer_en_reset (timer_en_reset ),
        .cnt            (cnt            ),
        .wdata          (wdata_out      )
    );

    counter_control u_counter_control(
        .clk        (sys_clk    ),
        .rst_n      (sys_rst_n  ),
        .div_en     (div_en     ),
        .timer_en   (timer_en   ),
        .div_val    (div_val    ),
        .halt_req   (halt_req   ),
        .cnt_en     (cnt_en     ),
        .debug_mode (dbg_mode   )
    );

endmodule