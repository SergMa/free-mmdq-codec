#!/bin/sh 

################################################################################
# Demonstration of test programm                                               #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Demonstration of test program"

echo "Encode sample sound with MMDQ-codec:"

out/test --mmdq-encode 14 3 1 out/input.wav out/mmdq-32kbps.bin
out/test --mmdq-encode  6 3 1 out/input.wav out/mmdq-42kbps.bin

echo "Encode sample sound with G726-codec:"

out/test --g726-encode 32 out/input.wav out/g726-32kbps.bin
out/test --g726-encode 40 out/input.wav out/g726-40kbps.bin

echo "Encode sample sound with G711-codec:"
out/test --g711-encode alaw out/input.wav out/g711-alaw.bin
out/test --g711-encode ulaw out/input.wav out/g711-ulaw.bin


echo "Decode sample sound with MMDQ-codec:"

out/test --mmdq-decode 14 3 1 out/mmdq-32kbps.bin out/mmdq-32kbps.wav
out/test --mmdq-decode  6 3 1 out/mmdq-42kbps.bin out/mmdq-42kbps.wav
 
echo "Decode sample sound with G726-codec:"

out/test --g726-decode 32 out/g726-32kbps.bin out/g726-32kbps.wav
out/test --g726-decode 40 out/g726-40kbps.bin out/g726-40kbps.wav

echo "Decode sample sound with G711-codec:"
out/test --g711-decode alaw out/g711-alaw.bin out/g711-alaw.wav 
out/test --g711-decode ulaw out/g711-ulaw.bin out/g711-ulaw.wav 


echo "Measure quality of MMDQ-codec:"

out/test --mse 0 out/input.wav out/mmdq-32kbps.wav
out/test --mse 0 out/input.wav out/mmdq-42kbps.wav

echo "Measure quality of G726-codec:"

out/test --mse 0 out/input.wav out/g726-32kbps.wav
out/test --mse 0 out/input.wav out/g726-40kbps.wav

echo "Measure quality of G711-codec:"

out/test --mse 0 out/input.wav out/g711-alaw.wav
out/test --mse 0 out/input.wav out/g711-ulaw.wav

