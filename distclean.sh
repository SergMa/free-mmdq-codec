#!/bin/sh 

################################################################################
# Distributive clean directories (remove all generated files)                  #
# distclean.sh                                                                 #
# (c) Sergei Mashkin, 2015                                                     #
################################################################################

rm -f ./matlab/out/*.txt
rm -f ./matlab/out/*.log
rm -f ./matlab/out/*.png
rm -f ./matlab/out/*.wav
rm -f ./matlab/out/*.bin

rm -Rf ./matlab/female/*.txt
rm -Rf ./matlab/female/*.log
rm -Rf ./matlab/female/*.wav
rm -Rf ./matlab/female/*.bin

rm -Rf ./matlab/male/*.txt
rm -Rf ./matlab/male/*.log
rm -Rf ./matlab/male/*.wav
rm -Rf ./matlab/male/*.bin

rm -Rf ./matlab/modem/*.txt
rm -Rf ./matlab/modem/*.log
rm -Rf ./matlab/modem/*.wav
rm -Rf ./matlab/modem/*.bin

make -C ./c clean
