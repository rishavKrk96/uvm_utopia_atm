/**********************************************************************
 * Utopia ATM testbench
 *
 * To simulate this example with stimulus, invoke simulation on
 * 10.00.00_example_top.sv.  This top-level file includes all of the
 * example files in chapter 10.
 *
 * Author: Lee Moore, Stuart Sutherland
 *
 * (c) Copyright 2003, Sutherland HDL, Inc. *** ALL RIGHTS RESERVED ***
 * www.sutherland-hdl.com
 *
 * This example is based on an example from Janick Bergeron's
 * Verification Guild[1].  The original example is a non-synthesizable
 * behavioral model written in Verilog-1995 of a quad Asynchronous
 * Transfer Mode (ATM) user-to-network interface and forwarding node.
 * This example modifies the original code to be synthesizable, using
 * SystemVerilog constructs.  Also, the model has been made to be
 * configurable, so that it can be easily scaled from a 4x4 quad switch
 * to a 16x16 switch, or any other desired configuration.  The example,
 * including a nominal test bench, is partitioned into 8 files,
 * numbered 10.xx.xx_example_10-1.sv through 10-8.sv (where xx
 * represents section and subsection numbers in the book "SystemVerilog
 * for Design" (first edition).  The file 10.00.00_example_top.sv
 * includes all of the other files.  Simulation only needs to be
 * invoked on this one file.  Conditional compilation switches (`ifdef)
 * is used to compile the examples for simulation or for synthesis.
 *
 * [1] The Verification Guild is an independent e-mail newsletter and
 * moderated discussion forum on hardware verification.  Information on
 * the original Verification Guild example can be found at
 * www.janick.bergeron.com/guild/project.html.
 *
 * Used with permission in the book, "SystemVerilog for Design"
 *  By Stuart Sutherland, Simon Davidmann, and Peter Flake.
 *  Book copyright: 2003, Kluwer Academic Publishers, Norwell, MA, USA
 *  www.wkap.il, ISBN: 0-4020-7530-8
 *
 * Revision History:
 *   1.00 15 Dec 2003 -- original code, as included in book
 *   1.01 10 Jul 2004 -- cleaned up comments, added expected results
 *                       to output messages
 *   1.10 21 Jul 2004 -- corrected errata as printed in the book
 *                       "SystemVerilog for Design" (first edition) and
 *                       to bring the example into conformance with the
 *                       final Accellera SystemVerilog 3.1a standard
 *                       (for a description of changes, see the file
 *                       "errata_SV-Design-book_26-Jul-2004.txt")
 *
 * Caveat: Expected results displayed for this code example are based
 * on an interpretation of the SystemVerilog 3.1 standard by the code
 * author or authors.  At the time of writing, official SystemVerilog
 * validation suites were not available to validate the example.
 *
 * RIGHT TO USE: This code example, or any portion thereof, may be
 * used and distributed without restriction, provided that this entire
 * comment block is included with the example.
 *
 * DISCLAIMER: THIS CODE EXAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
 * TO WARRANTIES OF MERCHANTABILITY, FITNESS OR CORRECTNESS. IN NO
 * EVENT SHALL THE AUTHOR OR AUTHORS BE LIABLE FOR ANY DAMAGES,
 * INCLUDING INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF THE
 * USE OF THIS CODE.
 *********************************************************************/

// The following include file listed in the book text is in an example
// file that is included by 10.00.00_example_top.sv
//`include "methods.sv"

//`include "definitions.sv"  // include external definitions


