#!/bin/sh 

################################################################################
# Demonstration of test programm                                               #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Demonstration of test program"

echo "Encode sample sound with MMDQ-codec:"
echo "mmdq-32"
out/test --mmdq-encode 14 3 1 out/input.wav out/mmdq-32.bin
echo "mmdq-32nosm"
out/test --mmdq-encode 14 3 0 out/input.wav out/mmdq-32nosm.bin
echo "mmdq-40"
out/test --mmdq-encode 13 4 1 out/input.wav out/mmdq-40.bin
echo "mmdq-40nosm"
out/test --mmdq-encode 13 4 0 out/input.wav out/mmdq-40nosm.bin
echo "mmdq-40x"
out/test --mmdq-encode  7 3 1 out/input.wav out/mmdq-40x.bin
echo "mmdq-40xnosm"
out/test --mmdq-encode  7 3 0 out/input.wav out/mmdq-40xnosm.bin

echo "Encode sample sound with G726-codec:"
echo "g726-32"
out/test --g726-encode 32 out/input.wav out/g726-32.bin
echo "g726-40"
out/test --g726-encode 40 out/input.wav out/g726-40.bin

echo "Encode sample sound with G711-codec:"
echo "g711-alaw"
out/test --g711-encode alaw out/input.wav out/g711-alaw.bin
echo "g711-ulaw"
out/test --g711-encode ulaw out/input.wav out/g711-ulaw.bin


echo "Decode sample sound with MMDQ-codec:"
echo "mmdq-32"
out/test --mmdq-decode 14 3 1 out/mmdq-32.bin      out/mmdq-32.wav
echo "mmdq-32nosm"
out/test --mmdq-decode 14 3 0 out/mmdq-32nosm.bin  out/mmdq-32nosm.wav
echo "mmdq-40"
out/test --mmdq-decode 13 4 1 out/mmdq-40.bin      out/mmdq-40.wav
echo "mmdq-40nosm"
out/test --mmdq-decode 13 4 0 out/mmdq-40nosm.bin  out/mmdq-40nosm.wav
echo "mmdq-40x"
out/test --mmdq-decode  7 3 1 out/mmdq-40x.bin     out/mmdq-40x.wav
echo "mmdq-40xnosm"
out/test --mmdq-decode  7 3 0 out/mmdq-40xnosm.bin out/mmdq-40xnosm.wav
 
echo "Decode sample sound with G726-codec:"
echo "g726-32"
out/test --g726-decode 32 out/g726-32.bin out/g726-32.wav
echo "g726-40"
out/test --g726-decode 40 out/g726-40.bin out/g726-40.wav

echo "Decode sample sound with G711-codec:"
echo "g711-alaw"
out/test --g711-decode alaw out/g711-alaw.bin out/g711-alaw.wav 
echo "g711-ulaw"
out/test --g711-decode ulaw out/g711-ulaw.bin out/g711-ulaw.wav 


echo "Measure quality of MMDQ-codec:"
out/test --mse 0 out/input.wav out/mmdq-32.wav
out/test --mse 0 out/input.wav out/mmdq-32nosm.wav
out/test --mse 0 out/input.wav out/mmdq-40.wav
out/test --mse 0 out/input.wav out/mmdq-40nosm.wav
out/test --mse 0 out/input.wav out/mmdq-40x.wav
out/test --mse 0 out/input.wav out/mmdq-40xnosm.wav

echo "Measure quality of G726-codec:"
out/test --mse 0 out/input.wav out/g726-32.wav
out/test --mse 0 out/input.wav out/g726-40.wav

echo "Measure quality of G711-codec:"
out/test --mse 0 out/input.wav out/g711-alaw.wav
out/test --mse 0 out/input.wav out/g711-ulaw.wav

