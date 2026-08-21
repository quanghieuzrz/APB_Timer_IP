task run_test;
    reg [31:0] rdata;
    reg [63:0] cnt;
    reg [63:0] cnt_save;
    reg        err;

    begin
        err = 0;

        $display("========================================");
        $display("=== Test Case: Interrupt Check       ===");
        $display("========================================");

        // --------------------------------------------------------
        // Generate an interrupt when counter reaches compare value.
        // --------------------------------------------------------
        test_bench.apb_wr(ADDR_TCMP0, 32'h0000_00FF);
        test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TIER,  32'h0000_0001);
        test_bench.apb_wr(ADDR_TCR,   32'h0000_0001);

        repeat (256 + 5) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b1) begin
            $display("PASSED: Interrupt is asserted");
        end
        else begin
            $display("FAILED: Interrupt does not assert");
            err = 1;
        end

        $display("Check interrupt status is 1");
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        // --------------------------------------------------------
        // Reset and run the interrupt test again.
        // --------------------------------------------------------
        #100;
        $display("Assert reset");

        test_bench.rst_n = 1'b0;
        #100;
        @(posedge test_bench.clk);
        #1;

        $display("Release reset");
        test_bench.rst_n = 1'b1;

        $display("Configure and assert interrupt again");

        test_bench.apb_wr(ADDR_TCMP0, 32'h0000_00FF);
        test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TIER,  32'h0000_0001);
        test_bench.apb_wr(ADDR_TCR,   32'h0000_0001);

        repeat (256 + 5) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b1) begin
            $display("PASSED: Interrupt is asserted after reset");
        end
        else begin
            $display("FAILED: Interrupt does not assert after reset");
            err = 1;
        end

        // Save counter value. Interrupt must not stop counting.
        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt_save[31:0] = rdata;
        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt_save[63:32] = rdata;

        $display("Check interrupt status is 1");
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        // Writing zero to W1C bit must not clear interrupt status.
        $display("Write 0 to interrupt status");

        test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);

        if (test_bench.tim_int == 1'b1) begin
            $display("PASSED: Interrupt remains asserted after writing 0");
        end
        else begin
            $display("FAILED: Interrupt is cleared after writing 0");
            err = 1;
        end

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        repeat (256) @(posedge test_bench.clk);

        $display("Check counter continues while interrupt is asserted");

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;
        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if (cnt == cnt_save) begin
            $display("FAILED: Counter stops when interrupt is asserted");
            err = 1;
        end
        else begin
            $display("PASSED: Counter continues when interrupt is asserted");
        end

        // Mask interrupt output. Pending status must remain set.
        $display("Disable interrupt and check tim_int is masked");

        test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);

        if (test_bench.tim_int == 1'b1) begin
            $display("FAILED: Interrupt output is not masked");
            err = 1;
        end
        else begin
            $display("PASSED: Interrupt output is masked");
        end

        $display("Check int_st remains 1");

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        // Re-enable output: pending status should assert interrupt again.
        $display("Enable interrupt and check tim_int is asserted");

        test_bench.apb_wr(ADDR_TIER, 32'h0000_0001);

        if (test_bench.tim_int == 1'b1) begin
            $display("PASSED: Interrupt is asserted after re-enable");
        end
        else begin
            $display("FAILED: Interrupt is not asserted after re-enable");
            err = 1;
        end

        // Write 1 to W1C interrupt status bit to clear it.
        $display("Write int_st = 1 to clear interrupt status");

        test_bench.apb_wr(ADDR_TISR, 32'h0000_0001);
        repeat (5) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b1) begin
            $display("FAILED: Interrupt remains asserted after clear");
            err = 1;
        end
        else begin
            $display("PASSED: Interrupt is cleared by writing int_st = 1");
        end

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hffff_ffff);

        // --------------------------------------------------------
        // Manual interrupt condition: counter equals compare value.
        // --------------------------------------------------------
        $display("Manual condition to generate interrupt");

        test_bench.apb_wr(ADDR_TCR,   32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR0,  32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR1,  32'h0000_0000);
        test_bench.apb_wr(ADDR_TIER,  32'h0000_0000);

        // TCMP0 remains FF. Force counter to FF while timer is disabled.
        test_bench.apb_wr(ADDR_TDR0, 32'h0000_00FF);

        repeat (5) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b1) begin
            $display("FAILED: Interrupt asserts while int_en = 0");
            err = 1;
        end
        else begin
            $display("PASSED: Interrupt is masked while int_en = 0");
        end

        // Status bit is set even though output pin is masked.
        $display("Check interrupt status is 1");

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        // Enabling interrupt exposes the already pending interrupt.
        test_bench.apb_wr(ADDR_TIER, 32'h0000_0001);

        if (test_bench.tim_int == 1'b1) begin
            $display("PASSED: Interrupt asserts when enabled");
        end
        else begin
            $display("FAILED: Interrupt does not assert when enabled");
            err = 1;
        end

        // Clear while counter still equals compare value.
        // The status is asserted again because the trigger condition remains true.
        $display("Clear int_st while compare condition remains true");

        test_bench.apb_wr(ADDR_TISR, 32'h0000_0001);
        repeat (5) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b1) begin
            $display("PASSED: Interrupt reasserts while compare condition remains true");
        end
        else begin
            $display("FAILED: Interrupt does not reassert");
            err = 1;
        end

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0001, 32'hffff_ffff);

        // Remove compare condition, then clear interrupt status.
        $display("Change counter value and clear int_st");

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_00FE);
        test_bench.apb_wr(ADDR_TISR, 32'h0000_0001);

        repeat (5) @(posedge test_bench.clk);

        if (test_bench.tim_int == 1'b1) begin
            $display("FAILED: Interrupt remains asserted after clear");
            err = 1;
        end
        else begin
            $display("PASSED: Interrupt is negated after clear");
        end

        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hffff_ffff);

        if ((test_bench.err != 0) || (err != 0))
            $display("TEST INTERRUPT FAILED");
        else
            $display("TEST INTERRUPT PASSED");
    end
endtask