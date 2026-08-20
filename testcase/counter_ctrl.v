task run_test;
    reg [31:0] task_rdata;
    reg [63:0] cnt;
    reg [63:0] exp_value;
    reg [31:0] test_cycle;
    reg        err;
    integer    i;
    integer    j;
    integer    seed;
    reg [63:0] cnt_wdata;

    begin
        err = 0;
        i   = 0;
        j   = 0;

        $display("========================================");
        $display("=== Test Case: Counter Control Check ===");
        $display("========================================");

        $display("Check counter period with system clock");

        // Enable debug mode so the timer can be halted through THCSR.
        test_bench.dbg_mode = 1'b1;

        // --------------------------------------------------------
        // Test with system clock: div_en = 0.
        // --------------------------------------------------------
        $display("Test with system clock");

        test_cycle = 100;
        test_bench.set_golden(64'h0);

        // timer_en = 1, div_en = 0, div_val = 0
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);
        repeat (test_cycle) @(posedge test_bench.clk);

        // Halt timer before reading counter.
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;

        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        if (cnt !== test_bench.golden_cnt) begin
            $display("----------------------------------------------");
            $display("t=%0t FAILED: cnt does not match expected value", $time);
            $display("Expected: %0d", test_bench.golden_cnt);
            $display("Actual:   %0d", cnt);
            $display("----------------------------------------------");
            err = 1;
        end
        else begin
            $display("----------------------------------------------");
            $display("t=%0t PASSED: cnt matches expected value", $time);
            $display("Expected: %0d", test_bench.golden_cnt);
            $display("Actual:   %0d", cnt);
            $display("----------------------------------------------");
        end

        test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TCR,  32'h0000_0000);

        // --------------------------------------------------------
        // Test all valid div_val values with div_en = 1.
        // --------------------------------------------------------
        #10;

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < (2 * i + 1); j = j + 1) begin
                seed = $time + $realtime + $stime;
                seed = $urandom(seed);
                test_cycle = ($urandom(seed) % 1000) + 1;

                $display("Test: div_val=%0d, loop=%0d, cycle=%0d", i, j, test_cycle);

                test_bench.set_golden(64'h0);

                // timer_en = 1, div_en = 1, div_val = i
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h3);
                repeat (test_cycle) @(posedge test_bench.clk);

                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

                test_bench.apb_rd(ADDR_TDR0, task_rdata);
                cnt[31:0] = task_rdata;

                test_bench.apb_rd(ADDR_TDR1, task_rdata);
                cnt[63:32] = task_rdata;

                if (cnt !== (test_bench.golden_cnt >> i)) begin
                    $display("----------------------------------------------");
                    $display("t=%0t FAILED: divided counter mismatch", $time);
                    $display("Expected: %0d", test_bench.golden_cnt >> i);
                    $display("Actual:   %0d", cnt);
                    $display("----------------------------------------------");
                    err = 1;
                end
                else begin
                    $display("----------------------------------------------");
                    $display("t=%0t PASSED: divided counter matches", $time);
                    $display("Expected: %0d", test_bench.golden_cnt >> i);
                    $display("Actual:   %0d", cnt);
                    $display("----------------------------------------------");
                end

                test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
                test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);

                // timer_en = 0, div_en = 1, div_val = i.
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h2);
                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
                #10;
            end
        end

        // --------------------------------------------------------
        // Test a random initial counter value with system clock.
        // --------------------------------------------------------
        $display("========================================");
        $display("=== Test with random TDR0 and TDR1  ===");
        $display("========================================");

        cnt_wdata = $urandom(seed) + $urandom(seed);

        test_bench.apb_wr(ADDR_TDR0, cnt_wdata[31:0]);
        test_bench.apb_wr(ADDR_TDR1, cnt_wdata[63:32]);

        $display("Test with system clock");

        test_cycle = 100;
        test_bench.set_golden(cnt_wdata);

        // timer_en = 1, div_en = 0, div_val = 0
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);
        repeat (test_cycle) @(posedge test_bench.clk);

        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;

        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        if (cnt !== test_bench.golden_cnt) begin
            $display("----------------------------------------------");
            $display("t=%0t FAILED: random counter mismatch", $time);
            $display("Expected: %0d", test_bench.golden_cnt);
            $display("Actual:   %0d", cnt);
            $display("----------------------------------------------");
            err = 1;
        end
        else begin
            $display("----------------------------------------------");
            $display("t=%0t PASSED: random counter matches", $time);
            $display("Expected: %0d", test_bench.golden_cnt);
            $display("Actual:   %0d", cnt);
            $display("----------------------------------------------");
        end

        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
        test_bench.apb_wr(ADDR_TCR,   32'h0000_0000);

        // --------------------------------------------------------
        // Test random initial values for each divider value.
        // --------------------------------------------------------
        #10;

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < (2 * i + 1); j = j + 1) begin
                seed = $time + $realtime + $stime;
                seed = $urandom(seed);

                cnt_wdata = $urandom(seed) + $urandom(seed);

                test_bench.apb_wr(ADDR_TDR0, cnt_wdata[31:0]);
                test_bench.apb_wr(ADDR_TDR1, cnt_wdata[63:32]);

                test_cycle = ($urandom(seed) % 1000) + 1;

                $display("Test: div_val=%0d, loop=%0d, cycle=%0d", i, j, test_cycle);

                test_bench.set_golden(cnt_wdata * (1 << i));

                // timer_en = 1, div_en = 1, div_val = i
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h3);
                repeat (test_cycle) @(posedge test_bench.clk);

                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

                test_bench.apb_rd(ADDR_TDR0, task_rdata);
                cnt[31:0] = task_rdata;

                test_bench.apb_rd(ADDR_TDR1, task_rdata);
                cnt[63:32] = task_rdata;

                exp_value = cnt_wdata +
                    ((test_bench.golden_cnt -
                      (cnt_wdata * (1 << i))) >> i);

                if (cnt !== exp_value) begin
                    $display("----------------------------------------------");
                    $display("t=%0t FAILED: divided random counter mismatch", $time);
                    $display("Expected: %0d", exp_value);
                    $display("Actual:   %0d", cnt);
                    $display("----------------------------------------------");
                    err = 1;
                end
                else begin
                    $display("----------------------------------------------");
                    $display("t=%0t PASSED: divided random counter matches",
                             $time);
                    $display("Expected: %0d", exp_value);
                    $display("Actual:   %0d", cnt);
                    $display("----------------------------------------------");
                end

                #10;
                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);

                // timer_en = 0, div_en = 1, div_val = i
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h2);
            end
        end

        // --------------------------------------------------------
        // div_val must not affect speed when div_en = 0.
        // --------------------------------------------------------
        $display("Additional check");
        $display("Verify div_val does not affect counting when div_en = 0");

        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 1; j = j + 1) begin
                seed = $time + $realtime + $stime;
                seed = $urandom(seed);

                cnt_wdata = $urandom(seed) + $urandom(seed);

                test_bench.apb_wr(ADDR_TDR0, cnt_wdata[31:0]);
                test_bench.apb_wr(ADDR_TDR1, cnt_wdata[63:32]);

                test_cycle = ($urandom(seed) % 1000) + 1;

                $display("Test: div_val=%0d, loop=%0d, cycle=%0d", i, j, test_cycle);

                test_bench.set_golden(cnt_wdata);

                // timer_en = 1, div_en = 0, div_val = i
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h1);
                repeat (test_cycle) @(posedge test_bench.clk);

                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

                test_bench.apb_rd(ADDR_TDR0, task_rdata);
                cnt[31:0] = task_rdata;

                test_bench.apb_rd(ADDR_TDR1, task_rdata);
                cnt[63:32] = task_rdata;

                if (cnt !== test_bench.golden_cnt) begin
                    $display("----------------------------------------------");
                    $display("t=%0t FAILED: div_en=0 counter mismatch", $time);
                    $display("Expected: %0d", test_bench.golden_cnt);
                    $display("Actual:   %0d", cnt);
                    $display("----------------------------------------------");
                    err = 1;
                end
                else begin
                    $display("----------------------------------------------");
                    $display("t=%0t PASSED: div_en=0 counter matches", $time);
                    $display("Expected: %0d", test_bench.golden_cnt);
                    $display("Actual:   %0d", cnt);
                    $display("----------------------------------------------");
                end

                #10;
                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);

                // timer_en = 0, div_en = 0, div_val = i
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h0);
            end
        end

        if ((test_bench.err != 0) || (err != 0))
            $display("Test_result FAILED");
        else
            $display("Test_result PASSED");
    end
endtask