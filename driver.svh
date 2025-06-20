/**********************************************************************
 * Definition of an ATM driver
 *
 * Author: Chris Spear
 * Revision: 1.01
 * Last modified: 8/2/2011
 *
 * (c) Copyright 2008-2011, Chris Spear, Greg Tumbush. *** ALL RIGHTS RESERVED ***
 * http://chris.spear.net
 *
 *  This source file may be used and distributed without restriction
 *  provided that this copyright statement is not removed from the file
 *  and that any derivative work contains this copyright notice.
 *
 * Used with permission in the book, "SystemVerilog for Verification"
 * By Chris Spear and Greg Tumbush
 * Book copyright: 2008-2011, Springer LLC, USA, Springer.com
 *********************************************************************/

//`ifndef DRIVER__SV
//`define DRIVER__SV

//`include "atm_cell.sv"


class utopia_driver extends uvm_driver #(UNI_cell); //#(utopia_seq_item);

  // Virtual Interface
  virtual Utopia.TB_Rx rx_vif;
  
  //int PortID;

  `uvm_component_utils(utopia_driver)
  
   static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
   static uvm_event ev = ev_pool.get("ev");
    
  //uvm_analysis_port #(utopia_seq_item) Drvr2Sb_port;

  // Constructor
  //function new (string name = "utopia_driver", uvm_component parent, input int PortID = 0);
  function new (string name = "utopia_driver", uvm_component parent);
    super.new(name, parent);
    //this.PortID = PortID;
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual Utopia.TB_Rx)::get(this, "", "rx_vif", rx_vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".rx_vif"});
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
    
    UNI_cell c; //sequence item
    
    bit drop = 0;
    
    // Initialize ports
    rx_vif.cbr.data  <= 0;
    rx_vif.cbr.soc   <= 0;
    rx_vif.cbr.clav  <= 0;
    
    ev.wait_trigger();
    $display("%t: event ev trigger received", $time);

    forever begin
      seq_item_port.get_next_item(c);
      //respond_to_transfer(req);
      drive(c);
      seq_item_port.item_done();
    end
  endtask : run_phase

  // drive 
  virtual task drive(UNI_cell c);    
    
	  ATMCellType Pkt;

	 //c.display($sformatf("@%0t: Drv%0d: ", $time, PortID));
    
     //c.display($sformatf("@%0t: ", $time));
	 
     //ATMCellType Pkt;

     c.pack(Pkt);
     
    `uvm_info (get_type_name(), $sformatf("Sending cell:"),UVM_HIGH)
     //foreach (Pkt.Mem[i]) $write("%x ", Pkt.Mem[i]); $display;

     // Iterate through bytes of cell, deasserting Start Of Cell indicater
    @(rx_vif.cbr);
     rx_vif.cbr.clav <= 1;
    
     for (int i=0; i<=52; i++) begin
      // If not enabled, loop
       while (rx_vif.cbr.en === 1'b1) @(rx_vif.cbr);

      // Assert Start Of Cell indicater, assert enable, send byte 0 (i==0)
      rx_vif.cbr.soc  <= (i == 0);
      rx_vif.cbr.data <= Pkt.Mem[i];
      //$display("Driver : %0x",rx_vif.cbr.data);
      @(rx_vif.cbr);
     end
    
     rx_vif.cbr.soc <= 'z;
     rx_vif.cbr.data <= 8'bx;
     rx_vif.cbr.clav <= 0;
	
  endtask : drive

endclass : utopia_driver


