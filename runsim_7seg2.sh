#!/bin/bash

# Script to simulate 7seg-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s 7seg.vhdl 7seg_pkg.vhdl 7seg_tb2.vhdl

# Compile the design
ghdl -a 7seg.vhdl 7seg_pkg.vhdl 7seg_tb2.vhdl

# Create executable
ghdl -e sevenseg_tb

# Simulate
ghdl -r sevenseg_tb --vcd=sevenseg_tb.vcd

# Show simulation result as wave form
gtkwave sevenseg_tb.vcd &

# Delete unused files
rm -f *.o *.cf
