//---------------------------------------------------------------------------
// i2c_pkg.sv
// Top-level package that pulls in every UVM class in the correct
// dependency order. Compile this file (and its `included files) ahead
// of tb_top.sv.
//---------------------------------------------------------------------------

package i2c_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "transaction.sv"
  `include "seq_lib.sv"
  `include "driver.sv"
  `include "monitor.sv"
  `include "scoreboard.sv"
  `include "agent.sv"
  `include "env.sv"
  `include "test.sv"

endpackage : i2c_pkg