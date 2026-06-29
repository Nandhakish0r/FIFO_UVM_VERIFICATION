class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    
    uvm_analysis_imp #(fifo_seq_item, fifo_scoreboard) scb_port;
    
    fifo_seq_item que[$];
    fifo_seq_item trans;
    bit [7:0] mem[$];  // Reference FIFO
    bit [7:0] tx_data;
    bit read_delay_clk;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_port = new("scb_port", this);
    endfunction
    
    function void write(fifo_seq_item transaction);
        que.push_back(transaction);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            wait(que.size() > 0);
            trans = que.pop_front();
            
            // WRITE: Update reference
            if(trans.wr == 1) begin
                mem.push_back(trans.data_in);
            end
            
            // READ: Compare with reference
            if(trans.rd == 1 || (read_delay_clk != 0)) begin
                if(read_delay_clk == 0)
                    read_delay_clk = 1;
                else begin
                    if(trans.rd == 0)
                        read_delay_clk = 0;
                    
                    if(mem.size > 0) begin
                        tx_data = mem.pop_front();
                        if(trans.data_out == tx_data) begin
                            `uvm_info("SCOREBOARD", "EXPECTED MATCH", UVM_MEDIUM)
                            `uvm_info("SCOREBOARD", $sformatf("Exp=%0d, Rec=%0d", tx_data, trans.data_out), UVM_MEDIUM)
                        end else begin
                            `uvm_error("SCOREBOARD", "FAILED MATCH")
                            `uvm_error("SCOREBOARD", $sformatf("Exp=%0d, Rec=%0d", tx_data, trans.data_out))
                        end
                    end
                end
            end else begin
                read_delay_clk = 0;
            end
        end
    endtask
endclass
