task run_test;
    reg [31:0] rdata;

    begin
        $display("========================================");
        $display("=== Test Case: Byte Access Check      ===");
        $display("========================================");

        // --------------------------------------------------------
        // TCR
        // --------------------------------------------------------
        $display("*TCR*");

        test_bench.apb_pstrb(ADDR_TCR, 32'hffff_f5ff, PSTRB1);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0500, 32'hffff_ff00);

        test_bench.apb_pstrb(ADDR_TCR, 32'hffff_ffff, PSTRB0);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0503, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCR, 32'hffff_ff00, PSTRB2);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0503, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCR, 32'hffff_ff00, PSTRB3);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0503, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0002, PSTRB0);
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB0);

        test_bench.apb_pstrb(ADDR_TCR, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0501, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCR, 32'hffff_ffff, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0501, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB0);
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB1);

        // --------------------------------------------------------
        // TDR0
        // --------------------------------------------------------
        $display("*TDR0*");

        test_bench.apb_pstrb(ADDR_TDR0, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_0011, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0033_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h4433_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h4433_5555, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'h6666_5555, 32'hffff_ffff);

        // --------------------------------------------------------
        // TDR1
        // --------------------------------------------------------
        $display("*TDR1*");

        test_bench.apb_pstrb(ADDR_TDR1, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_0011, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0033_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h4433_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h4433_5555, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.cmp_data(ADDR_TDR1, rdata, 32'h6666_5555, 32'hffff_ffff);

        // --------------------------------------------------------
        // TCMP0
        // --------------------------------------------------------
        $display("*TCMP0*");

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hffff_ff11, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hffff_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFF33_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h4433_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h4433_5555, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h6666_5555, 32'hffff_ffff);

        // --------------------------------------------------------
        // TCMP1
        // --------------------------------------------------------
        $display("*TCMP1*");

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hffff_ff11, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hffff_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFF33_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h4433_2211, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h4433_5555, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h6666_5555, 32'hffff_ffff);

        // --------------------------------------------------------
        // TIER
        // --------------------------------------------------------
        $display("*TIER*");

        test_bench.apb_pstrb(ADDR_TIER, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TIER, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TIER, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TIER, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TIER, 32'h6666_6666, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TIER, 32'h7777_7777, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hffff_ffff);

        // --------------------------------------------------------
        // TISR: byte/half-word writes that do not include bit 0
        // must not clear the W1C interrupt-status bit.
        // --------------------------------------------------------
        $display("*TISR*");

        test_bench.apb_wr(ADDR_TIER,  32'h0000_0001);
        test_bench.apb_wr(ADDR_TCMP0, 32'h0000_000A);
        test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR1,  32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR0,  32'h0000_000A);

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TISR, 32'hffff_ffff, PSTRB1);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TISR, 32'hffff_ffff, PSTRB2);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TISR, 32'hffff_ffff, PSTRB3);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_TISR, 32'hffff_ffff, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        // Move counter away from compare value, then clear int_st.
        test_bench.apb_wr(ADDR_TDR0, 32'h0000_000B);
        test_bench.apb_pstrb(ADDR_TISR, 32'h0000_0001, PSTRB0);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hffff_ffff);

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_000A);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_000B);
        test_bench.apb_pstrb(ADDR_TISR, 32'h0000_0001, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hffff_ffff);

        // --------------------------------------------------------
        // THCSR
        // --------------------------------------------------------
        $display("*THCSR*");

        test_bench.apb_pstrb(ADDR_THCSR, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h6666_6666, PSTRB_15_0);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hffff_ffff);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h7777_7777, PSTRB_31_16);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hffff_ffff);

        if (test_bench.err != 0)
            $display("TEST BYTE_ACCESS FAILED");
        else
            $display("TEST BYTE_ACCESS PASSED");
    end
endtask