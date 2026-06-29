interface fifo_interface(input logic clk, rst);
    
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic empty;
    logic full;
    logic rd;
    logic wr;
    
    // Driver clocking block
    clocking driver_cb @(posedge clk);
        output data_in;
        output rd, wr;
        input full, empty;
        input data_out;
    endclocking
    
    // Monitor clocking block
    clocking monitor_cb @(posedge clk);
        input data_in;
        input rd, wr;
        input full, empty;
        input data_out;
    endclocking
    
    // Modports
    modport DRIVER(clocking driver_cb, input clk, rst);
    modport MONITOR(clocking monitor_cb, input clk, rst);
    
endinterface
