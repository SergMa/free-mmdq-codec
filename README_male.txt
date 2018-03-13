To estimate quality of codecs for male voice:

1.Install MATLAB/FreeMat/Octave

2.Execute matlab/main_male.m
This script will generate wave-files for a male voice in directory matlab/male

3.Compile test program (with GCC in Linux):
cd c
make

4.Encode/decode voice wave-files by executing c/demo_male.sh
This script will encode and decode back all wave-files in matlab/male

5.Look for results in matlab/male/*.txt  files.


