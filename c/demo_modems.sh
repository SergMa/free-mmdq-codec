#!/bin/sh 

################################################################################
# Demonstration of test programm (generate modems signals)                     #
# demo.sh                                                                      #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Demonstration of test program"

echo "Encode/decode modem sound with MMDQ-codec 40 kbit/s:"

out/test --mmdq-encode 13 4 1 ../matlab/modem/ask2.wav           ../matlab/modem/mmdq-40_ask2.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_ask2.bin   ../matlab/modem/mmdq-40_ask2.wav
                                                                 
out/test --mmdq-encode 13 4 1 ../matlab/modem/fsk2.wav           ../matlab/modem/mmdq-40_fsk2.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_fsk2.bin   ../matlab/modem/mmdq-40_fsk2.wav
                                                                 
out/test --mmdq-encode 13 4 1 ../matlab/modem/psk4.wav           ../matlab/modem/mmdq-40_psk4.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_psk4.bin   ../matlab/modem/mmdq-40_psk4.wav
                                                                 
out/test --mmdq-encode 13 4 1 ../matlab/modem/psk8.wav           ../matlab/modem/mmdq-40_psk8.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_psk8.bin   ../matlab/modem/mmdq-40_psk8.wav

out/test --mmdq-encode 13 4 1 ../matlab/modem/qask16.wav         ../matlab/modem/mmdq-40_qask16.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_qask16.bin ../matlab/modem/mmdq-40_qask16.wav

out/test --mmdq-encode 13 4 1 ../matlab/modem/qask32.wav         ../matlab/modem/mmdq-40_qask32.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_qask32.bin ../matlab/modem/mmdq-40_qask32.wav

out/test --mmdq-encode 13 4 1 ../matlab/modem/qask64.wav         ../matlab/modem/mmdq-40_qask64.bin
out/test --mmdq-decode 13 4 1 ../matlab/modem/mmdq-40_qask64.bin ../matlab/modem/mmdq-40_qask64.wav

echo "Encode/decode modem sound with MMDQ-codec 40 kbit/s no smooth:"

out/test --mmdq-encode 13 4 0 ../matlab/modem/ask2.wav               ../matlab/modem/mmdq-40nosm_ask2.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_ask2.bin   ../matlab/modem/mmdq-40nosm_ask2.wav
                                                                     
out/test --mmdq-encode 13 4 0 ../matlab/modem/fsk2.wav               ../matlab/modem/mmdq-40nosm_fsk2.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_fsk2.bin   ../matlab/modem/mmdq-40nosm_fsk2.wav
                                                                     
out/test --mmdq-encode 13 4 0 ../matlab/modem/psk4.wav               ../matlab/modem/mmdq-40nosm_psk4.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_psk4.bin   ../matlab/modem/mmdq-40nosm_psk4.wav
                                                                     
out/test --mmdq-encode 13 4 0 ../matlab/modem/psk8.wav               ../matlab/modem/mmdq-40nosm_psk8.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_psk8.bin   ../matlab/modem/mmdq-40nosm_psk8.wav

out/test --mmdq-encode 13 4 0 ../matlab/modem/qask16.wav             ../matlab/modem/mmdq-40nosm_qask16.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_qask16.bin ../matlab/modem/mmdq-40nosm_qask16.wav

out/test --mmdq-encode 13 4 0 ../matlab/modem/qask32.wav             ../matlab/modem/mmdq-40nosm_qask32.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_qask32.bin ../matlab/modem/mmdq-40nosm_qask32.wav

out/test --mmdq-encode 13 4 0 ../matlab/modem/qask64.wav             ../matlab/modem/mmdq-40nosm_qask64.bin
out/test --mmdq-decode 13 4 0 ../matlab/modem/mmdq-40nosm_qask64.bin ../matlab/modem/mmdq-40nosm_qask64.wav

echo "Encode/decode modem sound with MMDQ-codec 40x kbit/s:"

out/test --mmdq-encode 7 3 1 ../matlab/modem/ask2.wav            ../matlab/modem/mmdq-40x_ask2.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_ask2.bin   ../matlab/modem/mmdq-40x_ask2.wav
                                                                 
out/test --mmdq-encode 7 3 1 ../matlab/modem/fsk2.wav            ../matlab/modem/mmdq-40x_fsk2.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_fsk2.bin   ../matlab/modem/mmdq-40x_fsk2.wav
                                                                 
out/test --mmdq-encode 7 3 1 ../matlab/modem/psk4.wav            ../matlab/modem/mmdq-40x_psk4.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_psk4.bin   ../matlab/modem/mmdq-40x_psk4.wav
                                                                 
out/test --mmdq-encode 7 3 1 ../matlab/modem/psk8.wav            ../matlab/modem/mmdq-40x_psk8.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_psk8.bin   ../matlab/modem/mmdq-40x_psk8.wav

out/test --mmdq-encode 7 3 1 ../matlab/modem/qask16.wav          ../matlab/modem/mmdq-40x_qask16.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_qask16.bin ../matlab/modem/mmdq-40x_qask16.wav

out/test --mmdq-encode 7 3 1 ../matlab/modem/qask32.wav          ../matlab/modem/mmdq-40x_qask32.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_qask32.bin ../matlab/modem/mmdq-40x_qask32.wav

out/test --mmdq-encode 7 3 1 ../matlab/modem/qask64.wav          ../matlab/modem/mmdq-40x_qask64.bin
out/test --mmdq-decode 7 3 1 ../matlab/modem/mmdq-40x_qask64.bin ../matlab/modem/mmdq-40x_qask64.wav

