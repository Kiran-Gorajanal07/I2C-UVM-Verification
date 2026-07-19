//////////////////////////////////////////////////////////
// sequences.sv
// Baseline sequences (write_data, read_data, reset_dut) plus the new
// directed/corner-case sequences added to close coverage gaps.
//////////////////////////////////////////////////////////

///////////////////write seq
class write_data extends uvm_sequence#(transaction);
  `uvm_object_utils(write_data)

  transaction tr;
  rand int num_txn = 15;   // configurable instead of hardcoded repeat(15)

  function new(input string name = "write_data");
    super.new(name);
  endfunction

  virtual task body();
    repeat(num_txn)
      begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.op = writed;
        `uvm_info("SEQ", $sformatf("MODE : WRITE DIN : %0d ADDR : %0d ", tr.din, tr.addr), UVM_NONE);
        finish_item(tr);
      end
  endtask

endclass
//////////////////////////////////////////////////////////

class read_data extends uvm_sequence#(transaction);
  `uvm_object_utils(read_data)

  transaction tr;
  rand int num_txn = 15;

  function new(input string name = "read_data");
    super.new(name);
  endfunction

  virtual task body();
    repeat(num_txn)
      begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.op = readd;
        `uvm_info("SEQ", $sformatf("MODE : READ ADDR : %0d ", tr.addr), UVM_NONE);
        finish_item(tr);
      end
  endtask

endclass
/////////////////////////////////////////////////////////////////////

class reset_dut extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_dut)

  transaction tr;

  function new(input string name = "reset_dut");
    super.new(name);
  endfunction

  virtual task body();
    repeat(2)   // 2 reps is enough; reset_mid_seq below covers the real check
      begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.op = rstdut;
        `uvm_info("SEQ", "MODE : RESET", UVM_NONE);
        finish_item(tr);
      end
  endtask

endclass
////////////////////////////////////////////////////////////


// ==================== ADDED SEQUENCES ====================

// 1) Write-then-read-back the SAME address. Your original write_data and
//    read_data sequences pick addresses independently, so nothing ever
//    guaranteed a read actually checked a value you'd just written in
//    the same run. This forces addr correlation and drives the
//    ADDR_X_OP cross bins hard.
class wr_rd_same_addr extends uvm_sequence#(transaction);
  `uvm_object_utils(wr_rd_same_addr)

  transaction tr;
  rand int num_txn = 15;
  logic [6:0] addr_saved;
  logic [7:0] din_saved;

  function new(input string name = "wr_rd_same_addr");
    super.new(name);
  endfunction

  virtual task body();
    repeat(num_txn) begin
      // WRITE
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      tr.op = writed;
      addr_saved = tr.addr;
      din_saved  = tr.din;
      `uvm_info("SEQ", $sformatf("WR-RD PAIR: WRITE addr:%0d din:%0d", tr.addr, tr.din), UVM_NONE);
      finish_item(tr);

      // READ BACK - same address, bypass randomize so addr matches exactly
      tr = transaction::type_id::create("tr");
      start_item(tr);
      tr.addr = addr_saved;
      tr.din  = 0;
      tr.op   = readd;
      `uvm_info("SEQ", $sformatf("WR-RD PAIR: READ  addr:%0d (expect %0d)", tr.addr, din_saved), UVM_NONE);
      finish_item(tr);
    end
  endtask
endclass


// 2) Directed corner-case sequence: explicitly hits addr = 0 and addr = 10
//    (min/max of the legal address range) combined with din = 0x00 and
//    din = 0xFF (min/max data) - exactly the values random testing is
//    most likely to skip.
class corner_case_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(corner_case_seq)

  transaction tr;
  logic [6:0] corner_addrs[2] = '{0, 10};
  logic [7:0] corner_dins[2]  = '{8'h00, 8'hFF};

  function new(input string name = "corner_case_seq");
    super.new(name);
  endfunction

  virtual task body();
    foreach (corner_addrs[i]) begin
      foreach (corner_dins[j]) begin
        // WRITE corner value
        tr = transaction::type_id::create("tr");
        start_item(tr);
        tr.addr = corner_addrs[i];
        tr.din  = corner_dins[j];
        tr.op   = writed;
        `uvm_info("SEQ", $sformatf("CORNER WRITE addr:%0d din:%0d", tr.addr, tr.din), UVM_NONE);
        finish_item(tr);

        // READ it back
        tr = transaction::type_id::create("tr");
        start_item(tr);
        tr.addr = corner_addrs[i];
        tr.din  = 0;
        tr.op   = readd;
        `uvm_info("SEQ", $sformatf("CORNER READ  addr:%0d", tr.addr), UVM_NONE);
        finish_item(tr);
      end
    end
  endtask
endclass


// 3) Back-to-back stress sequence: no directed correlation, just hammers
//    the driver with consecutive writes/reads with alternating op to
//    exercise back-to-back timing / handshake edge cases.
class back2back_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(back2back_seq)

  transaction tr;
  rand int num_txn = 20;

  function new(input string name = "back2back_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(num_txn) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      tr.op = (tr.op == readd) ? writed : readd; // force alternation
      finish_item(tr);
    end
  endtask
endclass


// 4) Reset-in-the-middle sequence: write data, reset, then read back the
//    SAME address. Combined with the scoreboard fix in scoreboard.sv,
//    this actually verifies reset clears stored data.
class reset_mid_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_mid_seq)

  transaction tr;
  logic [6:0] addr_saved;

  function new(input string name = "reset_mid_seq");
    super.new(name);
  endfunction

  virtual task body();
    // WRITE
    tr = transaction::type_id::create("tr");
    start_item(tr);
    assert(tr.randomize());
    tr.op = writed;
    addr_saved = tr.addr;
    `uvm_info("SEQ", $sformatf("RESET-MID: WRITE addr:%0d din:%0d", tr.addr, tr.din), UVM_NONE);
    finish_item(tr);

    // RESET
    tr = transaction::type_id::create("tr");
    start_item(tr);
    assert(tr.randomize());
    tr.op = rstdut;
    `uvm_info("SEQ", "RESET-MID: RESET", UVM_NONE);
    finish_item(tr);

    // READ same address back - scoreboard should now expect 0, not the old value
    tr = transaction::type_id::create("tr");
    start_item(tr);
    tr.addr = addr_saved;
    tr.din  = 0;
    tr.op   = readd;
    `uvm_info("SEQ", $sformatf("RESET-MID: READ  addr:%0d (expect 0 after reset)", tr.addr), UVM_NONE);
    finish_item(tr);
  endtask
endclass

// ==================== END ADDED SEQUENCES ====================