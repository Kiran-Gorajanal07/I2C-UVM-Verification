//////////////////////////////////////////////////////////
// monitor.sv
// Samples functional coverage (tr.sample_cov()) after each observed
// transaction, then broadcasts it to the scoreboard.
//////////////////////////////////////////////////////////

class mon extends uvm_monitor;
`uvm_component_utils(mon)

uvm_analysis_port#(transaction) send;
transaction tr;
virtual i2c_i vif;
logic [15:0] din;
logic [7:0] dout;

    function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
      if(!uvm_config_db#(virtual i2c_i)::get(this,"","vif",vif))
        `uvm_error("MON","Unable to access Interface");
    endfunction


    virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);

      if(vif.rst)
        begin
        tr.op      = rstdut;
        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
        tr.sample_cov();          // coverage sample
        send.write(tr);
        end


      else begin

        if(vif.wr)
               begin
                      tr.op = writed;
                      tr.addr = vif.addr;
                      tr.wr   = 1;
                      tr.din  = vif.din;
                      @(posedge vif.done);
                      `uvm_info("MON", $sformatf("DATA WRITE addr:%0d data:%0d",tr.addr,tr.din), UVM_NONE);
                      tr.sample_cov();   // coverage sample
                      send.write(tr);
              end
        else if (!vif.wr)
              begin
                      tr.op = readd;
                      tr.addr = vif.addr;
                      tr.wr   = 0;
                      tr.din  = vif.din;
                      @(posedge vif.done);
                      tr.datard = vif.datard;
                      `uvm_info("MON", $sformatf("DATA READ addr:%0d data:%0d ",tr.addr,tr.datard), UVM_NONE);
                      tr.sample_cov();   // coverage sample
                      send.write(tr);
           end
    end
end
   endtask

endclass