echo "Encode/decode modem sound with MMDQ-codec 40x kbit/s no smooth:"

out/test --mmdq-encode 7 3 0 ../matlab/modem/ask2.wav                ../matlab/modem/mmdq-40xnosm_ask2.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_ask2.bin   ../matlab/modem/mmdq-40xnosm_ask2.wav
                                                                     
out/test --mmdq-encode 7 3 0 ../matlab/modem/fsk2.wav                ../matlab/modem/mmdq-40xnosm_fsk2.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_fsk2.bin   ../matlab/modem/mmdq-40xnosm_fsk2.wav
                                                                     
out/test --mmdq-encode 7 3 0 ../matlab/modem/psk4.wav                ../matlab/modem/mmdq-40xnosm_psk4.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_psk4.bin   ../matlab/modem/mmdq-40xnosm_psk4.wav
                                                                     
out/test --mmdq-encode 7 3 0 ../matlab/modem/psk8.wav                ../matlab/modem/mmdq-40xnosm_psk8.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_psk8.bin   ../matlab/modem/mmdq-40xnosm_psk8.wav

out/test --mmdq-encode 7 3 0 ../matlab/modem/qask16.wav              ../matlab/modem/mmdq-40xnosm_qask16.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_qask16.bin ../matlab/modem/mmdq-40xnosm_qask16.wav

out/test --mmdq-encode 7 3 0 ../matlab/modem/qask32.wav              ../matlab/modem/mmdq-40xnosm_qask32.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_qask32.bin ../matlab/modem/mmdq-40xnosm_qask32.wav

out/test --mmdq-encode 7 3 0 ../matlab/modem/qask64.wav              ../matlab/modem/mmdq-40xnosm_qask64.bin
out/test --mmdq-decode 7 3 0 ../matlab/modem/mmdq-40xnosm_qask64.bin ../matlab/modem/mmdq-40xnosm_qask64.wav

echo "Encode/decode modem sound with MMDQ-codec 32 kbit/s:"

out/test --mmdq-encode 14 3 1 ../matlab/modem/ask2.wav           ../matlab/modem/mmdq-32_ask2.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_ask2.bin   ../matlab/modem/mmdq-32_ask2.wav
                                                                 
out/test --mmdq-encode 14 3 1 ../matlab/modem/fsk2.wav           ../matlab/modem/mmdq-32_fsk2.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_fsk2.bin   ../matlab/modem/mmdq-32_fsk2.wav
                                                                 
out/test --mmdq-encode 14 3 1 ../matlab/modem/psk4.wav           ../matlab/modem/mmdq-32_psk4.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_psk4.bin   ../matlab/modem/mmdq-32_psk4.wav
                                                                 
out/test --mmdq-encode 14 3 1 ../matlab/modem/psk8.wav           ../matlab/modem/mmdq-32_psk8.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_psk8.bin   ../matlab/modem/mmdq-32_psk8.wav
                                                                 
out/test --mmdq-encode 14 3 1 ../matlab/modem/qask16.wav         ../matlab/modem/mmdq-32_qask16.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_qask16.bin ../matlab/modem/mmdq-32_qask16.wav

out/test --mmdq-encode 14 3 1 ../matlab/modem/qask32.wav         ../matlab/modem/mmdq-32_qask32.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_qask32.bin ../matlab/modem/mmdq-32_qask32.wav

out/test --mmdq-encode 14 3 1 ../matlab/modem/qask64.wav         ../matlab/modem/mmdq-32_qask64.bin
out/test --mmdq-decode 14 3 1 ../matlab/modem/mmdq-32_qask64.bin ../matlab/modem/mmdq-32_qask64.wav

echo "Encode/decode modem sound with MMDQ-codec 32 kbit/s no smooth:"

out/test --mmdq-encode 14 3 0 ../matlab/modem/ask2.wav               ../matlab/modem/mmdq-32nosm_ask2.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_ask2.bin   ../matlab/modem/mmdq-32nosm_ask2.wav
                                                                     
out/test --mmdq-encode 14 3 0 ../matlab/modem/fsk2.wav               ../matlab/modem/mmdq-32nosm_fsk2.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_fsk2.bin   ../matlab/modem/mmdq-32nosm_fsk2.wav
                                                                     
out/test --mmdq-encode 14 3 0 ../matlab/modem/psk4.wav               ../matlab/modem/mmdq-32nosm_psk4.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_psk4.bin   ../matlab/modem/mmdq-32nosm_psk4.wav
                                                                     
out/test --mmdq-encode 14 3 0 ../matlab/modem/psk8.wav               ../matlab/modem/mmdq-32nosm_psk8.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_psk8.bin   ../matlab/modem/mmdq-32nosm_psk8.wav

out/test --mmdq-encode 14 3 0 ../matlab/modem/qask16.wav             ../matlab/modem/mmdq-32nosm_qask16.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_qask16.bin ../matlab/modem/mmdq-32nosm_qask16.wav

out/test --mmdq-encode 14 3 0 ../matlab/modem/qask32.wav             ../matlab/modem/mmdq-32nosm_qask32.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_qask32.bin ../matlab/modem/mmdq-32nosm_qask32.wav

out/test --mmdq-encode 14 3 0 ../matlab/modem/qask64.wav             ../matlab/modem/mmdq-32nosm_qask64.bin
out/test --mmdq-decode 14 3 0 ../matlab/modem/mmdq-32nosm_qask64.bin ../matlab/modem/mmdq-32nosm_qask64.wav

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
