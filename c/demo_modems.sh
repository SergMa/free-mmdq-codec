#!/bin/sh 

################################################################################
# Compare MMDQ with G.726, G.711 codecs for modems signals                     #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Compare MMDQ with G.726, G.711 codecs for modems signals"

echo "Build test utilite"
make

echo "Copy modem wave-files from \"../samples/modems_matlab\" to \"../matlab/modem\""
cp ../samples/modems_matlab/* ../matlab/modem

echo "Encode/decode modem sound with MMDQ-40-1:"
out/test --mmdq-encode 13 4 1 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-40-1_ask2.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_ask2.bin   ../matlab/modem/mmdq-40-1_ask2.wav
out/test --mmdq-encode 13 4 1 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-40-1_fsk2.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_fsk2.bin   ../matlab/modem/mmdq-40-1_fsk2.wav
out/test --mmdq-encode 13 4 1 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-40-1_psk4.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_psk4.bin   ../matlab/modem/mmdq-40-1_psk4.wav
out/test --mmdq-encode 13 4 1 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-40-1_psk8.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_psk8.bin   ../matlab/modem/mmdq-40-1_psk8.wav
out/test --mmdq-encode 13 4 1 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-40-1_qask16.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_qask16.bin ../matlab/modem/mmdq-40-1_qask16.wav
out/test --mmdq-encode 13 4 1 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-40-1_qask32.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_qask32.bin ../matlab/modem/mmdq-40-1_qask32.wav
out/test --mmdq-encode 13 4 1 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-40-1_qask64.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40-1_qask64.bin ../matlab/modem/mmdq-40-1_qask64.wav

echo "Encode/decode modem sound with MMDQ-40-2:"
out/test --mmdq-encode 13 4 2 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-40-2_ask2.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_ask2.bin   ../matlab/modem/mmdq-40-2_ask2.wav
out/test --mmdq-encode 13 4 2 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-40-2_fsk2.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_fsk2.bin   ../matlab/modem/mmdq-40-2_fsk2.wav
out/test --mmdq-encode 13 4 2 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-40-2_psk4.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_psk4.bin   ../matlab/modem/mmdq-40-2_psk4.wav
out/test --mmdq-encode 13 4 2 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-40-2_psk8.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_psk8.bin   ../matlab/modem/mmdq-40-2_psk8.wav
out/test --mmdq-encode 13 4 2 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-40-2_qask16.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_qask16.bin ../matlab/modem/mmdq-40-2_qask16.wav
out/test --mmdq-encode 13 4 2 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-40-2_qask32.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_qask32.bin ../matlab/modem/mmdq-40-2_qask32.wav
out/test --mmdq-encode 13 4 2 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-40-2_qask64.bin
out/test --mmdq-decode 13 4 2 ../matlab/modem/mmdq-40-2_qask64.bin ../matlab/modem/mmdq-40-2_qask64.wav

echo "Encode/decode modem sound with MMDQ-40-3"
out/test --mmdq-encode 13 4 3 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-40-3_ask2.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_ask2.bin   ../matlab/modem/mmdq-40-3_ask2.wav
out/test --mmdq-encode 13 4 3 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-40-3_fsk2.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_fsk2.bin   ../matlab/modem/mmdq-40-3_fsk2.wav
out/test --mmdq-encode 13 4 3 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-40-3_psk4.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_psk4.bin   ../matlab/modem/mmdq-40-3_psk4.wav
out/test --mmdq-encode 13 4 3 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-40-3_psk8.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_psk8.bin   ../matlab/modem/mmdq-40-3_psk8.wav
out/test --mmdq-encode 13 4 3 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-40-3_qask16.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_qask16.bin ../matlab/modem/mmdq-40-3_qask16.wav
out/test --mmdq-encode 13 4 3 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-40-3_qask32.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_qask32.bin ../matlab/modem/mmdq-40-3_qask32.wav
out/test --mmdq-encode 13 4 3 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-40-3_qask64.bin
out/test --mmdq-decode 13 4 3 ../matlab/modem/mmdq-40-3_qask64.bin ../matlab/modem/mmdq-40-3_qask64.wav

echo "Encode/decode modem sound with MMDQ-40-4"
out/test --mmdq-encode 13 4 4 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-40-4_ask2.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_ask2.bin   ../matlab/modem/mmdq-40-4_ask2.wav
out/test --mmdq-encode 13 4 4 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-40-4_fsk2.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_fsk2.bin   ../matlab/modem/mmdq-40-4_fsk2.wav
out/test --mmdq-encode 13 4 4 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-40-4_psk4.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_psk4.bin   ../matlab/modem/mmdq-40-4_psk4.wav
out/test --mmdq-encode 13 4 4 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-40-4_psk8.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_psk8.bin   ../matlab/modem/mmdq-40-4_psk8.wav
out/test --mmdq-encode 13 4 4 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-40-4_qask16.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_qask16.bin ../matlab/modem/mmdq-40-4_qask16.wav
out/test --mmdq-encode 13 4 4 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-40-4_qask32.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_qask32.bin ../matlab/modem/mmdq-40-4_qask32.wav
out/test --mmdq-encode 13 4 4 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-40-4_qask64.bin
out/test --mmdq-decode 13 4 4 ../matlab/modem/mmdq-40-4_qask64.bin ../matlab/modem/mmdq-40-4_qask64.wav


echo "Encode/decode modem sound with MMDQ-40x-1:"
out/test --mmdq-encode 7 3 1 ../matlab/modem/ask2.wav              ../matlab/modem/mmdq-40x-1_ask2.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_ask2.bin   ../matlab/modem/mmdq-40x-1_ask2.wav
out/test --mmdq-encode 7 3 1 ../matlab/modem/fsk2.wav              ../matlab/modem/mmdq-40x-1_fsk2.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_fsk2.bin   ../matlab/modem/mmdq-40x-1_fsk2.wav
out/test --mmdq-encode 7 3 1 ../matlab/modem/psk4.wav              ../matlab/modem/mmdq-40x-1_psk4.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_psk4.bin   ../matlab/modem/mmdq-40x-1_psk4.wav
out/test --mmdq-encode 7 3 1 ../matlab/modem/psk8.wav              ../matlab/modem/mmdq-40x-1_psk8.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_psk8.bin   ../matlab/modem/mmdq-40x-1_psk8.wav
out/test --mmdq-encode 7 3 1 ../matlab/modem/qask16.wav            ../matlab/modem/mmdq-40x-1_qask16.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_qask16.bin ../matlab/modem/mmdq-40x-1_qask16.wav
out/test --mmdq-encode 7 3 1 ../matlab/modem/qask32.wav            ../matlab/modem/mmdq-40x-1_qask32.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_qask32.bin ../matlab/modem/mmdq-40x-1_qask32.wav
out/test --mmdq-encode 7 3 1 ../matlab/modem/qask64.wav            ../matlab/modem/mmdq-40x-1_qask64.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x-1_qask64.bin ../matlab/modem/mmdq-40x-1_qask64.wav

echo "Encode/decode modem sound with MMDQ-40x-2:"
out/test --mmdq-encode 7 3 2 ../matlab/modem/ask2.wav              ../matlab/modem/mmdq-40x-2_ask2.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_ask2.bin   ../matlab/modem/mmdq-40x-2_ask2.wav
out/test --mmdq-encode 7 3 2 ../matlab/modem/fsk2.wav              ../matlab/modem/mmdq-40x-2_fsk2.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_fsk2.bin   ../matlab/modem/mmdq-40x-2_fsk2.wav
out/test --mmdq-encode 7 3 2 ../matlab/modem/psk4.wav              ../matlab/modem/mmdq-40x-2_psk4.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_psk4.bin   ../matlab/modem/mmdq-40x-2_psk4.wav
out/test --mmdq-encode 7 3 2 ../matlab/modem/psk8.wav              ../matlab/modem/mmdq-40x-2_psk8.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_psk8.bin   ../matlab/modem/mmdq-40x-2_psk8.wav
out/test --mmdq-encode 7 3 2 ../matlab/modem/qask16.wav            ../matlab/modem/mmdq-40x-2_qask16.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_qask16.bin ../matlab/modem/mmdq-40x-2_qask16.wav
out/test --mmdq-encode 7 3 2 ../matlab/modem/qask32.wav            ../matlab/modem/mmdq-40x-2_qask32.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_qask32.bin ../matlab/modem/mmdq-40x-2_qask32.wav
out/test --mmdq-encode 7 3 2 ../matlab/modem/qask64.wav            ../matlab/modem/mmdq-40x-2_qask64.bin
out/test --mmdq-decode 7 3 2 ../matlab/modem/mmdq-40x-2_qask64.bin ../matlab/modem/mmdq-40x-2_qask64.wav

echo "Encode/decode modem sound with MMDQ-40x-3"
out/test --mmdq-encode 7 3 3 ../matlab/modem/ask2.wav              ../matlab/modem/mmdq-40x-3_ask2.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_ask2.bin   ../matlab/modem/mmdq-40x-3_ask2.wav
out/test --mmdq-encode 7 3 3 ../matlab/modem/fsk2.wav              ../matlab/modem/mmdq-40x-3_fsk2.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_fsk2.bin   ../matlab/modem/mmdq-40x-3_fsk2.wav
out/test --mmdq-encode 7 3 3 ../matlab/modem/psk4.wav              ../matlab/modem/mmdq-40x-3_psk4.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_psk4.bin   ../matlab/modem/mmdq-40x-3_psk4.wav
out/test --mmdq-encode 7 3 3 ../matlab/modem/psk8.wav              ../matlab/modem/mmdq-40x-3_psk8.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_psk8.bin   ../matlab/modem/mmdq-40x-3_psk8.wav
out/test --mmdq-encode 7 3 3 ../matlab/modem/qask16.wav            ../matlab/modem/mmdq-40x-3_qask16.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_qask16.bin ../matlab/modem/mmdq-40x-3_qask16.wav
out/test --mmdq-encode 7 3 3 ../matlab/modem/qask32.wav            ../matlab/modem/mmdq-40x-3_qask32.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_qask32.bin ../matlab/modem/mmdq-40x-3_qask32.wav
out/test --mmdq-encode 7 3 3 ../matlab/modem/qask64.wav            ../matlab/modem/mmdq-40x-3_qask64.bin
out/test --mmdq-decode 7 3 3 ../matlab/modem/mmdq-40x-3_qask64.bin ../matlab/modem/mmdq-40x-3_qask64.wav

echo "Encode/decode modem sound with MMDQ-40x-4"
out/test --mmdq-encode 7 3 4 ../matlab/modem/ask2.wav              ../matlab/modem/mmdq-40x-4_ask2.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_ask2.bin   ../matlab/modem/mmdq-40x-4_ask2.wav
out/test --mmdq-encode 7 3 4 ../matlab/modem/fsk2.wav              ../matlab/modem/mmdq-40x-4_fsk2.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_fsk2.bin   ../matlab/modem/mmdq-40x-4_fsk2.wav
out/test --mmdq-encode 7 3 4 ../matlab/modem/psk4.wav              ../matlab/modem/mmdq-40x-4_psk4.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_psk4.bin   ../matlab/modem/mmdq-40x-4_psk4.wav
out/test --mmdq-encode 7 3 4 ../matlab/modem/psk8.wav              ../matlab/modem/mmdq-40x-4_psk8.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_psk8.bin   ../matlab/modem/mmdq-40x-4_psk8.wav
out/test --mmdq-encode 7 3 4 ../matlab/modem/qask16.wav            ../matlab/modem/mmdq-40x-4_qask16.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_qask16.bin ../matlab/modem/mmdq-40x-4_qask16.wav
out/test --mmdq-encode 7 3 4 ../matlab/modem/qask32.wav            ../matlab/modem/mmdq-40x-4_qask32.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_qask32.bin ../matlab/modem/mmdq-40x-4_qask32.wav
out/test --mmdq-encode 7 3 4 ../matlab/modem/qask64.wav            ../matlab/modem/mmdq-40x-4_qask64.bin
out/test --mmdq-decode 7 3 4 ../matlab/modem/mmdq-40x-4_qask64.bin ../matlab/modem/mmdq-40x-4_qask64.wav


echo "Encode/decode modem sound with MMDQ-32-1:"
out/test --mmdq-encode 14 3 1 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-32-1_ask2.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_ask2.bin   ../matlab/modem/mmdq-32-1_ask2.wav
out/test --mmdq-encode 14 3 1 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-32-1_fsk2.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_fsk2.bin   ../matlab/modem/mmdq-32-1_fsk2.wav
out/test --mmdq-encode 14 3 1 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-32-1_psk4.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_psk4.bin   ../matlab/modem/mmdq-32-1_psk4.wav
out/test --mmdq-encode 14 3 1 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-32-1_psk8.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_psk8.bin   ../matlab/modem/mmdq-32-1_psk8.wav
out/test --mmdq-encode 14 3 1 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-32-1_qask16.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_qask16.bin ../matlab/modem/mmdq-32-1_qask16.wav
out/test --mmdq-encode 14 3 1 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-32-1_qask32.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_qask32.bin ../matlab/modem/mmdq-32-1_qask32.wav
out/test --mmdq-encode 14 3 1 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-32-1_qask64.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32-1_qask64.bin ../matlab/modem/mmdq-32-1_qask64.wav

echo "Encode/decode modem sound with MMDQ-32-2:"
out/test --mmdq-encode 14 3 2 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-32-2_ask2.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_ask2.bin   ../matlab/modem/mmdq-32-2_ask2.wav
out/test --mmdq-encode 14 3 2 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-32-2_fsk2.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_fsk2.bin   ../matlab/modem/mmdq-32-2_fsk2.wav
out/test --mmdq-encode 14 3 2 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-32-2_psk4.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_psk4.bin   ../matlab/modem/mmdq-32-2_psk4.wav
out/test --mmdq-encode 14 3 2 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-32-2_psk8.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_psk8.bin   ../matlab/modem/mmdq-32-2_psk8.wav
out/test --mmdq-encode 14 3 2 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-32-2_qask16.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_qask16.bin ../matlab/modem/mmdq-32-2_qask16.wav
out/test --mmdq-encode 14 3 2 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-32-2_qask32.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_qask32.bin ../matlab/modem/mmdq-32-2_qask32.wav
out/test --mmdq-encode 14 3 2 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-32-2_qask64.bin
out/test --mmdq-decode 14 3 2 ../matlab/modem/mmdq-32-2_qask64.bin ../matlab/modem/mmdq-32-2_qask64.wav

echo "Encode/decode modem sound with MMDQ-32-3"
out/test --mmdq-encode 14 3 3 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-32-3_ask2.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_ask2.bin   ../matlab/modem/mmdq-32-3_ask2.wav
out/test --mmdq-encode 14 3 3 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-32-3_fsk2.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_fsk2.bin   ../matlab/modem/mmdq-32-3_fsk2.wav
out/test --mmdq-encode 14 3 3 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-32-3_psk4.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_psk4.bin   ../matlab/modem/mmdq-32-3_psk4.wav
out/test --mmdq-encode 14 3 3 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-32-3_psk8.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_psk8.bin   ../matlab/modem/mmdq-32-3_psk8.wav
out/test --mmdq-encode 14 3 3 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-32-3_qask16.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_qask16.bin ../matlab/modem/mmdq-32-3_qask16.wav
out/test --mmdq-encode 14 3 3 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-32-3_qask32.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_qask32.bin ../matlab/modem/mmdq-32-3_qask32.wav
out/test --mmdq-encode 14 3 3 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-32-3_qask64.bin
out/test --mmdq-decode 14 3 3 ../matlab/modem/mmdq-32-3_qask64.bin ../matlab/modem/mmdq-32-3_qask64.wav

echo "Encode/decode modem sound with MMDQ-32-4"
out/test --mmdq-encode 14 3 4 ../matlab/modem/ask2.wav             ../matlab/modem/mmdq-32-4_ask2.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_ask2.bin   ../matlab/modem/mmdq-32-4_ask2.wav
out/test --mmdq-encode 14 3 4 ../matlab/modem/fsk2.wav             ../matlab/modem/mmdq-32-4_fsk2.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_fsk2.bin   ../matlab/modem/mmdq-32-4_fsk2.wav
out/test --mmdq-encode 14 3 4 ../matlab/modem/psk4.wav             ../matlab/modem/mmdq-32-4_psk4.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_psk4.bin   ../matlab/modem/mmdq-32-4_psk4.wav
out/test --mmdq-encode 14 3 4 ../matlab/modem/psk8.wav             ../matlab/modem/mmdq-32-4_psk8.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_psk8.bin   ../matlab/modem/mmdq-32-4_psk8.wav
out/test --mmdq-encode 14 3 4 ../matlab/modem/qask16.wav           ../matlab/modem/mmdq-32-4_qask16.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_qask16.bin ../matlab/modem/mmdq-32-4_qask16.wav
out/test --mmdq-encode 14 3 4 ../matlab/modem/qask32.wav           ../matlab/modem/mmdq-32-4_qask32.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_qask32.bin ../matlab/modem/mmdq-32-4_qask32.wav
out/test --mmdq-encode 14 3 4 ../matlab/modem/qask64.wav           ../matlab/modem/mmdq-32-4_qask64.bin
out/test --mmdq-decode 14 3 4 ../matlab/modem/mmdq-32-4_qask64.bin ../matlab/modem/mmdq-32-4_qask64.wav


echo "Encode/decode modem sound with G726-codec 40 kbit/s:"
out/test --g726-encode 40  ../matlab/modem/ask2.wav           ../matlab/modem/g726-40_ask2.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_ask2.bin   ../matlab/modem/g726-40_ask2.wav
out/test --g726-encode 40  ../matlab/modem/fsk2.wav           ../matlab/modem/g726-40_fsk2.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_fsk2.bin   ../matlab/modem/g726-40_fsk2.wav
out/test --g726-encode 40  ../matlab/modem/psk4.wav           ../matlab/modem/g726-40_psk4.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_psk4.bin   ../matlab/modem/g726-40_psk4.wav
out/test --g726-encode 40  ../matlab/modem/psk8.wav           ../matlab/modem/g726-40_psk8.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_psk8.bin   ../matlab/modem/g726-40_psk8.wav
out/test --g726-encode 40  ../matlab/modem/qask16.wav         ../matlab/modem/g726-40_qask16.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_qask16.bin ../matlab/modem/g726-40_qask16.wav
out/test --g726-encode 40  ../matlab/modem/qask32.wav         ../matlab/modem/g726-40_qask32.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_qask32.bin ../matlab/modem/g726-40_qask32.wav
out/test --g726-encode 40  ../matlab/modem/qask64.wav         ../matlab/modem/g726-40_qask64.bin
out/test --g726-decode 40  ../matlab/modem/g726-40_qask64.bin ../matlab/modem/g726-40_qask64.wav

echo "Encode/decode modem sound with G726-codec 32 kbit/s:"
out/test --g726-encode 32  ../matlab/modem/ask2.wav           ../matlab/modem/g726-32_ask2.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_ask2.bin   ../matlab/modem/g726-32_ask2.wav
out/test --g726-encode 32  ../matlab/modem/fsk2.wav           ../matlab/modem/g726-32_fsk2.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_fsk2.bin   ../matlab/modem/g726-32_fsk2.wav
out/test --g726-encode 32  ../matlab/modem/psk4.wav           ../matlab/modem/g726-32_psk4.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_psk4.bin   ../matlab/modem/g726-32_psk4.wav
out/test --g726-encode 32  ../matlab/modem/psk8.wav           ../matlab/modem/g726-32_psk8.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_psk8.bin   ../matlab/modem/g726-32_psk8.wav
out/test --g726-encode 32  ../matlab/modem/qask16.wav         ../matlab/modem/g726-32_qask16.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_qask16.bin ../matlab/modem/g726-32_qask16.wav
out/test --g726-encode 32  ../matlab/modem/qask32.wav         ../matlab/modem/g726-32_qask32.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_qask32.bin ../matlab/modem/g726-32_qask32.wav
out/test --g726-encode 32  ../matlab/modem/qask64.wav         ../matlab/modem/g726-32_qask64.bin
out/test --g726-decode 32  ../matlab/modem/g726-32_qask64.bin ../matlab/modem/g726-32_qask64.wav

echo "Encode/decode modem sound with G711-codec alaw/s:"
out/test --g711-encode alaw  ../matlab/modem/ask2.wav           ../matlab/modem/g711-alaw_ask2.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_ask2.bin ../matlab/modem/g711-alaw_ask2.wav
out/test --g711-encode alaw  ../matlab/modem/fsk2.wav           ../matlab/modem/g711-alaw_fsk2.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_fsk2.bin ../matlab/modem/g711-alaw_fsk2.wav
out/test --g711-encode alaw  ../matlab/modem/psk4.wav           ../matlab/modem/g711-alaw_psk4.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_psk4.bin ../matlab/modem/g711-alaw_psk4.wav
out/test --g711-encode alaw  ../matlab/modem/psk8.wav           ../matlab/modem/g711-alaw_psk8.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_psk8.bin ../matlab/modem/g711-alaw_psk8.wav
out/test --g711-encode alaw  ../matlab/modem/qask16.wav           ../matlab/modem/g711-alaw_qask16.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_qask16.bin ../matlab/modem/g711-alaw_qask16.wav
out/test --g711-encode alaw  ../matlab/modem/qask32.wav           ../matlab/modem/g711-alaw_qask32.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_qask32.bin ../matlab/modem/g711-alaw_qask32.wav
out/test --g711-encode alaw  ../matlab/modem/qask64.wav           ../matlab/modem/g711-alaw_qask64.bin
out/test --g711-decode alaw  ../matlab/modem/g711-alaw_qask64.bin ../matlab/modem/g711-alaw_qask64.wav

echo "Encode/decode modem sound with G711-codec ulaw/s:"
out/test --g711-encode ulaw  ../matlab/modem/ask2.wav             ../matlab/modem/g711-ulaw_ask2.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_ask2.bin   ../matlab/modem/g711-ulaw_ask2.wav
out/test --g711-encode ulaw  ../matlab/modem/fsk2.wav             ../matlab/modem/g711-ulaw_fsk2.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_fsk2.bin   ../matlab/modem/g711-ulaw_fsk2.wav
out/test --g711-encode ulaw  ../matlab/modem/psk4.wav             ../matlab/modem/g711-ulaw_psk4.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_psk4.bin   ../matlab/modem/g711-ulaw_psk4.wav
out/test --g711-encode ulaw  ../matlab/modem/psk8.wav             ../matlab/modem/g711-ulaw_psk8.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_psk8.bin   ../matlab/modem/g711-ulaw_psk8.wav
out/test --g711-encode ulaw  ../matlab/modem/qask16.wav           ../matlab/modem/g711-ulaw_qask16.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_qask16.bin ../matlab/modem/g711-ulaw_qask16.wav
out/test --g711-encode ulaw  ../matlab/modem/qask32.wav           ../matlab/modem/g711-ulaw_qask32.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_qask32.bin ../matlab/modem/g711-ulaw_qask32.wav
out/test --g711-encode ulaw  ../matlab/modem/qask64.wav           ../matlab/modem/g711-ulaw_qask64.bin
out/test --g711-decode ulaw  ../matlab/modem/g711-ulaw_qask64.bin ../matlab/modem/g711-ulaw_qask64.wav

