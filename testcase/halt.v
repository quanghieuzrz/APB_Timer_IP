task run_test;
    reg [31:0] task_rdata;
    reg [63:0] cnt;
    reg [63:0] cnt1;
    reg [63:0] exp_value;
    reg [31:0] test_cycle;
    reg        err;
    integer    i;
    integer    j;
    integer    seed;
    reg [63:0] cnt_wdata;

    begin
        err = 0;

        $display("========================================");
        $display("=== Test Case: Counter Halt Check    ===");
        $display("========================================");

        // --------------------------------------------------------
        // When dbg_mode = 0, halt_req must not stop the counter.
        // --------------------------------------------------------
        $display("Counter is not halted when debug mode is low");

        test_bench.dbg_mode = 1'b0;
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

        // Store counter value before halt request.
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        // Request halt while debug mode is low.
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

        // halt_ack must remain 0; read value is halt_req = 1.
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(
            ADDR_THCSR,
            task_rdata,
            32'h0000_0001,
            32'hFFFF_FFFF
        );

        // Counter must still increment.
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt1[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt1[63:32] = task_rdata;

        if (cnt1 > cnt) begin
            $display("PASSED: Counter runs normally when dbg_mode = 0");
        end
        else begin
            $display("FAILED: Counter stops when dbg_mode = 0");
            err = 1;
        end

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        if (cnt > cnt1) begin
            $display("PASSED: Counter continues while halt_req = 1 in normal mode");
        end
        else begin
            $display("FAILED: Counter does not run in normal mode");
            err = 1;
        end

        // --------------------------------------------------------
        // When dbg_mode = 1, halt_req must stop the counter.
        // --------------------------------------------------------
        $display("Counter is halted when debug mode is high");

        test_bench.apb_wr(ADDR_TCR,   32'h0000_0000);
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
        test_bench.dbg_mode = 1'b1;
        test_bench.apb_wr(ADDR_TCR,   32'h0000_0001);

        // Store counter value before halt request.
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

        // halt_req = 1 and halt_ack = 1.
        test_bench.apb_rd(ADDR_THCSR, task_rdata);
        test_bench.cmp_data(
            ADDR_THCSR,
            task_rdata,
            32'h0000_0003,
            32'hFFFF_FFFF
        );

        // Counter must be stopped once halt_ack is asserted.
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt1[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt1[63:32] = task_rdata;

        repeat (256) @(posedge test_bench.clk);

        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        if (cnt == cnt1) begin
            $display("PASSED: Counter stops when halt_req = 1 in debug mode");
        end
        else begin
            $display("FAILED: Counter does not stop in debug mode");
            err = 1;
        end

        test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);

        // --------------------------------------------------------
        // Halt/resume test using system clock.
        // --------------------------------------------------------
        $display("========================================");
        $display("=== Halt and Resume: System Clock    ===");
        $display("========================================");

        seed = $time + $realtime + $stime;
        cnt_wdata[31:0]  = $urandom(seed);
        cnt_wdata[63:32] = $urandom(seed >> 1);

        test_bench.apb_wr(ADDR_TDR0, cnt_wdata[31:0]);
        test_bench.apb_wr(ADDR_TDR1, cnt_wdata[63:32]);

        test_cycle = 100;
        test_bench.set_golden(cnt_wdata);

        // timer_en = 1, div_en = 0.
        test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);
        repeat (test_cycle) @(posedge test_bench.clk);

        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        if (cnt !== test_bench.golden_cnt) begin
            $display("FAILED: Counter mismatch before resume");
            $display("Expected: %0d", test_bench.golden_cnt);
            $display("Actual:   %0d", cnt);
            err = 1;
        end
        else begin
            $display("PASSED: Counter matches golden model before resume");
        end

        // Resume counter.
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
        repeat (test_cycle) @(posedge test_bench.clk);

        // Halt again, then compare with the golden model.
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        cnt[31:0] = task_rdata;
        test_bench.apb_rd(ADDR_TDR1, task_rdata);
        cnt[63:32] = task_rdata;

        if (cnt !== test_bench.golden_cnt) begin
            $display("FAILED: Counter mismatch after resume");
            $display("Expected: %0d", test_bench.golden_cnt);
            $display("Actual:   %0d", cnt);
            err = 1;
        end
        else begin
            $display("PASSED: Counter matches golden model after resume");
        end

        test_bench.apb_wr(ADDR_TCR,   32'h0000_0000);
        test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);

        // --------------------------------------------------------
        // Halt/resume test for all divider values.
        // --------------------------------------------------------
        $display("========================================");
        $display("=== Halt and Resume: Divider Mode    ===");
        $display("========================================");

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < (2 * i + 1); j = j + 1) begin
                seed = $time + $realtime + $stime + i + j;

                cnt_wdata[31:0]  = $urandom(seed);
                cnt_wdata[63:32] = $urandom(seed >> 1);

                test_bench.apb_wr(ADDR_TDR0, cnt_wdata[31:0]);
                test_bench.apb_wr(ADDR_TDR1, cnt_wdata[63:32]);

                test_cycle = ($urandom(seed) % 1000) + 1;

                $display("Test: div_val=%0d, loop=%0d, cycle=%0d", i, j, test_cycle);

                test_bench.set_golden(cnt_wdata * (1 << i));

                // timer_en = 1, div_en = 1, div_val = i.
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h3);
                repeat (test_cycle) @(posedge test_bench.clk);

                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

                test_bench.apb_rd(ADDR_TDR0, task_rdata);
                cnt[31:0] = task_rdata;
                test_bench.apb_rd(ADDR_TDR1, task_rdata);
                cnt[63:32] = task_rdata;

                exp_value = cnt_wdata + ((test_bench.golden_cnt - (cnt_wdata * (1 << i))) >> i);

                if (cnt !== exp_value) begin
                    $display("FAILED: Divider counter mismatch before resume");
                    $display("Expected: %0d", exp_value);
                    $display("Actual:   %0d", cnt);
                    err = 1;
                end
                else begin
                    $display("PASSED: Divider counter matches before resume");
                end

                // Resume timer.
                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
                repeat (test_cycle) @(posedge test_bench.clk);

                // Halt timer again.
                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);

                test_bench.apb_rd(ADDR_TDR0, task_rdata);
                cnt1[31:0] = task_rdata;
                test_bench.apb_rd(ADDR_TDR1, task_rdata);
                cnt1[63:32] = task_rdata;

                exp_value = cnt_wdata + ((test_bench.golden_cnt - (cnt_wdata * (1 << i))) >> i);

                if (cnt1 !== exp_value) begin
                    $display("FAILED: Divider counter mismatch after resume");
                    $display("Expected: %0d", exp_value);
                    $display("Actual:   %0d", cnt1);
                    err = 1;
                end
                else begin
                    $display("PASSED: Divider counter matches after resume");
                end

                test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
                test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h2);
            end
        end

        test_bench.dbg_mode = 1'b0;

        if ((test_bench.err != 0) || (err != 0))
            $display("Test_result FAILED");
        else
            $display("Test_result PASSED");
    end
endtask