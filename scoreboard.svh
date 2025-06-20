
class Expect_cells;
   NNI_cell q[$];
   int iexpect, iactual;
endclass : Expect_cells


//`uvm_analysis_imp_decl(_rcvd_pkt)
//`uvm_analysis_imp_decl(_sent_pkt)


class utopia_scoreboard extends uvm_scoreboard;

 `uvm_component_utils(utopia_scoreboard)
  
  uvm_tlm_analysis_fifo  #(NNI_cell) tlm_a_fifo_rcvd[`TxPorts];
  uvm_tlm_analysis_fifo  #(NNI_cell) tlm_a_fifo_sent[`RxPorts];
  
  //uvm_analysis_imp_rcvd_pkt #(NNI_cell, utopia_scoreboard) rcvd_item_collected_export;
  
  //uvm_analysis_imp_sent_pkt #(NNI_cell, utopia_scoreboard) sent_item_collected_export;
  
  Expect_cells expect_cells[`TxPorts];
  //NNI_cell cellq[$];
  NNI_cell cellq_rcvd[`TxPorts];
  NNI_cell cellq_sent[`RxPorts];
  int iexpect[`TxPorts], iactual[`TxPorts];
  //static int ID;
  //int PortID;
  
  int i,j,k,l,m;
  
  
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
  static uvm_event ev_end = ev_pool.get("ev_end");
  
  // new - constructor
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
    
    for(m=0;m<`TxPorts;m++)
      expect_cells[m] = new();

   
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        
    
    for(i=0;i<`TxPorts;i++)
      tlm_a_fifo_rcvd[i] = new($sformatf("tlm_a_fifo_rcvd[%0d]", i), this);
    
    for(j=0;j<`TxPorts;j++)
      tlm_a_fifo_sent[j] = new($sformatf("tlm_a_fifo_sent[%0d]", j), this);
    
    //rcvd_item_collected_export = new("rcvd_item_collected_export", this);
    //sent_item_collected_export = new("sent_item_collected_export", this);
  endfunction: build_phase
  
 
   extern function void save_expected(NNI_cell ncell);
   extern function void check_actual(input NNI_cell c, input int portn);
   //extern function void display(string prefix="");
   //extern function void write_rcvd_pkt(NNI_cell ncell); 
   //extern function void write_sent_pkt(NNI_cell ncell); 
     
   virtual task run_phase(uvm_phase phase);
     super.run_phase(phase);
     ev.wait_trigger();
     
     $display("Scoreboard Run Phase starts....");
     

     
      fork
      begin
        
      forever begin
     
      //$display("Next round %0t ....",$time);
            
      #10000ns;   
        
      for(j=0;j<`RxPorts;j++) begin
       
       automatic int q;
       q = j;
       fork
       begin
       
         tlm_a_fifo_sent[q].get(cellq_sent[q]) ;       
         save_expected(cellq_sent[q]);
         
       end
       join_none
      end
        
      end
                
      end
      begin
        
      forever begin
     
      //$display("Next round %0t ....",$time);
            
      #10000ns;     
      for(i=0;i<`TxPorts;i++) begin
       
       automatic int p;
       p = i;
       fork
       begin
       
         tlm_a_fifo_rcvd[p].get(cellq_rcvd[p]) ;       
         //cellq_rcvd[p].display();
         check_actual(cellq_rcvd[p],p);
         
       end
       join_none
      end
        
      end
      
      end
      
      begin  
      
      #10000000ns;
      
      end
      join_any  
     
     $display("Scoreboard final check phase....");  
     
     for(i=0;i<`TxPorts;i++) begin
         if(iexpect[i] == iactual[i])
           `uvm_info (get_type_name(), $sformatf("@%0t: Number of expected cells %0d matches with number of actual cells %0d for TX port %0d ",$time,iexpect[i],iactual[i],i),UVM_LOW)
         else
           `uvm_error (get_type_name(), $sformatf("@%0t: ERROR: Number of expected cells %0d doesn't match with number of actual cells %0d for TX port %0d",$time,iexpect[i],iactual[i],i))
     end   
           
       $display("Scoreboard ends....");  
       ev_end.trigger();
     
   endtask: run_phase  

 
endclass : utopia_scoreboard

//---------------------------------------------------------------------------

     function void utopia_scoreboard::save_expected(NNI_cell ncell);

 
    CellCfgType CellCfg = top.squat.lut.read(ncell.VPI);
    ncell.VPI = CellCfg;


       `uvm_info (get_type_name(), $sformatf("@%0t: Scb save for RX port: VPI=%0x, Forward=%b", $time, ncell.VPI, CellCfg.FWD),UVM_HIGH)
 
     for (int i=0; i<`TxPorts; i++)
     if (CellCfg.FWD[i]) begin
	   expect_cells[i].q.push_back(ncell); // Save cell in this forward queue
	   expect_cells[i].iexpect++;
       iexpect[i]++;
     end

       
  
endfunction : save_expected


//-----------------------------------------------------------------------------
function void utopia_scoreboard::check_actual(input NNI_cell c,
				       input int portn);
   NNI_cell match;
   int match_idx;
 
  `uvm_info (get_type_name(), $sformatf("@%0t: Scb check for port %0d: ", $time,portn),UVM_HIGH)

  
  if (expect_cells[portn].q.size() == 0) begin
     `uvm_error (get_type_name(), $sformatf("@%0t: ERROR: %m cell not found because scoreboard for TX%0d empty", $time, portn));
      //c.display("Not Found: ");
      return;
   end
   
  
  expect_cells[portn].iactual++;
  iactual[portn]++;
  
  foreach (expect_cells[portn].q[i]) begin
     if (expect_cells[portn].q[i].compare(c)) begin
       `uvm_info (get_type_name(), $sformatf("@%0t: Match found for the cell ",$time),UVM_LOW)
      expect_cells[portn].q.delete(i);      
	 return;
     end
  end   
    
      //$display("Expected: ");
      //expect_cells[portn].q[i].display();
      //$display("Actual: ");
      //c.display();
      `uvm_error (get_type_name(), $sformatf("@%0t: ERROR: %m cell does not match for TX port %0d ", $time, portn));
      //c.display("Not Found: ");
      return;

    
endfunction : check_actual

     /*
//---------------------------------------------------------------------------
// Print the contents of the scoreboard, mainly for debugging
//---------------------------------------------------------------------------
     function void utopia_scoreboard::display(string prefix,);
   $display("@%0t: %m so far %0d expected cells, %0d actual cells received", $time, iexpect, iactual);
 
     
  $display("Tx[%0d]: exp=%0d, act=%0d", PortID, expect_cells.iexpect, expect_cells.iactual);
      foreach (expect_cells.q[j])
        expect_cells.q[j].display($sformatf("%sScoreboard: Tx%0d: ", prefix, PortID));  
     
endfunction : display
*/
     /*
// scoreboard write 
function void utopia_scoreboard::write_rcvd_pkt(NNI_cell ncell);
       //save_expected(ncell);
  check_actual(ncell,portn);
  
       if(iexpect == iactual)
         `uvm_info (get_type_name(), $sformatf("@%0t: Number of expected cells matches with number of actual cells for TX port %0d ",$time,PortID),UVM_LOW)
       else
         `uvm_error (get_type_name(), $sformatf("@%0t: ERROR: Number of expected cells doesn't match with number of actual cells for TX port %0d",$time,PortID))
         
     
  
endfunction

// scoreboard write 
function void utopia_scoreboard::write_sent_pkt(NNI_cell ncell);
      
       save_expected(ncell);
      
endfunction
*/     
     
//`endif // SCOREBOARD__SV
