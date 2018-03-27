#!/bin/bash

# Script to simulate PRNG-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s PRNG.vhdl PRNG_pkg.vhdl PRNG_tb.vhdl

# Compile the design
ghdl -a PRNG.vhdl PRNG_pkg.vhdl PRNG_tb.vhdl

# Create executable
ghdl -e prng_tb

# Simulate
ghdl -r prng_tb --vcd=prng_tb.vcd

# Show simulation result as wave form
gtkwave prng_tb.vcd &

# Delete unused files
rm -f *.o *.cf
