class fifo_seq_item extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item)
    
    // Randomizable fields
    rand bit [7:0] data_in;
    rand bit wr;
    rand bit rd;
    
    // Observed fields
    bit full;
    bit empty;
    bit [7:0] data_out;
    
    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction
    
endclass
