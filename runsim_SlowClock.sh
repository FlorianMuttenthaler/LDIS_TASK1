#!/bin/bash

# Script to simulate SlowClock-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s SlowClock.vhdl SlowClock_pkg.vhdl SlowClock_tb.vhdl

# Compile the design
ghdl -a SlowClock.vhdl SlowClock_pkg.vhdl SlowClock_tb.vhdl

# Create executable
ghdl -e slowclk_tb

# Simulate
ghdl -r slowclk_tb --vcd=slowclk_tb.vcd

# Show simulation result as wave form
gtkwave slowclk_tb.vcd &

# Delete unused files
rm -f *.o *.cf
