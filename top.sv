/**********************************************************************
 * Utopia top-level--includes all files for simulating the complete
 * utopia design (not in book)
 *
 * This top-level file includes all of the example files in chapter 10.
 *
 * To simulate this example, invoke simulation on this file, with:
 *   `define SYNTHESIS commented out
 *   `define FWDALL uncommented (or enabled using +define+FWDALL)
 *
 * To synthesize this example, invoke simulation on this file, with:
 *   `define SYNTHESIS uncommented (or enabled using +define+SYNTHESIS)
 *   `define FWDALL commented out
 *
 * Author: Stuart Sutherland
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
`timescale 1ns/1ns

//`define SYNTHESIS	// conditional compilation flag for synthesis
//`define FWDALL		// conditional compilation flag to forward cells

`define TxPorts 4  // set number of transmit ports
`define RxPorts 4  // set number of receive ports


module top;

  //import uvm_pkg::*;
  
  
  parameter int NumRx = `RxPorts;
  parameter int NumTx = `TxPorts;

  logic rst, clk;

  
  // System Clock and Reset
  initial begin
    rst = 0; clk = 0;
    #5ns rst = 1;
    #5ns clk = 1;
    #5ns rst = 0; clk = 0;
    forever 
      #5ns clk = ~clk;
  end

  Utopia Rx[0:NumRx-1] ();	// NumRx x Level 1 Utopia Rx Interface
  Utopia Tx[0:NumTx-1] ();	// NumTx x Level 1 Utopia Tx Interface
  
  //int i,j;
  genvar i,j;
  
  //generate 
  
    for(i=0;i<NumRx;i++) begin : for_loop_rx
      
    //Utopia Rx();
    
    initial begin
      
      uvm_config_db #(virtual Utopia.TB_Rx)::set(null, $sformatf("uvm_test_top.env.utopia_agnt_Rx[%0d].utopia_drv", i), "rx_vif", Rx[i]);
      uvm_config_db #(virtual Utopia.TB_Rx)::set(null, $sformatf("uvm_test_top.env.utopia_agnt_Rx[%0d].utopia_mon", i), "rx_vif", Rx[i]);
      
      //$display("yo");
      //uvm_config_db #(1)::dump();

    end  
      
    end  
    
  //endgenerate
  
  
  //generate
  
    for(j=0;j<NumTx;j++) begin : for_loop_tx
      
    //Utopia Tx();
    
    initial begin
      
      uvm_config_db #(virtual Utopia.TB_Tx)::set(null, $sformatf("uvm_test_top.env.utopia_agnt_Tx[%0d].utopia_mon", j), "tx_vif", Tx[j]);
      
    end
      
    end  
    
  //endgenerate
  

  
  
  cpu_ifc mif();	  // Intel-style Utopia parallel management interface
  squat #(NumRx, NumTx) squat(Rx, Tx, mif, rst, clk);	// DUT
  //test  #(NumRx, NumTx) t1(Rx, Tx, mif, rst, clk);	// Test
  
  //Debug signals
  /*
  bit tx_cbt_soc;
  bit tx_cbt_en;
  bit tx_cbt_valid;
  bit tx_cbt_clav;
  
  bit rx_cbr_soc;
  bit rx_cbr_en;
  bit rx_cbr_valid;
  bit rx_cbr_clav;
   
  bit [7:0] rx_data;
  bit [7:0] tx_data;
  bit [7:0] tx_vpi;
  bit rx_clk_in_3;
  bit rx_clk_in_2;
  bit rx_clk_in_1;
  bit rx_clk_in_0;

  assign tx_cbt_soc = Tx[3].cbt.soc;
  assign tx_cbt_en = Tx[3].cbt.en;
  assign tx_cbt_valid = Tx[3].cbt.valid;
  assign tx_cbt_clav = Tx[3].cbt.clav;
  
  
  assign rx_cbr_soc = Rx[3].cbr.soc;
  assign rx_cbr_en = Rx[3].cbr.en;
  assign rx_cbr_valid = Rx[3].cbr.valid;
  assign rx_cbr_clav = Rx[3].cbr.clav;
  
  assign rx_data = Rx[3].cbr.data;
  assign tx_data = Tx[3].cbt.data;
  //assign rx_clk_in = Rx[3].clk_out;
  assign tx_vpi = top.squat.ATMcell.nni.VPI[11:4];
  
  assign rx_clk_in_3 = Rx[3].clk_in;
  assign rx_clk_in_2 = Rx[2].clk_in;
  assign rx_clk_in_1 = Rx[1].clk_in;
  assign rx_clk_in_0 = Rx[0].clk_in;
  
  bit [0:3] forward;
  assign forward = top.squat.forward;
  */
  
  initial begin 
  
    uvm_config_db #(virtual cpu_ifc)::set(null,"uvm_test_top.env.cpu_agnt.cpu_drv", "mif", mif);
    
  end
  
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(3,top);
    $set_coverage_db_name("utopia_cov");
    
    //run_test("uni_seq_test");    // choose your test here
   
    run_test("uni_parallel_test"); 
    //run_test("uni_error_injection_test"); 
   
    uvm_top.print_topology();
    
  end

 
endmodule : top
