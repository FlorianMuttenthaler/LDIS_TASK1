#!/bin/bash

# Script to simulate TRNG-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s TRNG_pkg.vhd
ghdl -s TRNG.vhd
ghdl -s TRNG_tb.vhd

# Compile the design
ghdl -a TRNG_pkg.vhd
ghdl -a TRNG.vhd
ghdl -a TRNG_tb.vhd

# Create executable
ghdl -e TRNG_tb

# Simulate
ghdl -r TRNG_tb --vcd=trng_tb.vcd

# Show simulation result as wave form
gtkwave trng_tb.vcd &

# Delete unused files
rm -f *.o *.cf
