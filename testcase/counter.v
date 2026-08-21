task run_test;
    reg [31:0] rdata;
    reg [63:0] cnt;
    reg        err;

    begin
        err = 0;

        $display("==================================================");
        $display("=== Test Case: Counter Check                   ===");
        $display("==================================================");

        // Check rollover from TDR0 to TDR1.
        $display("Check rollover at TDR0 boundary");

        test_bench.apb_wr(ADDR_TDR0, 32'hffff_ff00);
        test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TCR,  32'h0000_0001);

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;

        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if ((cnt[63:32] == 32'h0000_0001) && (cnt[31:0] < 32'd10)) begin
            $display("PASSED: TDR0 rollover, cnt = %h", cnt);
        end
        else begin
            $display("FAILED: TDR0 rollover, cnt = %h", cnt);
            err = 1;
        end

        // Disable timer. Advanced level clears counter on timer_en: 1 -> 0.
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);

        // Check rollover of the full 64-bit counter.
        $display("Check rollover at TDR1 boundary");

        test_bench.apb_wr(ADDR_TDR0, 32'hffff_ff00);
        test_bench.apb_wr(ADDR_TDR1, 32'hffff_ffff);
        test_bench.apb_wr(ADDR_TCR,  32'h0000_0001);

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;

        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if ((cnt[63:32] == 32'h0000_0000) && (cnt[31:0] < 32'd10)) begin
            $display("PASSED: 64-bit rollover, cnt = %h", cnt);
        end
        else begin
            $display("FAILED: 64-bit rollover, cnt = %h", cnt);
            err = 1;
        end

        test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);

        // Check that the counter continues counting after TDR0 is written.
        $display("Check writing to counter while counting");

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TCR,  32'h0000_0001);

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;

        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if ((cnt < 64'd250) || (cnt > 64'd270)) begin
            $display("FAILED: Counter expected between 250 and 270");
            $display("Actual: %0d", cnt);
            err = 1;
        end
        else begin
            $display("PASSED: Counter value = %0d", cnt);
        end

        // Write near overflow while the timer remains enabled.
        test_bench.apb_wr(ADDR_TDR0, 32'hffff_ff00);

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;

        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if ((cnt[63:32] == 32'h0000_0001) &&
            (cnt[31:0] < 32'd10)) begin
            $display("PASSED: Counter rollover after TDR0 write, cnt = %h", cnt);
        end
        else begin
            $display("FAILED: Counter rollover after TDR0 write, cnt = %h", cnt);
            err = 1;
        end

        // Disable timer and confirm counter is cleared in advanced level.
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);

        $display("Check counter is cleared when timer_en = 0");

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;

        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if (cnt == 64'h0000_0000_0000_0000) begin
            $display("PASSED: Counter is zero when timer_en = 0");
        end
        else begin
            $display("FAILED: Counter is not zero when timer_en = 0");
            $display("Actual: %h", cnt);
            err = 1;
        end

        // Enable timer again and confirm counter restarts.
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        cnt[31:0] = rdata;

        test_bench.apb_rd(ADDR_TDR1, rdata);
        cnt[63:32] = rdata;

        if ((cnt < 64'd250) || (cnt > 64'd270)) begin
            $display("FAILED: Counter does not restart correctly");
            $display("Actual: %0d", cnt);
            err = 1;
        end
        else begin
            $display("PASSED: Counter restarts correctly, cnt = %0d", cnt);
        end

        if ((test_bench.err != 0) || (err != 0))
            $display("TEST COUNTER FAILED");
        else
            $display("TEST COUNTER PASSED");
    end
endtask