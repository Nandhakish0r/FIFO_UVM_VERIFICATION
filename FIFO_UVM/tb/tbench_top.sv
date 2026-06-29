module tbench_top;
    bit clk;
    bit reset;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset generation
    initial begin
        reset = 0;
        #2 reset = 1;
    end
    
    // Interface instance
    fifo_interface in(clk, reset);
    
    // DUT instance
    fifo_sync dut(
        .data_in(in.data_in),
        .clk(in.clk),
        .rst(in.rst),
        .wr(in.wr),
        .rd(in.rd),
        .empty(in.empty),
        .full(in.full),
        .data_out(in.data_out)
    );
    
    // Pass interface to UVM
    initial begin
        uvm_config_db#(virtual fifo_interface)::set(null, "*", "vif", in);
    end
    
    // Trigger test
    initial begin
        run_test("fifo_wr_then_rd_test");
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    
endmodule
