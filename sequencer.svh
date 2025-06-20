class utopia_sequencer extends uvm_sequencer#(UNI_cell);

   `uvm_sequencer_utils(utopia_sequencer)
     
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : utopia_sequencer

class cpu_sequencer extends uvm_sequencer;

  `uvm_sequencer_utils(cpu_sequencer)
     
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : cpu_sequencer