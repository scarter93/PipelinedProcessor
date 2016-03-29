Tests
=====

Here are a collection of tests which we've done and have worked properl. Please
note, they have manually added stall instructions as they were writen before
Hazard detection was working.

A test can be selected by changing `File_Address_Read` inside 
`PipelinedProcessor.vhd` to he name of the appropriate binary dat file.

Init.dat
--------

A basic test we use to verify no breaking changes
```
R1 = R0;
R2 = R1 + 15;
R3 = R2 + 32;
```

test\_jump.dat
--------------

Shows that jump works

```
R1 = 0;
R2 = 15;
while (1) {
	R2 = R2 + 15;
	R2 = R2 + 15;
	R2 = R2 + 15;
}
```

test\_branch.dat
----------------

Show that branch works

```
R1 = 0;
R2 = 15;
R2 = R2 + 15;
R2 = R2 + 15;
R2 = R2 + 15;

if (R1 == R0) goto: add_one

R2 = R2 + 15;
R2 = R2 + 15;

add_one:
R2 = R2 + 1;
```

mem_wr.tcl
----------

Tests memory reading and writing, both words and bytes.

It prints to the console if any errors are detected and runs the code found in
mem_wr_tb.vhd.

