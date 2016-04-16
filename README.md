Pipelined Processor
===================

- ECSE 425 Group 3

How to Run
==========

Prerequisites
-------------

- `Python3`
- Open `PipelinedProcessor.vhd` in ModelSim

Run Your Code
-------------

1. Run `python assembler.py INPUT.asm OUTPUT.dat`, which assembles INPUT.asm into
   bytecode in `OUTPUT.dat`. If no inputs are specified, it defaults to `fib.asm`
   and `fib.dat`.
   NOTE: `OUTPUT.dat` should be in the same folder as the source code
2. Edit `constant File_Address_Read` in `PipelineProcessor.vhd` to `OUTPUT.dat`
3. Enter `source tests/test_pipeline.tcl` in the ModelSim terminal
4. The output waveform will open. We added all signals for all tests, but the
   Registers are always on the top row.

Other Tests
===========

Read `tests.md` for documentation on other tests we've written. Note, these were
written early in the process and don't demonstrate functional hazard detection
due to manually added stall cycles. Hazard Detection is demonstrated to be
working when running `fib.asm`

Functionality
=============

The processor is fully working, with a noticeable improvement from implementing an instruction cache.
