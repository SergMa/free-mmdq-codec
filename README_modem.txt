To estimate transparancy of codecs for different modem signals:

1.Install MATLAB with Communications Toolbox (You may use Octave with similar
toolbox too, but you must write new code, because of difference in names
of modulation functions).

2.Execute matlab/main_modem_generate.m
This script will generate wave-files for some modem modulation types
(ASK,FSK,PSK,QAM) in directory matlab/modem

3.Compile test program (with GCC in Linux):
cd c
make

4.Encode/decode modem wave-files by executing c/demo_modem.sh
This script will encode and decode back all wave-files in matlab/modem.

5.Look for results in matlab/modem/*.txt  files.


