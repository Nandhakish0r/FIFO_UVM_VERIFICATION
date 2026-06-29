// Random sequence
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)
    
    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(15) begin
            req = fifo_seq_item::type_id::create("req");
            start_item(req);
            req.randomize();
            finish_item(req);
            set_response_queue_depth(15);
        end
    endtask
endclass

// Write sequence - explicit bin coverage
class fifo_write_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_sequence)
    
    fifo_seq_item item;
    
    function new(string name = "fifo_write_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        // Write one value from EACH coverage bin
        bit [7:0] required_values[6] = '{8'h00, 8'h20, 8'h60, 8'hA0, 8'hD5, 8'hFF};
        
        foreach(required_values[i]) begin
            item = fifo_seq_item::type_id::create("item");
            start_item(item);
            item.wr = 1;
            item.rd = 0;
            item.data_in = required_values[i];
            finish_item(item);
            set_response_queue_depth(15);
        end
        
        // Add random writes to fill FIFO
        repeat(6) begin
            item = fifo_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {item.wr == 1; item.rd == 0;});
            finish_item(item);
            set_response_queue_depth(15);
        end
    endtask
endclass

// Read sequence
class fifo_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_read_sequence)
    
    function new(string name = "fifo_read_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        repeat(12) begin
            `uvm_do_with(req, {req.rd == 1; req.wr == 0;})
            set_response_queue_depth(25);
        end
    endtask
endclass

// Write-Then-Read sequence (Main test)
class fifo_wr_then_rd_sequence extends uvm_sequence #(fifo_seq_item);
    fifo_write_sequence wr_seq;
    fifo_read_sequence rd_seq;
    
    `uvm_object_utils(fifo_wr_then_rd_sequence)
    
    function new(string name = "fifo_wr_then_rd_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        `uvm_do(wr_seq)  // Fill FIFO
        `uvm_do(rd_seq)  // Empty FIFO
    endtask
endclass
