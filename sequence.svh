/*
class random_sequence extends uvm_sequence #(sequence_item);
   `uvm_object_utils(random_sequence);
   
   sequence_item command;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new
 
   task body();
      repeat (5000) begin : random_loop
         command = sequence_item::type_id::create("command");
         start_item(command);
         assert(command.randomize());
         finish_item(command);
      end : random_loop
   endtask : body
endclass : random_sequence
*/


class utopia_UNI_sequence extends uvm_sequence#(UNI_cell);
  
   `uvm_object_utils(utopia_UNI_sequence)
  
   //int      nCells;	// Number of cells for this generator to create
   //int	    PortID;	// Which Rx port are we generating?
   
  UNI_cell req;
  
  //Constructor
  function new(string name = "utopia_UNI_sequence",input int nCells = 0,input int PortID = 0);
    super.new(name);
    //this.nCells  = nCells;
    //this.PortID  = PortID;
  endfunction
  
  task body();
    req = UNI_cell::type_id::create();
    start_item(req);
    assert(req.randomize());//`uvm_do(req)
    finish_item(req);
  endtask
  
endclass



class utopia_NNI_sequence extends uvm_sequence#(NNI_cell);
  
   //int      nCells;	// Number of cells for this generator to create
   //int	    PortID;	// Which Rx port are we generating?
  
  `uvm_object_utils(utopia_NNI_sequence)
   
  NNI_cell req;
  
  //Constructor
  function new(string name = "utopia_NNI_sequence",input int nCells = 0,
		input int PortID = 0);
    super.new(name);
    //this.nCells  = nCells;
    //this.PortID  = PortID;
  endfunction
  
  task body();
    start_item(req);
    assert(req.randomize());//`uvm_do(req)
    finish_item(req);
  endtask
  
endclass
/*

/////////////////////////////////////////////////////////////////////////////
class UNI_generator;

   UNI_cell blueprint;	// Blueprint for generator
   mailbox  gen2drv;	// Mailbox to driver for cells
   event    drv2gen;	// Event from driver when done with cell
   int      nCells;	// Number of cells for this generator to create
   int	    PortID;	// Which Rx port are we generating?
   
   function new(input mailbox gen2drv,
		input event drv2gen,
		input int nCells,
		input int PortID);
      this.gen2drv = gen2drv;
      this.drv2gen = drv2gen;
      this.nCells  = nCells;
      this.PortID  = PortID;
      blueprint = new();
   endfunction : new

   task run();
      UNI_cell c;
      repeat (nCells) begin
	 assert(blueprint.randomize());
	 $cast(c, blueprint.copy());
	 c.display($sformatf("@%0t: Gen%0d: ", $time, PortID));
	 gen2drv.put(c);
	 @drv2gen;		// Wait for driver to finish with it
      end
   endtask : run

endclass : UNI_generator

*/

/*
/////////////////////////////////////////////////////////////////////////////
class NNI_generator;

   NNI_cell blueprint;	// Blueprint for generator
   mailbox  gen2drv;	// Mailbox to driver for cells
   event    drv2gen;	// Event from driver when done with cell
   int      nCells;	// Number of cells for this generator to create
   int	    PortID;	// Which Rx port are we generating?

   function new(input mailbox gen2drv,
		input event drv2gen,
		input int nCells,
		input int PortID);
      this.gen2drv = gen2drv;
      this.drv2gen = drv2gen;
      this.nCells  = nCells;
      this.PortID  = PortID;
      blueprint = new();
   endfunction : new


   task run();
      NNI_cell c;
      repeat (nCells) begin
	 assert(blueprint.randomize());
	 $cast(c, blueprint.copy());
	 c.display($sformatf("Gen%0d: ", PortID));
	 gen2drv.put(c);
	 @drv2gen;		// Wait for driver to finish with it
      end
   endtask : run

endclass : NNI_generator
*/
//`endif // GENERATOR__SV
