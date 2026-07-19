// Compile order for simulators (e.g. `vcs -f filelist.f` or `vlog -f filelist.f`)
// NOTE: i2c_i.sv (your interface) and i2c_mem.sv (your DUT) are NOT
// included here since they weren't part of the files you shared -
// add their paths above i2c_pkg.sv, since i2c_pkg.sv's classes and
// tb_top.sv both reference the virtual i2c_i type.

// i2c_i.sv          <-- add your interface file here
// i2c_mem.sv        <-- add your DUT file here
i2c_pkg.sv
tb_top.sv