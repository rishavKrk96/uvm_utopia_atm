
//`include "atm_cell.sv"

class utopia_tx_monitor extends uvm_monitor;

  
  `uvm_component_utils(utopia_tx_monitor)
  
  // Virtual Interface
  virtual Utopia.TB_Tx tx_vif;
  
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
 
  
  uvm_analysis_port #(NNI_cell) item_collected_port;

 
  function new (string name = "utopia_tx_monitor",uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual Utopia.TB_Tx)::get(this, "", "tx_vif", tx_vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".tx_vif"});
  endfunction: build_phase
  
    
  extern task receive (output NNI_cell c);  

  // run phase
  virtual task run_phase(uvm_phase phase);
    
    NNI_cell trans_collected;
    ev.wait_trigger();
    
    forever begin
      
      receive(trans_collected);
      
      //trans_collected.display();
      
      item_collected_port.write(trans_collected); 
      
    end
  endtask : run_phase
   

endclass : utopia_tx_monitor

    
class utopia_rx_monitor extends uvm_monitor;

  
  `uvm_component_utils(utopia_rx_monitor)
  
  // Virtual Interface
  virtual Utopia.TB_Rx rx_vif;
  
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
 

  uvm_analysis_port #(NNI_cell) item_collected_port;
  uvm_analysis_port #(NNI_cell) item_collected_port_cov;

  // Placeholder to capture transaction information.
  //NNI_cell trans_collected;


  // new - constructor
 
  function new (string name = "utopia_rx_monitor",uvm_component parent = null);
    super.new(name, parent);
    //trans_collected = new();
    item_collected_port = new("item_collected_port", this);
    item_collected_port_cov = new("item_collected_port_cov", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual Utopia.TB_Rx)::get(this, "", "rx_vif", rx_vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".rx_vif"});
  endfunction: build_phase
  
  extern task receive (output NNI_cell c);  


  // run phase
  virtual task run_phase(uvm_phase phase);
 
    NNI_cell trans_collected;
    ev.wait_trigger();
    
    forever begin
    
    receive(trans_collected); 
    
    item_collected_port.write(trans_collected);     
    item_collected_port_cov.write(trans_collected);       
      
    end  
        
  endtask : run_phase
   

endclass : utopia_rx_monitor


    
    
//---------------------------------------------------------------------------
// receive(): Read a cell from the DUT output, pack it into a NNI cell
//---------------------------------------------------------------------------
task utopia_tx_monitor::receive(output NNI_cell c);
   ATMCellType Pkt;

   tx_vif.cbt.clav <= 1;
  
   while (tx_vif.cbt.soc !== 1'b1 && tx_vif.cbt.en !== 1'b0)
     @(tx_vif.cbt);
   for (int i=0; i<=52; i++) begin
      // If not enabled, loop
      while (tx_vif.cbt.en !== 1'b0) @(tx_vif.cbt);
      
      //$display("Receiving %0x",tx_vif.cbt.data);
      Pkt.Mem[i] = tx_vif.cbt.data;
      @(tx_vif.cbt);
   end

   tx_vif.cbt.clav <= 0;

   c = new();
   c.unpack(Pkt);
   //c.display($sformatf("@%0t: Mon%0d: ", $time, PortID));
   //c.display($sformatf("@%0t ", $time));
  
  
endtask : receive    
    
task utopia_rx_monitor::receive(output NNI_cell c);
   ATMCellType Pkt;
  
  //@(rx_vif.cbr.clav); // <= 1;
  wait (rx_vif.clav == 1);   
  
  while (rx_vif.soc !== 1'b1)
    //@(rx_vif.cbr);
    //@(posedge top.clk);
    @(posedge rx_vif.clk_in);
   for (int i=0; i<=52; i++) begin
    //@(rx_vif.cbr);
     @(posedge rx_vif.clk_in);
     //@(posedge top.clk);
     Pkt.Mem[i] = rx_vif.data;
    // $display("Transmitting : %0x",rx_vif.cbr.data);
    //@(posedge top.clk);
    // @(rx_vif.cbr);
   end

  //@(rx_vif.cbr.clav == 1'b0);
  wait (rx_vif.clav == 0);   
  
   c = new();
   c.unpack(Pkt);
   //c.display($sformatf("@%0t: Mon%0d: ", $time, PortID));
   //c.display($sformatf(" @%0t ", $time));
  
  
endtask : receive    



//`endif // MONITOR__SV
