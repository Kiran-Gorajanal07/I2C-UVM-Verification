interface i2c_i;

  logic clk;
  logic rst;
  logic wr;
  logic [6:0] addr;
  logic [7:0] din;
  logic [7:0] datard;
  logic done;

  modport DUT (
      input  clk, rst, wr, addr, din,
      output datard, done
  );

  modport TB (
      output clk, rst, wr, addr, din,
      input  datard, done
  );

endinterface