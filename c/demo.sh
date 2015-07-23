#!/bin/sh 

################################################################################
# Demonstration of test programm                                               #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Demonstration of test program"

echo "Build test utilite"
make

echo "Copy \"../samples/cmu/sample3_8000.wav\" to \"out/input.wav\""
cp "../samples/cmu/sample3_8000.wav" out/input.wav

echo "Encode sample sound with MMDQ-codec:"
echo "mmdq-32-1"
out/test --mmdq-encode 14 3 1 out/input.wav out/mmdq-32-1.bin
echo "mmdq-32-2"
out/test --mmdq-encode 14 3 2 out/input.wav out/mmdq-32-2.bin
echo "mmdq-32-3"
out/test --mmdq-encode 14 3 3 out/input.wav out/mmdq-32-3.bin
echo "mmdq-32-4"
out/test --mmdq-encode 14 3 4 out/input.wav out/mmdq-32-4.bin
echo "mmdq-40-1"
out/test --mmdq-encode 13 4 1 out/input.wav out/mmdq-40-1.bin
echo "mmdq-40-2"
out/test --mmdq-encode 13 4 2 out/input.wav out/mmdq-40-2.bin
echo "mmdq-40-3"
out/test --mmdq-encode 13 4 3 out/input.wav out/mmdq-40-3.bin
echo "mmdq-40-4"
out/test --mmdq-encode 13 4 4 out/input.wav out/mmdq-40-4.bin
echo "mmdq-40x-1"
out/test --mmdq-encode  7 3 1 out/input.wav out/mmdq-40x-1.bin
echo "mmdq-40x-2"
out/test --mmdq-encode  7 3 2 out/input.wav out/mmdq-40x-2.bin
echo "mmdq-40x-3"
out/test --mmdq-encode  7 3 3 out/input.wav out/mmdq-40x-3.bin
echo "mmdq-40x-4"
out/test --mmdq-encode  7 3 4 out/input.wav out/mmdq-40x-4.bin

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
echo "mmdq-32-1"
out/test --mmdq-decode 14 3 1 out/mmdq-32-1.bin      out/mmdq-32-1.wav
echo "mmdq-32-2"
out/test --mmdq-decode 14 3 2 out/mmdq-32-2.bin      out/mmdq-32-2.wav
echo "mmdq-32-3"
out/test --mmdq-decode 14 3 3 out/mmdq-32-3.bin      out/mmdq-32-3.wav
echo "mmdq-32-4"
out/test --mmdq-decode 14 3 4 out/mmdq-32-4.bin      out/mmdq-32-4.wav
echo "mmdq-40-1"
out/test --mmdq-decode 13 4 1 out/mmdq-40-1.bin      out/mmdq-40-1.wav
echo "mmdq-40-2"
out/test --mmdq-decode 13 4 2 out/mmdq-40-2.bin      out/mmdq-40-2.wav
echo "mmdq-40-3"
out/test --mmdq-decode 13 4 3 out/mmdq-40-3.bin      out/mmdq-40-3.wav
echo "mmdq-40-4"
out/test --mmdq-decode 13 4 4 out/mmdq-40-4.bin      out/mmdq-40-4.wav
echo "mmdq-40x-1"
out/test --mmdq-decode  7 3 4 out/mmdq-40x-1.bin     out/mmdq-40x-1.wav
echo "mmdq-40x-2"
out/test --mmdq-decode  7 3 4 out/mmdq-40x-2.bin     out/mmdq-40x-2.wav
echo "mmdq-40x-3"
out/test --mmdq-decode  7 3 4 out/mmdq-40x-3.bin     out/mmdq-40x-3.wav
echo "mmdq-40x-4"
out/test --mmdq-decode  7 3 4 out/mmdq-40x-4.bin     out/mmdq-40x-4.wav

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
out/test --mse 0 out/input.wav out/mmdq-32-1.wav
out/test --mse 0 out/input.wav out/mmdq-32-2.wav
out/test --mse 0 out/input.wav out/mmdq-32-3.wav
out/test --mse 0 out/input.wav out/mmdq-32-4.wav
out/test --mse 0 out/input.wav out/mmdq-40-1.wav
out/test --mse 0 out/input.wav out/mmdq-40-2.wav
out/test --mse 0 out/input.wav out/mmdq-40-3.wav
out/test --mse 0 out/input.wav out/mmdq-40-4.wav
out/test --mse 0 out/input.wav out/mmdq-40x-1.wav
out/test --mse 0 out/input.wav out/mmdq-40x-2.wav
out/test --mse 0 out/input.wav out/mmdq-40x-3.wav
out/test --mse 0 out/input.wav out/mmdq-40x-4.wav

echo "Measure quality of G726-codec:"
out/test --mse 0 out/input.wav out/g726-32.wav
out/test --mse 0 out/input.wav out/g726-40.wav

echo "Measure quality of G711-codec:"
out/test --mse 0 out/input.wav out/g711-alaw.wav
out/test --mse 0 out/input.wav out/g711-ulaw.wav

