//////////////////////////////////////////////////////////
// scoreboard.sv
// BUG FIX vs. original: arr[] is now cleared on reset, so reset actually
// has an observable, checkable effect. Also adds a pass/fail summary.
//////////////////////////////////////////////////////////

class sco extends uvm_scoreboard;
`uvm_component_utils(sco)

  uvm_analysis_imp#(transaction,sco) recv;
  bit [7:0] arr[128] = '{default:0};
  bit [7:0] data_rd = 0;

  int pass_cnt = 0;
  int fail_cnt = 0;


    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction


  virtual function void write(transaction tr);
    if(tr.op == rstdut)
              begin
                // BUG FIX: original code never cleared arr on reset, so a
                // reset test could never actually fail or pass - it was
                // untested. This makes reset semantically meaningful.
                arr = '{default:0};
                `uvm_info("SCO", "SYSTEM RESET DETECTED - memory model cleared", UVM_NONE);
              end
    else if (tr.op == writed)
      begin
          arr[tr.addr] = tr.din;
          `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, wdata:%0d arr_wr:%0d",tr.addr,tr.din,  arr[tr.addr]), UVM_NONE);
      end

    else if (tr.op == readd)
                begin
                  data_rd = arr[tr.addr];
                  if (data_rd == tr.datard)
                    begin
                    pass_cnt++;
                    `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, rdata:%0d",tr.addr,tr.datard), UVM_NONE)
                    end
                  else
                    begin
                    fail_cnt++;
                    `uvm_error("SCO",$sformatf("TEST FAILED : addr:%0d, rdata:%0d data_rd_arr:%0d",tr.addr,tr.datard,data_rd))
                    end
                end


    $display("----------------------------------------------------------------");
    endfunction

  virtual function void report_phase(uvm_phase phase);
    `uvm_info("SCO", $sformatf("SCOREBOARD SUMMARY: PASS=%0d FAIL=%0d", pass_cnt, fail_cnt), UVM_NONE);
  endfunction

endclass