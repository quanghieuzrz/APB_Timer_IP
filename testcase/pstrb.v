task run_test;
    reg [31:0] task_rdata;
    reg [31:0] expected_data;
    reg [31:0] write_data;
    reg [11:0] reg_addr;
    integer    i;
    integer    j;

    begin
        $display("========================================");
        $display("=== Test Case: APB PSTRB Check       ===");
        $display("========================================");

        // --------------------------------------------------------
        // TCR: valid fields are div_val[11:8], div_en[1], timer_en[0].
        // --------------------------------------------------------
        $display("*TCR*");

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_F2FF, PSTRB1);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0200, 32'hFFFF_FF00);

        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FFFF, PSTRB0);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0203, 32'hFFFF_FFFF);

        // Bytes 2 and 3 are reserved for TCR.
        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FFFF, PSTRB2);
        test_bench.apb_pstrb(ADDR_TCR, 32'hFFFF_FFFF, PSTRB3);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0203, 32'hFFFF_FFFF);

        // Disable timer and divider before changing TCR fields.
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0002, PSTRB0);
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB0);

        test_bench.apb_pstrb(ADDR_TCR, 32'h2222_2222, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0202, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TCR, 32'h2222_2222, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TCR, task_rdata);
        test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0202, 32'hFFFF_FFFF);

        // Reset TCR fields for the following tests.
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB0);
        test_bench.apb_pstrb(ADDR_TCR, 32'h0000_0000, PSTRB1);

        // --------------------------------------------------------
        // TDR0, TDR1, TCMP0, TCMP1: full 32-bit RW registers.
        // --------------------------------------------------------
        for (j = 0; j < 4; j = j + 1) begin
            case (j)
                0: reg_addr = ADDR_TDR0;
                1: reg_addr = ADDR_TDR1;
                2: reg_addr = ADDR_TCMP0;
                default: reg_addr = ADDR_TCMP1;
            endcase

            $display("Test byte access at address %h", reg_addr);

            // Start from zero so each byte update is easy to verify.
            test_bench.apb_wr(reg_addr, 32'h0000_0000);
            expected_data = 32'h0000_0000;

            // Write byte 0 through byte 3.
            for (i = 0; i < 4; i = i + 1) begin
                write_data = 32'h0000_0011 << (i * 8);
                expected_data = expected_data | write_data;

                test_bench.apb_pstrb(reg_addr, write_data, (4'b0001 << i));
                test_bench.apb_rd(reg_addr, task_rdata);
                test_bench.cmp_data(reg_addr, task_rdata, expected_data, 32'hFFFF_FFFF);
            end

            // Update lower half word.
            test_bench.apb_pstrb(reg_addr, 32'hAAAA_AAAA, PSTRB_15_0);
            expected_data[15:0] = 16'hAAAA;

            test_bench.apb_rd(reg_addr, task_rdata);
            test_bench.cmp_data(reg_addr, task_rdata, expected_data, 32'hFFFF_FFFF);

            // Update upper half word.
            test_bench.apb_pstrb(reg_addr, 32'hBBBB_BBBB, PSTRB_31_16);
            expected_data[31:16] = 16'hBBBB;

            test_bench.apb_rd(reg_addr, task_rdata);
            test_bench.cmp_data(reg_addr, task_rdata, expected_data, 32'hFFFF_FFFF);
        end

        // --------------------------------------------------------
        // TIER: only int_en bit 0 is writable.
        // --------------------------------------------------------
        $display("*TIER*");

        test_bench.apb_pstrb(ADDR_TIER, 32'h1111_1111, PSTRB0);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h1, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h2222_2222, PSTRB1);
        test_bench.apb_pstrb(ADDR_TIER, 32'h3333_3333, PSTRB2);
        test_bench.apb_pstrb(ADDR_TIER, 32'h4444_4444, PSTRB3);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h1, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h6666_6666, PSTRB_15_0);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_TIER, 32'h5555_5555, PSTRB_31_16);
        test_bench.apb_rd(ADDR_TIER, task_rdata);
        test_bench.cmp_data(ADDR_TIER, task_rdata, 32'h0, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // TISR: int_st is a W1C bit in byte 0.
        // --------------------------------------------------------
        $display("*TISR*");

        // Create interrupt status: counter equals compare value.
        test_bench.apb_wr(ADDR_TIER,  32'h1);
        test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
        test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR1,  32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR0,  32'hFFFF_FFFF);

        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h1, 32'hFFFF_FFFF);

        // Strobed bytes that do not contain bit 0 cannot clear int_st.
        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB1);
        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB2);
        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB3);

        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h1, 32'hFFFF_FFFF);

        // Move counter away from compare value, then clear W1C status.
        test_bench.apb_wr(ADDR_TDR1, 32'h0000_0002);
        test_bench.apb_pstrb(ADDR_TISR, 32'hFFFF_FFFF, PSTRB0);

        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0, 32'hFFFF_FFFF);

        // Trigger again, then clear using lower half-word strobe.
        test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR0, 32'hFFFF_FFFF);

        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h1, 32'hFFFF_FFFF);

        test_bench.apb_wr(ADDR_TDR1, 32'h0000_0002);
        test_bench.apb_pstrb(ADDR_TISR, 32'h0000_0001, PSTRB_15_0);

        test_bench.apb_rd(ADDR_TISR, task_rdata);
        test_bench.cmp_data(ADDR_TISR, task_rdata, 32'h0, 32'hFFFF_FFFF);

        // --------------------------------------------------------
        // THCSR: halt_req is bit 0; other bits are reserved.
        // --------------------------------------------------------
        $display("*THCSR*");

        test_bench.apb_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, PSTRB0);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h1, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'hAAAA_AAAA, PSTRB1);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h1, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'h2222_2222, PSTRB_15_0);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0, 32'hFFFF_FFFF);

        test_bench.apb_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, PSTRB_31_16);
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(ADDR_THCSR, task_rdata, 32'h0, 32'hFFFF_FFFF);

        if (test_bench.err != 0)
            $display("TEST PSTRB FAILED");
        else
            $display("TEST PSTRB PASSED");
    end
endtask