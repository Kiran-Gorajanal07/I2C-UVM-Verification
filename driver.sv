//////////////////////////////////////////////////////////
// driver.sv
//////////////////////////////////////////////////////////

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)

  virtual i2c_i vif;
  transaction tr;


  function new(input string path = "drv", uvm_component parent = null);
    super.new(path,parent);
  endfunction

 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     tr = transaction::type_id::create("tr");

      if(!uvm_config_db#(virtual i2c_i)::get(this,"","vif",vif))
      `uvm_error("drv","Unable to access Interface");
  endfunction



  ////////////////////reset task
  task reset_dut();
    begin
    `uvm_info("DRV", "System Reset", UVM_MEDIUM);
    vif.rst       <= 1'b1;  ///active high reset
    vif.addr      <= 0;
    vif.din       <= 0;
    vif.wr        <= 0;
    @(posedge vif.clk);
    end
  endtask

  ///////////////////////write
  task write_d();
    `uvm_info("DRV", $sformatf("mode : WRITE addr : %0d  din : %0d", tr.addr, tr.din), UVM_NONE);
  vif.rst  <= 1'b0;
  vif.wr   <= 1'b1;
  vif.addr <= tr.addr;
  vif.din  <= tr.din;
  @(posedge vif.done);

  endtask

   task read_d();
  `uvm_info("DRV", $sformatf("mode : READ addr : %0d  din : %0d", tr.addr, tr.din), UVM_NONE);
  vif.rst  <= 1'b0;
  vif.wr   <= 1'b0;
  vif.addr <= tr.addr;
  vif.din  <= 0;
  @(posedge vif.done);
   endtask



  virtual task run_phase(uvm_phase phase);
    forever begin

         seq_item_port.get_next_item(tr);


                   if(tr.op ==  rstdut)
                          begin
                          reset_dut();
                          end

                  else if(tr.op == writed)
                          begin
                          write_d();
                          end

                else if(tr.op ==  readd)
                          begin
                          read_d();
                          end

       seq_item_port.item_done();

   end
  endtask


endclass