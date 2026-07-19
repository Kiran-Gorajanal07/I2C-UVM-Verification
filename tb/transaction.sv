//////////////////////////////////////////////////////////
// transaction.sv
// Sequence item for the I2C UVM environment, with embedded
// functional coverage (cov_trans covergroup).
///////////////////AUTHOR: KIRAN GORAJANAL 
//////////////////////////////////////////////////////////

typedef enum bit [1:0] {readd = 0, writed = 1, rstdut = 2} oper_mode;


class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)

  oper_mode op;
  logic wr;
  randc logic [6:0] addr;
  rand logic [7:0] din;
  logic [7:0] datard;
  logic done;

  constraint addr_c { addr <= 10; }

  // ---------------- Functional coverage ----------------
  // Only 11 legal addresses exist (0-10) because of addr_c above, so we
  // bin every address individually instead of range-bucketing. din is
  // bucketed but explicitly carves out the 0x00 / 0xFF corners since
  // those are the values most likely to expose off-by-one / truncation
  // bugs in the DUT memory.
  covergroup cov_trans;
    option.per_instance = 1;

    OP: coverpoint op {
      bins read  = {readd};
      bins write = {writed};
      bins rst   = {rstdut};
    }

    ADDR: coverpoint addr {
      bins addr_val[] = {[0:10]};   // one bin per legal address value
    }

    DIN: coverpoint din {
      bins zero = {8'h00};
      bins max  = {8'hFF};
      bins low  = {[8'h01:8'h3F]};
      bins mid  = {[8'h40:8'hBF]};
      bins high = {[8'hC0:8'hFE]};
    }

    // makes sure every address is hit by BOTH a read and a write,
    // not just randomly by one or the other
    ADDR_X_OP: cross ADDR, OP;
  endgroup

  function new(input string name = "transaction");
    super.new(name);
    cov_trans = new();
  endfunction

  // call this from the monitor once fields are filled in
  function void sample_cov();
    cov_trans.sample();
  endfunction

endclass : transaction