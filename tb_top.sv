//////////////////////////////////////////////////////////
// tb_top.sv
// Top-level testbench module. Instantiates the interface and DUT,
// generates the clock, and kicks off run_test().
//////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;
import i2c_pkg::*;

module tb;

  i2c_i vif();

  i2c_mem dut (.clk(vif.clk), .rst(vif.rst), .wr(vif.wr), .addr(vif.addr), .din(vif.din), .datard(vif.datard), .done(vif.done));

  initial begin
    vif.clk <= 0;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  always #10 vif.clk <= ~vif.clk;

  initial begin
    uvm_config_db#(virtual i2c_i)::set(null, "*", "vif", vif);
    run_test("test");
  end

endmodule