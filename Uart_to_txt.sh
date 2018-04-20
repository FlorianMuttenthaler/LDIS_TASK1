#!/bin/bash

# Script to write stream via uart to fil
#
# Usage:
#
#		Uart_to_txt.sh <file.txt>	

(stty -F /dev/ttyUSB1 raw; cat > $1) < /dev/ttyUSB1