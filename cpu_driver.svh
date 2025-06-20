
class cpu_driver extends uvm_driver #(); 

  // Virtual Interface
  virtual cpu_ifc mif;
  CellCfgType lookup [255:0]; // copy of look-up table
  utopia_config cfg;
  //Config cfg;
  bit [`TxPorts-1:0] fwd;
 
  
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
  static uvm_event ev_next = ev_pool.get("ev_next");
  
  //int PortID;

  `uvm_component_utils(cpu_driver)
 
  // Constructor
  
  function new (string name = "cpu_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
     cfg = utopia_config::type_id::create("cfg", this);
    
    if(!uvm_config_db#(virtual cpu_ifc)::get(this, "", "mif", mif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".mif"});
    
       
    if (!uvm_config_db #(utopia_config)::get(this,"*","utopia_config", cfg))
      `uvm_fatal("FATAL MSG", "Configuration object is not set properly");

    
  endfunction: build_phase

  extern task Initialize_Host ();
  extern task HostWrite (int a, CellCfgType d); // configure
  extern task HostRead (int a, output CellCfgType d);
  extern task run();
  
  // run phase
  virtual task run_phase(uvm_phase phase);
        
    forever begin
    run();
    ev.trigger();
    $display("%t: event ev triggered", $time);
    ev_next.wait_trigger();
    end
    
  endtask : run_phase

  
endclass : cpu_driver



task cpu_driver::Initialize_Host ();
   mif.BusMode <= 1;
   mif.Addr <= 0;
   mif.DataIn <= 0;
   mif.Sel <= 1;
   mif.Rd_DS <= 1;
   mif.Wr_RW <= 1;
endtask : Initialize_Host


task cpu_driver::HostWrite (int a, CellCfgType d); // configure
   #10 mif.Addr <= a; mif.DataIn <= d; mif.Sel <= 0;
   #10 mif.Wr_RW <= 0;
   while (mif.Rdy_Dtack!==0) #10;
   #10 mif.Wr_RW <= 1; mif.Sel <= 1;
   while (mif.Rdy_Dtack==0) #10;
endtask : HostWrite


task cpu_driver::HostRead (int a, output CellCfgType d);
   #10 mif.Addr <= a; mif.Sel <= 0;
   #10 mif.Rd_DS <= 0;
   while (mif.Rdy_Dtack!==0) #10;
   #10 d = mif.DataOut; mif.Rd_DS <= 1; mif.Sel <= 1;
   while (mif.Rdy_Dtack==0) #10;
endtask : HostRead

task cpu_driver::run();
   CellCfgType CellFwd;
   Initialize_Host();

   // Configure through Host interface
  repeat (10) @(negedge top.clk);
   $write("Memory: Loading ... ");
   for (int i=0; i<=255; i++) begin
     //CellFwd.FWD = $urandom_range(14);
/*`ifdef FWDALL
     CellFwd.FWD = '1;
`else
     CellFwd.FWD = $urandom_range(2**`TxPorts-2);
`endif*/
     if(cfg.fwd_all == 1)
       CellFwd.FWD = '1;
     else
       CellFwd.FWD = $urandom_range(2**`TxPorts-2);    
      //$display("CellFwd.FWD[%0d]=%0d", i, CellFwd.FWD);
      CellFwd.VPI = i;
      HostWrite(i, CellFwd);
      lookup[i] = CellFwd;
   end

   // Verify memory
   $write("Verifying ...");
   for (int i=0; i<=255; i++) begin
      HostRead(i, CellFwd);
      if (lookup[i] != CellFwd) begin
         $display("FATAL, Mem Location 0x%x contains 0x%x, expected 0x%x",
                  i, CellFwd, lookup[i]);
         $finish;
      end
   end
   $display("Verified");

endtask : run


