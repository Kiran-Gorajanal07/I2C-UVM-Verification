//////////////////////////////////////////////////////////
// test.sv
// Runs the baseline sequences plus the four added coverage-closing
// sequences, then prints overall functional coverage.
//////////////////////////////////////////////////////////

class test extends uvm_test;
`uvm_component_utils(test)

function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction

env e;
write_data wdata;
read_data rdata;
reset_dut rstdut;

// handles for the added sequences
wr_rd_same_addr   wr_rd_seq;
corner_case_seq   corner_seq;
back2back_seq     b2b_seq;
reset_mid_seq     rst_mid_seq;


virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e           = env::type_id::create("env",this);
   wdata       = write_data::type_id::create("wdata");
   rdata       = read_data::type_id::create("rdata");
   rstdut      = reset_dut::type_id::create("rstdut");
   wr_rd_seq   = wr_rd_same_addr::type_id::create("wr_rd_seq");
   corner_seq  = corner_case_seq::type_id::create("corner_seq");
   b2b_seq     = back2back_seq::type_id::create("b2b_seq");
   rst_mid_seq = reset_mid_seq::type_id::create("rst_mid_seq");
endfunction

virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);

// initial reset
rstdut.start(e.a.seqr);

// baseline independent random write/read (original plan)
wdata.start(e.a.seqr);
rdata.start(e.a.seqr);

// added test cases - these close the coverage gaps:
wr_rd_seq.start(e.a.seqr);     // correlated write->read same addr
corner_seq.start(e.a.seqr);    // addr/din min-max corners
b2b_seq.start(e.a.seqr);       // back-to-back alternating stress
rst_mid_seq.start(e.a.seqr);   // reset-in-the-middle data-clear check

phase.drop_objection(this);
endtask

// $get_coverage() aggregates coverage across all covergroup instances
// sampled during the run (every transaction object created calls
// sample_cov() in the monitor).
virtual function void report_phase(uvm_phase phase);
  `uvm_info("TEST", $sformatf("=== OVERALL FUNCTIONAL COVERAGE = %0.2f%% ===", $get_coverage()), UVM_NONE);
endfunction

endclass