To estimate quality of codecs for female voice:

1.Install MATLAB/FreeMat/Octave

2.Execute matlab/main_female.m
This script will generate wave-files for a female voice in directory matlab/female

3.Compile test program (with GCC in Linux):
cd c
make

4.Encode/decode voice wave-files by executing c/demo_female.sh
This script will encode and decode back all wave-files in matlab/female

5.Look for results in matlab/female/*.txt  files.


