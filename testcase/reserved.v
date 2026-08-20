task run_test;
    reg [31:0] task_rdata;
    integer    i;

    begin
        $display("========================================");
        $display("=== Test Case: Reserved Address Check ===");
        $display("========================================");

        // Test the last address in the 12-bit APB address space.
        $display("Write to reserved address 0xFFC");

        test_bench.apb_wr(12'hFFC, 32'hFFFF_FFFF);
        test_bench.apb_rd(12'hFFC, task_rdata);
        test_bench.cmp_data(
            12'hFFC,
            task_rdata,
            32'h0000_0000,
            32'hFFFF_FFFF
        );

        // Test the first reserved address after THCSR (0x1C).
        $display("Write to first reserved address after THCSR");

        // Test other reserved addresses:
        // 0x020, 0x040, 0x080, 0x100, 0x200, 0x400, 0x800.
        for (i = 5; i < 12; i = i + 1) begin
            test_bench.apb_wr(1 << i, 32'hFFFF_FFFF);
            test_bench.apb_rd(1 << i, task_rdata);

            test_bench.cmp_data(
                1 << i,
                task_rdata,
                32'h0000_0000,
                32'hFFFF_FFFF
            );
        end

        if (test_bench.err != 0)
            $display("Test_result FAILED");
        else
            $display("Test_result PASSED");
    end
endtask