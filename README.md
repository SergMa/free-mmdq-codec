# free-mmdq-codec
Experimental free very low MIPS (VLM) sound waveform lossy codec
based on min-max-differencies-quantization (MMDQ) method.
This codec has been created as low CPU consumption alternative
of G.726 codec with 32 kbit/sec bitrate and 8000 Hz sample rate.
MMDQ-codec can be easily extended to other bitrates and sample rates.
Important property of implemented codec is transparancy for fax/DTMF
signals. MATLAB/Octave/FreeMat and C source codes are available.
