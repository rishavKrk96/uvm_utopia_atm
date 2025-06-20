class utopia_rx_agent extends uvm_agent;
  //declaring agent components
  utopia_driver    utopia_drv;
  utopia_sequencer utopia_sqncr;
  utopia_rx_monitor   utopia_mon;

  // UVM automation macros for general components
  `uvm_component_utils(utopia_rx_agent)

  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      utopia_drv = utopia_driver::type_id::create("utopia_drv", this);
      utopia_sqncr = utopia_sequencer::type_id::create("utopia_sqncr", this);
    end

    utopia_mon = utopia_rx_monitor::type_id::create("utopia_mon", this);
  endfunction : build_phase

  // connect_phase
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      utopia_drv.seq_item_port.connect(utopia_sqncr.seq_item_export);
    end
  endfunction : connect_phase

endclass : utopia_rx_agent


class utopia_tx_agent extends uvm_agent;
  //declaring agent components
  
  utopia_tx_monitor   utopia_mon;

  // UVM automation macros for general components
  `uvm_component_utils(utopia_tx_agent)

  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

   

    utopia_mon = utopia_tx_monitor::type_id::create("utopia_mon", this);
  endfunction : build_phase

  
endclass : utopia_tx_agent


class cpu_agent extends uvm_agent;
  //declaring agent components
  cpu_driver    cpu_drv;
  cpu_sequencer cpu_sqncr;
  //cpu_rx_monitor   cpu_mon;

  // UVM automation macros for general components
  `uvm_component_utils(cpu_agent)

  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      cpu_drv = cpu_driver::type_id::create("cpu_drv", this);
      cpu_sqncr = cpu_sequencer::type_id::create("cpu_sqncr", this);
    end

   
  
  endfunction : build_phase

  // connect_phase
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      cpu_drv.seq_item_port.connect(cpu_sqncr.seq_item_export);
    end
  endfunction : connect_phase

endclass : cpu_agent