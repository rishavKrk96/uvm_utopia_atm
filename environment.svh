/**********************************************************************
 * Definition of the environment class for the ATM testbench
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


///


class utopia_env extends uvm_env;
  
  `uvm_component_utils(utopia_env)
  
 
  
  utopia_config cfg;
  utopia_rx_agent utopia_agnt_Rx[`RxPorts];
  utopia_tx_agent utopia_agnt_Tx[`TxPorts];
  
  //utopia_rx_agent utopia_agnt_Rx[cfg.numRx];
  //utopia_tx_agent utopia_agnt_Tx[cfg.numTx];
 
  cpu_agent cpu_agnt;
  
  int i,j,k,l,m;
  
  
  utopia_scoreboard utopia_scbd;
  utopia_coverage utopia_cov;
  
  // new - constructor
  function new(string name = "utopia_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cfg = utopia_config::type_id::create("cfg", this);
    if (!uvm_config_db #(utopia_config)::get(this,"*","utopia_config", cfg))
      `uvm_fatal("FATAL MSG", "Configuration object is not set properly");
    
    for(i=0;i<`RxPorts;i++)
      utopia_agnt_Rx[i] = utopia_rx_agent::type_id::create($sformatf("utopia_agnt_Rx[%0d]", i), this);
    
    for(j=0;j<`TxPorts;j++)
      utopia_agnt_Tx[j] = utopia_tx_agent::type_id::create($sformatf("utopia_agnt_Tx[%0d]", j), this);
    
    //for(k=0;k<`TxPorts;k++)
      //utopia_scbd[k] = utopia_scoreboard::type_id::create($sformatf("utopia_scbd[%0d]", k),this);
    
    utopia_scbd = utopia_scoreboard::type_id::create("utopia_scbd",this);
    utopia_cov = utopia_coverage::type_id::create("utopia_cov",this);
    
    cpu_agnt = cpu_agent::type_id::create("cpu_agnt", this);
    
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
    //utopia_agnt.utopia_mon.item_collected_port.connect(utopia_scbd.item_collected_export);
    
    for(l=0;l<`TxPorts;l++) utopia_agnt_Tx[l].utopia_mon.item_collected_port.connect(utopia_scbd.tlm_a_fifo_rcvd[l].analysis_export);
    
    for(k=0;k<`RxPorts;k++)  utopia_agnt_Rx[k].utopia_mon.item_collected_port.connect(utopia_scbd.tlm_a_fifo_sent[k].analysis_export);

    
    for(m=0;m<`RxPorts;m++)    utopia_agnt_Rx[m].utopia_mon.item_collected_port_cov.connect(utopia_cov.tlm_a_fifo_cov[m].analysis_export);

    
    
    //for(l=0;l<`TxPorts;l++) utopia_agnt_Tx[l].utopia_mon.item_collected_port.connect(utopia_scbd[l].rcvd_item_collected_export);
    
    //for(m=0;m<`RxPorts;m++) utopia_agnt_Rx[m].utopia_mon.item_collected_port.connect(utopia_scbd[m].sent_item_collected_export);
  
 
  endfunction : connect_phase
  
  
endclass : utopia_env





