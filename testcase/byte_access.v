task run_test;
    reg [31:0] task_rdata;

    begin
        $display("========================================");
        $display("=== Test Case: Byte Access Check      ===");
        $display("========================================");

        // --------------------------------------------------------
        // TCR
        // --------------------------------------------------------
        $display("*TCR*");

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_F5FF, PSTRB1);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0500, 32'hFFFF_FF00);

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FFFF, PSTRB0);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0503, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FF00, PSTRB2);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0503, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FF00, PSTRB3);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0503, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0002, PSTRB0);
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB0);

        test_bench.apb_pstrb(ADDR_TCR, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0501, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FFFF, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0501, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB0);
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB1);

        // --------------------------------------------------------
        // TDR0
        // --------------------------------------------------------
        $display("*TDR0*");

        test_bench.apb_pstrb(ADDR_TDR0, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h0000_0011, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h0000_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h0033_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR0, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h6666_5555, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // TDR1
        // --------------------------------------------------------
        $display("*TDR1*");

        test_bench.apb_pstrb(ADDR_TDR1, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        test_bench.cmp_data(ADDR_TDR1, task_rdata, 32'h0000_0011, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        test_bench.cmp_data(ADDR_TDR1, task_rdata, 32'h0000_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        test_bench.cmp_data(ADDR_TDR1, task_rdata, 32'h0033_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        test_bench.cmp_data(ADDR_TDR1, task_rdata, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        test_bench.cmp_data(ADDR_TDR1, task_rdata, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TDR1, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        test_bench.cmp_data(ADDR_TDR1, task_rdata, 32'h6666_5555, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // TCMP0
        // --------------------------------------------------------
        $display("*TCMP0*");

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TCMP0, task_rdata);
        test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'hFFFF_FF11, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TCMP0, task_rdata);
        test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'hFFFF_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TCMP0, task_rdata);
        test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'hFF33_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TCMP0, task_rdata);
        test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCMP0, task_rdata);
        test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP0, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCMP0, task_rdata);
        test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'h6666_5555, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // TCMP1
        // --------------------------------------------------------
        $display("*TCMP1*");

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TCMP1, task_rdata);
        test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'hFFFF_FF11, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TCMP1, task_rdata);
        test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'hFFFF_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TCMP1, task_rdata);
        test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'hFF33_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TCMP1, task_rdata);
        test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'h4433_2211, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h5555_5555, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCMP1, task_rdata);
        test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'h4433_5555, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCMP1, 32'h6666_6666, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCMP1, task_rdata);
        test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'h6666_5555, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // TIER
        // --------------------------------------------------------
        $display("*TIER*");

        test_bench.apb_pstrb(ADDR_TIER, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h6666_6666, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h7777_7777, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);

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

        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB1);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB2);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB3);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        // Move counter away from compare value, then clear int_st.
        test_bench.apb_wr(ADDR_TDR0, 32'h0000_000B);
        test_bench.apb_pstrb(ADDR_TISR, 32'h0000_0001, PSTRB0);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_000A);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_000B);
        test_bench.apb_pstrb(ADDR_TISR, 32'h0000_0001, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // THCSR
        // --------------------------------------------------------
        $display("*THCSR*");

        test_bench.apb_pstrb(ADDR_THCSR, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h2222_2222, PSTRB1);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h3333_3333, PSTRB2);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h6666_6666, PSTRB_15_0);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h7777_7777, PSTRB_31_16);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);

        if (test_bench.err != 0)
            $display("Test_result FAILED");
        else
            $display("Test_result PASSED");
    end
endtask