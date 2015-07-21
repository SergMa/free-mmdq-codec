#!/bin/sh 

################################################################################
# Demonstration of test programm (generate modems signals)                     #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Demonstration of test program"

DIR=../matlab/female
NAME=female

cp "../samples/cmu/sample3_8000.wav" $DIR/$NAME.wav

echo "Encode/decode female voice with MMDQ-codec 40 kbit/s:"

out/test --mmdq-encode 13 4 1  $DIR/$NAME.wav               $DIR/mmdq-40_$NAME.bin
out/test --mmdq-decode 13 4 1  $DIR/mmdq-40_$NAME.bin       $DIR/mmdq-40_$NAME.wav

echo "Encode/decode modem sound with MMDQ-codec 40 kbit/s no smooth:"

out/test --mmdq-encode 13 4 0  $DIR/$NAME.wav               $DIR/mmdq-40nosm_$NAME.bin
out/test --mmdq-decode 13 4 0  $DIR/mmdq-40nosm_$NAME.bin   $DIR/mmdq-40nosm_$NAME.wav
                                                                     
echo "Encode/decode modem sound with MMDQ-codec 40x kbit/s:"

out/test --mmdq-encode 7 3 1   $DIR/$NAME.wav               $DIR/mmdq-40x_$NAME.bin
out/test --mmdq-decode 7 3 1   $DIR/mmdq-40x_$NAME.bin      $DIR/mmdq-40x_$NAME.wav

echo "Encode/decode modem sound with MMDQ-codec 40x kbit/s no smooth:"

out/test --mmdq-encode 7 3 0   $DIR/$NAME.wav               $DIR/mmdq-40xnosm_$NAME.bin
out/test --mmdq-decode 7 3 0   $DIR/mmdq-40xnosm_$NAME.bin  $DIR/mmdq-40xnosm_$NAME.wav

echo "Encode/decode modem sound with MMDQ-codec 32 kbit/s:"

out/test --mmdq-encode 7 3 1   $DIR/$NAME.wav               $DIR/mmdq-32_$NAME.bin
out/test --mmdq-decode 7 3 1   $DIR/mmdq-32_$NAME.bin       $DIR/mmdq-32_$NAME.wav

echo "Encode/decode modem sound with MMDQ-codec 32 kbit/s no smooth:"

out/test --mmdq-encode 7 3 0   $DIR/$NAME.wav               $DIR/mmdq-32nosm_$NAME.bin
out/test --mmdq-decode 7 3 0   $DIR/mmdq-32nosm_$NAME.bin   $DIR/mmdq-32nosm_$NAME.wav

echo "Encode/decode modem sound with G726-codec 40 kbit/s:"

out/test --g726-encode 40      $DIR/$NAME.wav               $DIR/g726-40_$NAME.bin
out/test --g726-decode 40      $DIR/g726-40_$NAME.bin       $DIR/g726-40_$NAME.wav

echo "Encode/decode modem sound with G726-codec 32 kbit/s:"

out/test --g726-encode 32      $DIR/$NAME.wav               $DIR/g726-32_$NAME.bin
out/test --g726-decode 32      $DIR/g726-32_$NAME.bin       $DIR/g726-32_$NAME.wav

echo "Encode/decode modem sound with G711-codec alaw/s:"

out/test --g711-encode alaw    $DIR/$NAME.wav               $DIR/g711-alaw_$NAME.bin
out/test --g711-decode alaw    $DIR/g711-alaw_$NAME.bin     $DIR/g711-alaw_$NAME.wav

echo "Encode/decode modem sound with G711-codec ulaw/s:"

out/test --g711-encode ulaw    $DIR/$NAME.wav               $DIR/g711-ulaw_$NAME.bin
out/test --g711-decode ulaw    $DIR/g711-ulaw_$NAME.bin     $DIR/g711-ulaw_$NAME.wav

