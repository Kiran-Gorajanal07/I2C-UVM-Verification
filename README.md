# I2C Protocol Verification using UVM

## Overview

This project implements a **UVM-based functional verification environment** for an I2C (Inter-Integrated Circuit) protocol design using **SystemVerilog** and the **Universal Verification Methodology (UVM)**.

The verification environment is designed using reusable UVM components and follows a coverage-driven verification methodology with constrained-random stimulus generation. Functional correctness is validated using a scoreboard, while functional coverage is used to measure verification completeness.

**Functional Coverage Achieved:** **90%+**

---

## Features

- UVM-based reusable verification environment
- Constrained-random stimulus generation
- Functional coverage collection
- Scoreboard-based data checking
- Monitor-based protocol observation
- Transaction-level communication
- Configurable testbench architecture
- Modular and reusable verification components

---

## Project Structure

```
I2C-UVM-Verification/
│
├── rtl/
│   ├── i2c_if.sv
│   └── I2C_mem.sv
│
├── tb/
│   ├── agent.sv
│   ├── driver.sv
│   ├── env.sv
│   ├── i2c_pkg.sv
│   ├── monitor.sv
│   ├── scoreboard.sv
│   ├── seq_lib.sv
│   ├── tb_top.sv
│   ├── test.sv
│   └── transaction.sv
│
├── sim/
│   └── filelist.f
│
├── docs/
│
├── README.md
└── .gitignore
```

---

## UVM Testbench Architecture

The verification environment consists of the following reusable UVM components:

- Transaction
- Sequence Library
- Driver
- Monitor
- Agent
- Environment
- Scoreboard
- Test
- Top-level Testbench

---

## Verification Components

### Driver
- Receives sequence items from the sequencer
- Drives transactions onto the DUT interface

### Monitor
- Samples DUT activity
- Converts interface signals into transactions
- Sends transactions to the scoreboard

### Scoreboard
- Compares expected and actual DUT behavior
- Reports mismatches and verification results

### Sequences
- Generates constrained-random and directed transactions
- Exercises various protocol scenarios

### Environment
- Instantiates and connects all verification components

---

## Verification Methodology

- Universal Verification Methodology (UVM)
- Constrained-random verification
- Coverage-driven verification
- Transaction-level communication (TLM)

---

## Functional Coverage

The verification environment includes functional coverage models to measure protocol verification completeness.

### Coverage Achieved

| Metric | Result |
|---------|--------|
| Functional Coverage | **90%+** |

Coverage includes verification of:

- Read transactions
- Write transactions
- Start condition
- Stop condition
- ACK/NACK behavior
- Address transfers
- Data transfers
- Multiple transaction scenarios

---

## Simulation

Simulator:

- QuestaSim

Compile:

```sh
vlog -f sim/filelist.f
```

Run:

```sh
vsim tb_top
run -all
```

---

## Technologies Used

- SystemVerilog
- Universal Verification Methodology (UVM)
- QuestaSim

---

## Future Improvements

- Assertion-Based Verification (SVA)
- Error injection sequences
- Protocol compliance checks
- Regression automation
- Additional corner-case testing
- Code coverage integration

---

## Author

**Kiran Gorajanal**

Electronics and Communication Engineering

Interested in Digital Design and Functional Verification using SystemVerilog and UVM.
