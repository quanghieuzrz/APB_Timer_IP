task run_test();
    reg [31:0] rdata;
    begin

        //TCR

        test_bench.apb_wr(ADDR_TCR, 32'h0);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.compare(ADDR_TCR, rdata, 32'h0);

        test_bench.pslverr_exp = 1;
        test_bench.apb_wr(ADDR_TCR, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.compare(ADDR_TCR, rdata, 32'h0);
        test_bench.pslverr_exp = 0;

        test_bench.apb_wr(ADDR_TCR, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.compare(ADDR_TCR, rdata, 32'h0000_0202);

        test_bench.pslverr_exp = 1;
        test_bench.apb_wr(ADDR_TCR, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.compare(ADDR_TCR, rdata, 32'h0202);

        test_bench.apb_wr(ADDR_TCR, 32'hffff_f22f);
        test_bench.apb_rd(ADDR_TCR, rdata);
        test_bench.compare(ADDR_TCR, rdata, 32'h203);
        test_bench.pslverr_exp = 0;

        #100;

        test_bench.rst_n = 1'b0;
        #100;
        @(posedge test_bench.clk);
        #1;
        test_bench.rst_n = 1'b1;

        //TDR0

        test_bench.apb_wr(ADDR_TDR0, 32'h0);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.compare(ADDR_TDR0, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TDR0, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.compare(ADDR_TDR0, rdata, 32'hffff_ffff);

        test_bench.apb_wr(ADDR_TDR0, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TDR0, rdata);
        test_bench.compare(ADDR_TDR0, rdata, 32'h2222_2222);

        //TDR1

        test_bench.apb_wr(ADDR_TDR1, 32'h0);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.compare(ADDR_TDR1, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TDR1, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.compare(ADDR_TDR1, rdata, 32'hffff_ffff);

        test_bench.apb_wr(ADDR_TDR1, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TDR1, rdata);
        test_bench.compare(ADDR_TDR1, rdata, 32'h2222_2222);

        //TIER

        test_bench.apb_wr(ADDR_TIER, 32'h0);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.compare(ADDR_TIER, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TIER, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.compare(ADDR_TIER, rdata, 32'h1);

        test_bench.apb_wr(ADDR_TIER, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.compare(ADDR_TIER, rdata, 32'h0);

        //TISR

        test_bench.apb_wr(ADDR_TISR, 32'h0);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.compare(ADDR_TISR, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TISR, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.compare(ADDR_TISR, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TISR, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TISR, rdata);
        test_bench.compare(ADDR_TISR, rdata, 32'h0);

        //TCMP0

        test_bench.apb_wr(ADDR_TCMP0, 32'h0);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.compare(ADDR_TCMP0, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TCMP0, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.compare(ADDR_TCMP0, rdata, 32'hffff_ffff);

        test_bench.apb_wr(ADDR_TCMP0, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TCMP0, rdata);
        test_bench.compare(ADDR_TCMP0, rdata, 32'h2222_2222);

        //TCMP1

        test_bench.apb_wr(ADDR_TCMP1, 32'h0);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.compare(ADDR_TCMP1, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TCMP1, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.compare(ADDR_TCMP1, rdata, 32'hffff_ffff);

        test_bench.apb_wr(ADDR_TCMP1, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TCMP1, rdata);
        test_bench.compare(ADDR_TCMP1, rdata, 32'h2222_2222);

        //TIER

        test_bench.apb_wr(ADDR_TIER, 32'h0);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.compare(ADDR_TIER, rdata, 32'h0);

        test_bench.apb_wr(ADDR_TIER, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.compare(ADDR_TIER, rdata, 32'h1);

        test_bench.apb_wr(ADDR_TIER, 32'h2222_2222);
        test_bench.apb_rd(ADDR_TIER, rdata);
        test_bench.compare(ADDR_TIER, rdata, 32'h0);

        //THCSR

        test_bench.apb_wr(ADDR_THCSR, 32'h0);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.compare(ADDR_THCSR, rdata, 32'h0);

        test_bench.apb_wr(ADDR_THCSR, 32'hffff_ffff);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.compare(ADDR_THCSR, rdata, 32'h1);

        test_bench.apb_wr(ADDR_THCSR, 32'h2222_2222);
        test_bench.apb_rd(ADDR_THCSR, rdata);
        test_bench.compare(ADDR_THCSR, rdata, 32'h0);

        #100;

        if(test_bench.err != 0)
            $display("TEST FUNCTION FAILED");
        else
            $display("TEST FUNCTION PASSED");
    end
endtask