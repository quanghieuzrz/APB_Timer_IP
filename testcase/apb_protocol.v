task run_test;
    reg [31:0] task_rdata;

    begin
        $display("========================================");
        $display("=== Test Case: APB Protocol Test     ===");
        $display("========================================");

        // Normal APB write/read transaction.
        test_bench.apb_wr(ADDR_TDR0, 32'h3333_3333);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h3333_3333, 32'hFFFF_FFFF);

        // Invalid write/read: PENABLE is not asserted.
        $display("Check behavior when PENABLE is not asserted");

        test_bench.apb_err_penable = 1;
        test_bench.apb_wr(ADDR_TDR0, 32'h5555_5555);
        test_bench.apb_err_penable = 0;

        // Invalid write must not modify TDR0.
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h3333_3333, 32'hFFFF_FFFF);

        // The testbench expects invalid read data to be zero.
        test_bench.apb_err_penable = 1;
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(
            ADDR_TDR0,
            task_rdata,
            32'h0000_0000,
            32'hFFFF_FFFF
        );
        test_bench.apb_err_penable = 0;

        // Invalid write/read: PSEL is not asserted.
        $display("Check behavior when PSEL is not asserted");

        test_bench.apb_err_psel = 1;
        test_bench.apb_wr(ADDR_TDR0, 32'h7777_7777);
        test_bench.apb_err_psel = 0;

        // Invalid write must not modify TDR0.
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h3333_3333, 32'hFFFF_FFFF);

        // The testbench expects invalid read data to be zero.
        test_bench.apb_err_psel = 1;
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h0000_0000, 32'hFFFF_FFFF);
        test_bench.apb_err_psel = 0;

        // Confirm APB transactions still work after invalid transfers.
        test_bench.apb_wr(ADDR_TDR0, 32'h9999_9999);
        test_bench.apb_rd(ADDR_TDR0, task_rdata);
        test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h9999_9999, 32'hFFFF_FFFF);

        if (test_bench.err != 0)
            $display("Test_result FAILED");
        else
            $display("Test_result PASSED");
    end
endtask
