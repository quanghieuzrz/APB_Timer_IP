task run_test();
    reg [31:0] rdata;
    begin

        test_bench.apb_wr(ADDR_TDR0, 32'haaaa_aaaa);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'haaaa_aaaa, 32'hffff_ffff);

        //offset 0x1 unalight
        test_bench.apb_wr(ADDR_TDR0+1, 32'hbbbb_bbbb);
        test_bench.apb_rd(ADDR_TDR0+1, rdata);
        test_bench.cmp_data(ADDR_TDR0+1, rdata, 32'h0, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'haaaa_aaaa, 32'hffff_ffff);

        //offset 0x2 unalight
        test_bench.apb_wr(ADDR_TDR0+2, 32'hbbbb_bbbb);
        test_bench.apb_rd(ADDR_TDR0+2, rdata);
        test_bench.cmp_data(ADDR_TDR0+2, rdata, 32'h0, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'haaaa_aaaa, 32'hffff_ffff);

        //offset 0x3 unalight
        test_bench.apb_wr(ADDR_TDR0+3, 32'hbbbb_bbbb);
        test_bench.apb_rd(ADDR_TDR0+3, rdata);
        test_bench.cmp_data(ADDR_TDR0+3, rdata, 32'h0, 32'hffff_ffff);

        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.cmp_data(ADDR_TDR0, rdata, 32'haaaa_aaaa, 32'hffff_ffff);

        if(test_bench.err != 0)
            $display("TEST ALIGNED FAILED");
        else
            $display("TEST ALIGNED PASSED");
    end
endtask