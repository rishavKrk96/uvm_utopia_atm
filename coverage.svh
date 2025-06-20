/**********************************************************************
 * Functional coverage code
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

class utopia_coverage extends uvm_subscriber #(NNI_cell);

  `uvm_component_utils(utopia_coverage)
  
   uvm_tlm_analysis_fifo  #(NNI_cell) tlm_a_fifo_cov[`RxPorts];
  
   //bit [1:0] src;
   //bit [`RxPorts-3:0] src;
   bit [$clog2(`RxPorts)-1:0] src;
   bit [`TxPorts-1:0] fwd; 
   CellCfgType CellCfg;
  
   int i;
 
   
  covergroup CG_fwd();
    
    option.per_instance = 1;

    SRC: coverpoint src { 
      bins src_bin[] = {[0:`RxPorts - 1]}; 
      //option.weight = 0;
      bins bad_values  = default;
    }
  
    FWD : coverpoint fwd {      
      bins fwd_bin[] = {[0:`TxPorts - 1 ]};
      //option.weight = 0;
	  bins bad_values = default;
    }
  
    CROSS : cross src,fwd;

endgroup : CG_fwd
  
   //CG_Forward CG_fwd[`RxPorts]
   //CG_Forward CG_fwd;
   NNI_cell cell_cov[`RxPorts];
  
   static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
   static uvm_event ev = ev_pool.get("ev");
   static uvm_event ev_end = ev_pool.get("ev_end");

  
      function new (string name, uvm_component parent);
        super.new(name, parent);
        CG_fwd = new();
        for(i=0;i<`RxPorts;i++) begin
          //CG_fwd[i] = new();
          tlm_a_fifo_cov[i] = new($sformatf("tlm_a_fifo_cov[%0d]", i), this);
        end
      endfunction : new

  
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase); 
      ev.wait_trigger();
      
      fork 
      begin
        
      forever begin
     
      #10000ns;
     
      for(i=0;i<`RxPorts;i++) begin
       
       automatic int p;
       p = i;
       fork
       begin
       
         tlm_a_fifo_cov[p].get(cell_cov[p]) ;       
         cell_cov[p].display();
         
         CellCfg = top.squat.lut.read(cell_cov[p].VPI); 
         
         //src = 0;
         case(p)
         0: src = 4'b00;
         1: src = 4'b01;
         2: src = 4'b10;
         3: src = 4'b11;
         4: src = 4'b100;
         5: src = 4'b101;
         6: src = 4'b110;
         7: src = 4'b111;
         8: src = 4'b1000;
         9: src = 4'b1001;
         10: src = 4'b1010;
         11: src = 4'b1011; 
         12: src = 4'b1100;
         13: src = 4'b1101;
         14: src = 4'b1110;
         15: src = 4'b1111;
         endcase
         
         //fwd[p] = CellCfg.FWD;
         fwd = CellCfg.FWD;
         //$display("FWD value =  %0x and src = %0x",fwd[p],src);
         //$display("FWD value =  %0x and src = %0x",fwd,src);
         
         //$display("YoYo ");
         //CG_fwd[p].sample(fwd[p],src);
         //CG_fwd.sample(fwd[p],src);
         CG_fwd.sample();
         //$display("CG_FWD = %f  ",CG_fwd);
  
       end
       join_none
      end
      end
      end
      begin
      ev_end.wait_trigger();   
        //for(i=0;i<`RxPorts;i++) begin
        $display("coverage of covergroup cg_fwd = %0f ",   CG_fwd.get_coverage());  
        $display("coverage of coverpoint fwd = %0f ", CG_fwd.fwd.get_inst_coverage());
        $display("coverage of coverpoint src = %0f ", CG_fwd.src.get_inst_coverage());
       // $display("coverage of coverpoint fwd = %0f ", CG_fwd.fwd.get_coverage());
        //end
      
      #10000ns;
      end 

      join_any
     
   endtask : run_phase
  
  function void write(NNI_cell t);
  endfunction: write
  
endclass : utopia_coverage


