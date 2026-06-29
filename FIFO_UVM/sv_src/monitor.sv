`define MON_IF vif.MONITOR.monitor_cb

class fifo_monitor extends uvm_monitor;
    virtual fifo_interface vif;
    uvm_analysis_port #(fifo_seq_item) ap;
    
    `uvm_component_utils(fifo_monitor)
    
    // COVERGROUP - Main tracking
    covergroup fifo_functional_coverage;
        
        // Coverpoint 1: Full flag
        cp_full: coverpoint vif.full {
            bins not_full = {0};
            bins is_full = {1};
        }
        
        // Coverpoint 2: Empty flag
        cp_empty: coverpoint vif.empty {
            bins not_empty = {0};
            bins is_empty = {1};
        }
        
        // Coverpoint 3: Write signal
        cp_write: coverpoint vif.wr {
            bins no_write = {0};
            bins write_active = {1};
        }
        
        // Coverpoint 4: Read signal
        cp_read: coverpoint vif.rd {
            bins no_read = {0};
            bins read_active = {1};
        }
        
        // Coverpoint 5: Data written
        cp_data_in: coverpoint vif.data_in {
            bins zero = {8'h00};
            bins low_range = {[8'h01:8'h3F]};
            bins mid_low = {[8'h40:8'h7F]};
            bins mid_high = {[8'h80:8'hBF]};
            bins high_range = {[8'hC0:8'hFE]};
            bins all_ones = {8'hFF};
        }
        
        // Coverpoint 6: Data read
        cp_data_out: coverpoint vif.data_out {
            bins zero = {8'h00};
            bins low_range = {[8'h01:8'h3F]};
            bins mid_low = {[8'h40:8'h7F]};
            bins mid_high = {[8'h80:8'hBF]};
            bins high_range = {[8'hC0:8'hFE]};
            bins all_ones = {8'hFF};
        }
        
        // Cross coverage 1: Write vs Full
        cross_wr_full: cross cp_write, cp_full;
        
        // Cross coverage 2: Read vs Empty
        cross_rd_empty: cross cp_read, cp_empty;
        
        // Cross coverage 3: Simultaneous ops
        cross_wr_rd: cross cp_write, cp_read;
        
    endgroup
    
    int write_count = 0;
    int read_count = 0;
    int full_count = 0;
    int empty_count = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        fifo_functional_coverage = new();  // CRITICAL: Create in constructor
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_interface)::get(this, "", "vif", vif))
            `uvm_error("build_phase", "No virtual interface");
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            fifo_seq_item trans;
            trans = fifo_seq_item::type_id::create("trans");
            
            // Sample signals
            trans.wr = `MON_IF.wr;
            trans.data_in = `MON_IF.data_in;
            trans.full = `MON_IF.full;
            trans.rd = `MON_IF.rd;
            trans.data_out = `MON_IF.data_out;
            trans.empty = `MON_IF.empty;
            
            // Update stats
            if(trans.wr) write_count++;
            if(trans.rd) read_count++;
            if(trans.full) full_count++;
            if(trans.empty) empty_count++;
            
            @(posedge vif.MONITOR.clk);
            
            // Sample coverage
            fifo_functional_coverage.sample();
            
            // Send to scoreboard
            ap.write(trans);
        end
    endtask
    
    function void report_phase(uvm_phase phase);
        real cov;
        super.report_phase(phase);
        
        cov = fifo_functional_coverage.get_coverage();
        
        `uvm_info("COV", "============================================", UVM_LOW)
        `uvm_info("COV", "   FUNCTIONAL COVERAGE REPORT", UVM_LOW)
        `uvm_info("COV", "============================================", UVM_LOW)
        `uvm_info("COV", $sformatf("OVERALL: %.2f%%", cov), UVM_LOW)
        `uvm_info("COV", $sformatf("Full:    %.2f%%", fifo_functional_coverage.cp_full.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("Empty:   %.2f%%", fifo_functional_coverage.cp_empty.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("Write:   %.2f%%", fifo_functional_coverage.cp_write.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("Read:    %.2f%%", fifo_functional_coverage.cp_read.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("Data In: %.2f%%", fifo_functional_coverage.cp_data_in.get_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("Data Out:%.2f%%", fifo_functional_coverage.cp_data_out.get_coverage()), UVM_LOW)
        `uvm_info("COV", "============================================", UVM_LOW)
        `uvm_info("COV", $sformatf("Writes:%0d Reads:%0d", write_count, read_count), UVM_LOW)
        `uvm_info("COV", "============================================", UVM_LOW)
    endfunction
    
endclass
