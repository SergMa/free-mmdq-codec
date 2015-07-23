#!/bin/sh 

################################################################################
# Compare MMDQ with G.726, G.711 codecs for male voice                         #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Compare MMDQ with G.726, G.711 codecs for male voice"

DIR=../matlab/male
NAME=male

echo "Build test utilite"
make

echo "Copy \"../samples/cmu/sample6_8000.wav\" to \"../matlab/male.wav\""
cp "../samples/cmu/sample6_8000.wav" $DIR/$NAME.wav

echo "Encode/decode male voice with MMDQ-40-1:"
out/test --mmdq-encode 13 4 1  $DIR/$NAME.wav               $DIR/mmdq-40-1_$NAME.bin
out/test --mmdq-decode 13 4 1  $DIR/mmdq-40-1_$NAME.bin     $DIR/mmdq-40-1_$NAME.wav

echo "Encode/decode male voice with MMDQ-40-2:"
out/test --mmdq-encode 13 4 2  $DIR/$NAME.wav               $DIR/mmdq-40-2_$NAME.bin
out/test --mmdq-decode 13 4 2  $DIR/mmdq-40-2_$NAME.bin     $DIR/mmdq-40-2_$NAME.wav

echo "Encode/decode male voice with MMDQ-40-3:"
out/test --mmdq-encode 13 4 3  $DIR/$NAME.wav               $DIR/mmdq-40-3_$NAME.bin
out/test --mmdq-decode 13 4 3  $DIR/mmdq-40-3_$NAME.bin     $DIR/mmdq-40-3_$NAME.wav

echo "Encode/decode male voice with MMDQ-40-4:"
out/test --mmdq-encode 13 4 4  $DIR/$NAME.wav               $DIR/mmdq-40-4_$NAME.bin
out/test --mmdq-decode 13 4 4  $DIR/mmdq-40-4_$NAME.bin     $DIR/mmdq-40-4_$NAME.wav


echo "Encode/decode male voice with MMDQ-40x-1:"
out/test --mmdq-encode 7 3 1   $DIR/$NAME.wav               $DIR/mmdq-40x-1_$NAME.bin
out/test --mmdq-decode 7 3 1   $DIR/mmdq-40x-1_$NAME.bin    $DIR/mmdq-40x-1_$NAME.wav

echo "Encode/decode male voice with MMDQ-40x-2:"
out/test --mmdq-encode 7 3 2   $DIR/$NAME.wav               $DIR/mmdq-40x-2_$NAME.bin
out/test --mmdq-decode 7 3 2   $DIR/mmdq-40x-2_$NAME.bin    $DIR/mmdq-40x-2_$NAME.wav

echo "Encode/decode male voice with MMDQ-40x-3:"
out/test --mmdq-encode 7 3 3   $DIR/$NAME.wav               $DIR/mmdq-40x-3_$NAME.bin
out/test --mmdq-decode 7 3 3   $DIR/mmdq-40x-3_$NAME.bin    $DIR/mmdq-40x-3_$NAME.wav

echo "Encode/decode male voice with MMDQ-40x-4:"
out/test --mmdq-encode 7 3 4   $DIR/$NAME.wav               $DIR/mmdq-40x-4_$NAME.bin
out/test --mmdq-decode 7 3 4   $DIR/mmdq-40x-4_$NAME.bin    $DIR/mmdq-40x-4_$NAME.wav


echo "Encode/decode male voice with MMDQ-32-1:"
out/test --mmdq-encode 14 3 1  $DIR/$NAME.wav               $DIR/mmdq-32-1_$NAME.bin
out/test --mmdq-decode 14 3 1  $DIR/mmdq-32-1_$NAME.bin     $DIR/mmdq-32-1_$NAME.wav

echo "Encode/decode male voice with MMDQ-32-2:"
out/test --mmdq-encode 14 3 2  $DIR/$NAME.wav               $DIR/mmdq-32-2_$NAME.bin
out/test --mmdq-decode 14 3 2  $DIR/mmdq-32-2_$NAME.bin     $DIR/mmdq-32-2_$NAME.wav

echo "Encode/decode male voice with MMDQ-32-3:"
out/test --mmdq-encode 14 3 3  $DIR/$NAME.wav               $DIR/mmdq-32-3_$NAME.bin
out/test --mmdq-decode 14 3 3  $DIR/mmdq-32-3_$NAME.bin     $DIR/mmdq-32-3_$NAME.wav

echo "Encode/decode male voice with MMDQ-32-4:"
out/test --mmdq-encode 14 3 4  $DIR/$NAME.wav               $DIR/mmdq-32-4_$NAME.bin
out/test --mmdq-decode 14 3 4  $DIR/mmdq-32-4_$NAME.bin     $DIR/mmdq-32-4_$NAME.wav


echo "Encode/decode male sound with G726-codec 40 kbit/s:"

out/test --g726-encode 40      $DIR/$NAME.wav               $DIR/g726-40_$NAME.bin
out/test --g726-decode 40      $DIR/g726-40_$NAME.bin       $DIR/g726-40_$NAME.wav

echo "Encode/decode male sound with G726-codec 32 kbit/s:"

out/test --g726-encode 32      $DIR/$NAME.wav               $DIR/g726-32_$NAME.bin
out/test --g726-decode 32      $DIR/g726-32_$NAME.bin       $DIR/g726-32_$NAME.wav

echo "Encode/decode male sound with G711-codec alaw/s:"

out/test --g711-encode alaw    $DIR/$NAME.wav               $DIR/g711-alaw_$NAME.bin
out/test --g711-decode alaw    $DIR/g711-alaw_$NAME.bin     $DIR/g711-alaw_$NAME.wav

echo "Encode/decode male sound with G711-codec ulaw/s:"

out/test --g711-encode ulaw    $DIR/$NAME.wav               $DIR/g711-ulaw_$NAME.bin
out/test --g711-decode ulaw    $DIR/g711-ulaw_$NAME.bin     $DIR/g711-ulaw_$NAME.wav

