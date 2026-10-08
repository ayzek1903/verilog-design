#!/usr/bin/env bash
# Compile and simulate every design with Icarus Verilog; waveforms go to build/
set -e
mkdir -p build
for d in mux2 mux4 mux4b dff dff_rst counter pwm_deadtime; do
  iverilog -o build/$d rtl/$d.v tb/tb_$d.v
  (cd build && vvp $d)
done
echo "Done. Open a waveform with: gtkwave build/<design>.vcd"
