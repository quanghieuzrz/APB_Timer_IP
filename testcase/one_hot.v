task run_test;
    reg [31:0] rdata;

    begin
        $display("========================================");
        $display("=== Test Case: Check One-Hot Fields   ===");
        $display("========================================");

        // Write all bits as 1-patterns. Reserved bits must remain unchanged.
        test_bench.apb_wr(ADDR_TISR,  32'h1111_1111);
        test_bench.apb_wr(ADDR_TCR,   32'h2222_2222);
        test_bench.apb_wr(ADDR_TDR0,  32'h3333_3333);
        test_bench.apb_wr(ADDR_TDR1,  32'h4444_4444);
        test_bench.apb_wr(ADDR_TCMP0, 32'h5555_5555);
        test_bench.apb_wr(ADDR_TCMP1, 32'h6666_6666);
        test_bench.apb_wr(ADDR_TIER,  32'h7777_7777);
        test_bench.apb_wr(ADDR_THCSR, 32'h8888_8888);

        // TISR: only int_st bit is implemented. Writing 1 clears it.
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hffff_ffff);

        // TCR: div_val = 2, div_en = 1, timer_en = 0.
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0202, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h3333_3333, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h4444_4444, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h5555_5555, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h6666_6666, 32'hffff_ffff);

        // TIER: only int_en bit 0 is implemented.
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hffff_ffff);

        // THCSR: halt request is accepted only in debug mode.
        // dbg_mode is 0 by default, so its readback remains 0.
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hffff_ffff);

        if (test_bench.err != 0)
            $display("TEST ONE_HOT FAILED");
        else
            $display("TEST ONE_HOT PASSED");
    end
endtask