class base_test extends uvm_test;

  utopia_env env;
  utopia_UNI_sequence UNI_seq;
  utopia_NNI_sequence NNI_seq; 
 
  utopia_UNI_sequence UNI_seq1;
  utopia_UNI_sequence UNI_seq2;
  utopia_UNI_sequence UNI_seq3;
  utopia_UNI_sequence UNI_seq4;
  
  utopia_config cfg;
  
   `uvm_component_utils(base_test)
  
  
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev_end = ev_pool.get("ev_end");
  static uvm_event ev_next = ev_pool.get("ev_next");

  function new(string name = "base_test", uvm_component parent=null);
    super.new(name,parent);
    //this.CellCfg = new();
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

       
    env = utopia_env::type_id::create("env", this);
    
    UNI_seq = utopia_UNI_sequence::type_id::create("UNI_seq");
    
    UNI_seq1 = utopia_UNI_sequence::type_id::create("UNI_seq1");
    UNI_seq2 = utopia_UNI_sequence::type_id::create("UNI_seq2");
    UNI_seq3 = utopia_UNI_sequence::type_id::create("UNI_seq3");
    UNI_seq4 = utopia_UNI_sequence::type_id::create("UNI_seq4");
    
    NNI_seq = utopia_NNI_sequence::type_id::create("NNI_seq");
    
    cfg = utopia_config::type_id::create("cfg", this);
    
    uvm_config_db #(utopia_config)::set(this,"*", "utopia_config", cfg);
    
    
  endfunction : build_phase

  //extern function gen_cfg();
  
  virtual task run_phase(uvm_phase phase);
  endtask
  

endclass : base_test

class uni_seq_test extends base_test;

  `uvm_component_utils(uni_seq_test)
  
  function new(string name = "uni_seq_test", uvm_component parent=null);
    super.new(name,parent);
    //this.CellCfg = new();
  endfunction : new
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    uvm_top.print_topology();
   
    repeat(120) begin
    UNI_seq.start(env.utopia_agnt_Rx[0].utopia_sqncr);
    UNI_seq.start(env.utopia_agnt_Rx[1].utopia_sqncr);
    UNI_seq.start(env.utopia_agnt_Rx[2].utopia_sqncr);
    UNI_seq.start(env.utopia_agnt_Rx[3].utopia_sqncr);
    
    //CellCfg = top.squat.lut.read(22);
    //$display("FWD val : %0d",CellCfg.FWD);
    #50000ns;
      
    end
          
    cfg.fwd_all = 1'b1;  
    ev_next.trigger();
      
    repeat(30) begin
      
    UNI_seq.start(env.utopia_agnt_Rx[0].utopia_sqncr);
    UNI_seq.start(env.utopia_agnt_Rx[1].utopia_sqncr);
    UNI_seq.start(env.utopia_agnt_Rx[2].utopia_sqncr);
    UNI_seq.start(env.utopia_agnt_Rx[3].utopia_sqncr);
      
    #100000ns;
    end
    //UNI_seq1.start(env.utopia_agnt_Rx[0].utopia_sqncr);
    //UNI_seq2.start(env.utopia_agnt_Rx[1].utopia_sqncr);
    //#200ns;
    
    #100000ns;
    ev_end.wait_trigger();
    `uvm_info("MYINFO1", $sformatf("TEST PASSED"), UVM_LOW)
    
    //#14000ns;
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : uni_seq_test  


class uni_parallel_test extends base_test;

  `uvm_component_utils(uni_parallel_test)
  
  function new(string name = "uni_parallel_test", uvm_component parent=null);
    super.new(name,parent);
    //this.CellCfg = new();
  endfunction : new
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    uvm_top.print_topology();
    
    repeat(120) begin
    fork 
    begin
    UNI_seq1.start(env.utopia_agnt_Rx[0].utopia_sqncr);
    end
    begin
    UNI_seq2.start(env.utopia_agnt_Rx[1].utopia_sqncr);
    end
    begin
    UNI_seq3.start(env.utopia_agnt_Rx[2].utopia_sqncr);
    end
    begin
    UNI_seq4.start(env.utopia_agnt_Rx[3].utopia_sqncr);
    end
    join
      
    #50000ns;
      
    end
          
    cfg.fwd_all = 1'b1;  
    ev_next.trigger();
      
    repeat(30) begin
      
    fork  
    begin
    UNI_seq1.start(env.utopia_agnt_Rx[0].utopia_sqncr);
    end
    begin
    UNI_seq2.start(env.utopia_agnt_Rx[1].utopia_sqncr);
    end
    begin
    UNI_seq3.start(env.utopia_agnt_Rx[2].utopia_sqncr);
    end
    begin
    UNI_seq4.start(env.utopia_agnt_Rx[3].utopia_sqncr);
    end
    join
      
    #100000ns;
    end
    //UNI_seq1.start(env.utopia_agnt_Rx[0].utopia_sqncr);
    //UNI_seq2.start(env.utopia_agnt_Rx[1].utopia_sqncr);
    //#200ns;
    
    #100000ns;
    ev_end.wait_trigger();
    `uvm_info("MYINFO1", $sformatf("TEST PASSED"), UVM_LOW)  
    
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : uni_parallel_test  

/*
function void base_test::gen_cfg();
   assert(cfg.randomize());
   cfg.display();
endfunction : gen_cfg
*/


/*
program automatic test
  #(parameter int NumRx = 4, parameter int NumTx = 4)
   (Utopia.TB_Rx Rx[0:NumRx-1],
    Utopia.TB_Tx Tx[0:NumTx-1],
    cpu_ifc.Test mif,
    input logic rst, clk);

  // Miscellaneous control interfaces
  logic Initialized;

  initial begin
    $display("Simulation was run with conditional compilation settings of:");
    $display("`define TxPorts %0d", `TxPorts);
    $display("`define RxPorts %0d", `RxPorts);
    `ifdef FWDALL
      $display("`define FWDALL");
    `endif
    `ifdef SYNTHESIS
      $display("`define SYNTHESIS");
    `endif
    $display("");
  end

*/

//`include "environment.svh"

  //Environment env;
  
 // utopia_env env;

// class Driver_cbs_drop extends Driver_cbs;
//  virtual task pre_tx(input ATM_cell cell, ref bit drop);
//     // Randomly drop 1 out of every 100 transactions
//     drop = ($urandom_range(0,99) == 0);
//   endtask
// endclass

// class Config_10_cells extends Config;
//    constraint ten_cells {nCells == 10; }

//    function new(input int NumRx,NumTx);
//       super.new(NumRx,NumTx);
//    endfunction : new
// endclass : Config_10_cells

/*
  initial begin
    env = new(Rx, Tx, NumRx, NumTx, mif);

//      begin // Just simulate for 10 cells
// 	Config_10_cells c10 = new(NumRx,NumTx);
// 	env.cfg = c10;
//      end

    env.gen_cfg();
//     env.cfg.nCells = 100_000;
//     $display("nCells = 100_000");
    env.build();

//     begin             // Create error injection callback
//       Driver_cbs_drop dcd = new();
//       env.drv.cbs.push_back(dcd); // Put into driver's Q
//     end

    env.run();
    env.wrap_up();
  end
*/

//endprogram // test

