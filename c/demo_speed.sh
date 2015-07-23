#!/bin/sh 

################################################################################
# Codecs speed test                                                            #
# demo_speed.sh                                                                #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

echo "Codecs speed test"

echo "Build test utilite"
make

echo "Speed test started.."
out/test --speed > out/speed.log
echo "Test results have been writted into \"out/speed.log\""
echo "OK"
