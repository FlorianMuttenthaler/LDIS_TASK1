#!/bin/bash

# Script to simulate TRNG-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s TRNG.vhdl TRNG_pkg.vhdl TRNG_tb.vhdl

# Compile the design
ghdl -a TRNG.vhdl TRNG_pkg.vhdl TRNG_tb.vhdl

# Create executable
ghdl -e trng_tb

# Simulate
ghdl -r trng_tb --vcd=trng_tb.vcd

# Show simulation result as wave form
gtkwave trng_tb.vcd &

# Delete unused files
rm -f *.o *.cf
