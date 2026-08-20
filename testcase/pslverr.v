task run_test;
    reg [31:0] rdata;
    reg        err;
    integer    i;

    begin
        err = 0;

        $display("========================================");
        $display("=== Test Case: PSLVERR Check          ===");
        $display("========================================");

        // Values div_val = 9..15 are prohibited.
        for (i = 9; i < 16; i = i + 1) begin
            test_bench.pslverr_exp = 1;
            test_bench.apb_wr(ADDR_TCR, i << 8);

            if (test_bench.pslverr_flag == 0) begin
                $display("----------------------------------------------");
                $display("FAILED PSLVERR: div_val = %0d", i);
                $display("----------------------------------------------");
                err = 1;
            end
            else begin
                $display("PASSED PSLVERR: div_val = %0d", i);
            end

            // Normal read must not return PSLVERR.
            test_bench.pslverr_exp = 0;
            test_bench.apb_rd(ADDR_TCR, rdata);
            test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);
        end

        // Enable the timer.
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

        // Changing div_en/div_val while timer_en = 1 is prohibited.
        test_bench.pslverr_exp = 1;
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0103);

        if (test_bench.pslverr_flag == 0) begin
            $display("FAILED PSLVERR: change TCR while timer is enabled");
            err = 1;
        end
        else begin
            $display("PASSED PSLVERR: change TCR while timer is enabled");
        end

        // Invalid write must not change TCR.
        test_bench.pslverr_exp = 0;
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        // Changing div_en from 1 to 0 while timer_en = 1 is prohibited.
        test_bench.pslverr_exp = 1;
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0100);

        if (test_bench.pslverr_flag == 0) begin
            $display("FAILED PSLVERR: change div_en while timer is enabled");
            err = 1;
        end
        else begin
            $display("PASSED PSLVERR: change div_en while timer is enabled");
        end

        // TCR remains unchanged after the invalid write.
        test_bench.pslverr_exp = 0;
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        // Changing div_en from 0 to 1 while timer_en = 1 is prohibited.
        test_bench.pslverr_exp = 1;
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0002);

        if (test_bench.pslverr_flag == 0) begin
            $display("FAILED PSLVERR: change div_en while timer is enabled");
            err = 1;
        end
        else begin
            $display("PASSED PSLVERR: change div_en while timer is enabled");
        end

        // TCR remains unchanged after the invalid write.
        test_bench.pslverr_exp = 0;
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

        if ((test_bench.err != 0) || (err != 0))
            $display("TEST PSLVERR FAILED");
        else
            $display("TEST PSLVERR PASSED");
    end
endtask