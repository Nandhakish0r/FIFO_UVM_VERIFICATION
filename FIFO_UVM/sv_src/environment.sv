class fifo_environment extends uvm_env;
    `uvm_component_utils(fifo_environment)
    
    fifo_agent agt;
    fifo_scoreboard scb;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = fifo_agent::type_id::create("agt", this);
        scb = fifo_scoreboard::type_id::create("scb", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.scb_port);
        `uvm_info("FIFO_ENVIRONMENT", "Connected monitor to scoreboard", UVM_LOW)
    endfunction
endclass
