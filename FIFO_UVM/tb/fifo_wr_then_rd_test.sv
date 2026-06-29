class fifo_wr_then_rd_test extends uvm_test;
    `uvm_component_utils(fifo_wr_then_rd_test)
    
    fifo_environment env;
    fifo_wr_then_rd_sequence seq;
    virtual fifo_interface vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_environment::type_id::create("env", this);
        seq = fifo_wr_then_rd_sequence::type_id::create("seq");
        
        if(!uvm_config_db#(virtual fifo_interface)::get(this, "", "vif", vif))
            `uvm_error("build_phase", "Test virtual interface failed");
    endfunction
    
    virtual function void end_of_elaboration();
        print();
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agt.seqr);
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 50);
    endtask
endclass
