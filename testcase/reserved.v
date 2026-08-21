task run_test;
    reg [31:0] rdata;
    integer    i;

    begin
        $display("========================================");
        $display("=== Test Case: Reserved Address Check ===");
        $display("========================================");

        // Test the last address in the 12-bit APB address space.
        $display("Write to reserved address 0xFFC");

        test_bench.apb_wr(12'hFFC, 32'hffff_ffff);
        test_bench.apb_rd(12'hFFC, rdata);
        test_bench.cmp_data(12'hFFC, rdata, 32'h0000_0000, 32'hffff_ffff);

        // Test the first reserved address after THCSR (0x1C).
        $display("Write to first reserved address after THCSR");

        // Test other reserved addresses:
        // 0x020, 0x040, 0x080, 0x100, 0x200, 0x400, 0x800.
        for (i = 5; i < 12; i = i + 1) begin
            test_bench.apb_wr(1 << i, 32'hffff_ffff);
            test_bench.apb_rd(1 << i, rdata);

            test_bench.cmp_data(1 << i, rdata, 32'h0000_0000, 32'hffff_ffff);
        end

        if (test_bench.err != 0)
            $display("TEST RESERVED FAILED");
        else
            $display("TEST RESERVED PASSED");
    end
endtask