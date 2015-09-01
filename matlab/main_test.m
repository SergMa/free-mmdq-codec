%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to check and demonstrate work of MMDQ-codec                      %
% main_test.m                                                                  %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

disp('started!');

RESULTS_FILENAME = 'out/results.txt';
%fid = fopen(RESULTS_FILENAME,'w');
fid = 1;
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', RESULTS_FILENAME);
end

fprintf(fid,'MMDQ-codec test started...\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of global variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global MAXX;
global FACTOR;
global SAMPLES_PER_FRAME;
global BITS_PER_SAMPLE;
global SMOOTH_N;
global SMOOTH_ERROR_VER;
global COMPAND_TABLE;
global EXPAND_TABLE;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SAMPLES = 0;         % Numbers of samples to process (if 0 - process all available samples)
%SAMPLES = 5000:10000;
%SAMPLES = 5000:5300;

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec
BITS = 16;            % Bits per sample in original input signal
MAXX = 2^(BITS-1);    % Maximum amplitude of original input signal (for BITS=16: AMP=32768)

USE_AUTOSCALE = 1;    % 0 - disable autoscale of input signals, 1 - enable

CODEC_VERSION = 1;    % 0-no encode/decode operations
                      % 1-matlab float point
                      % 2-c-adapted, code tables, div tables

SHOW_GRAPHICS = 1;    % 0 - disable plotting of graphics, 1 - enable it

SPECTROGRAM_WIDTH = 256; % Parameters of spectrograms
SPECTROGRAM_OVR   = 8;

INPUT_FILENAME    = 'out/input.wav'; % Name of file for input signal
OUTPUT_FILENAME_0 = 'out/out0.wav';  % Name of file for output signal for codec version 0
OUTPUT_FILENAME_1 = 'out/out1.wav';  % Name of file for output signal for codec version 1
OUTPUT_FILENAME_2 = 'out/out2.wav';  % Name of file for output signal for codec version 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Codec settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SAMPLES_PER_FRAME = 10; %42400 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 13; %40000 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 26; %36000 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 6; %42666 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 7; %40000 bit/s      (*)
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 8; %38000 bit/s
%BITS_PER_SAMPLE   = 3;

SAMPLES_PER_FRAME = 14; %32000 bit/s     (*)
BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 32; %27500 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 5; %40000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 6; %36000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 7; %33142 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 8; %31000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 10; %28000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 12; %26000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 15; %24000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 20; %22000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 30; %20000 bit/s
%BITS_PER_SAMPLE   = 2;

SMOOTH_N = 4;
SMOOTH_ERROR_VER = 0;

FACTOR = 2^BITS_PER_SAMPLE;
FIXP = 32768*2;

% encoded frame data format:
% 8 bits   = min/max value (we will store A-law code here)
% 8 bits   = max/min value (we will store A-law code here)
% 1 bit    = smooth1 bit
% S*B bits = S=(SAMPLES_PER_FRAME-1), B=BITS_PER_SAMPLE - differences codes

COMPRESSION = (SAMPLES_PER_FRAME * 8) / ( 8 + 8 + 1 + (SAMPLES_PER_FRAME-1)*BITS_PER_SAMPLE);
BITRATE = 64000 / COMPRESSION;

% Print codec settings
fprintf(fid,'test of mycodec started...\n');
fprintf(fid,'-----------------------\n');
fprintf(fid,'bits             : %d\n', BITS);
fprintf(fid,'maxx             : %d\n', MAXX);
fprintf(fid,'-----------------------\n');
fprintf(fid,'codec version    : %d\n', CODEC_VERSION);
fprintf(fid,'samles per frame : %d\n', SAMPLES_PER_FRAME);
fprintf(fid,'bits per sample  : %d\n', BITS_PER_SAMPLE);
fprintf(fid,'factor           : %d\n', FACTOR);
fprintf(fid,'compression      : %f\n', COMPRESSION);
fprintf(fid,'bitrate, bit/s   : %d\n', BITRATE);
fprintf(fid,'-----------------------\n');


% Compand/Expand tables for FACTOR=8

% SMOOTH_N=1 best results:
% COMPAND_TAB = [ 0.33  0.51  0.71 ;
%                 0.00  0.00  0.00 ;
%                 0.00  0.00  0.00 ;
%                 0.00  0.00  0.00 ];
% EXPAND_TAB =  [ 0.15  0.40  0.56  0.86 ;
%                 0.00  0.00  0.00  0.00 ;
%                 0.00  0.00  0.00  0.00 ;
%                 0.00  0.00  0.00  0.00 ];

%SMOOTH_N=2 best results:
% COMPAND_TAB = [ 0.31  0.53  0.73 ;
%                 0.21  0.51  0.79 ;
%                 0.00  0.00  0.00 ;
%                 0.00  0.00  0.00 ];
% EXPAND_TAB =  [ 0.15  0.39  0.57  0.83 ;
%                 0.09  0.30  0.65  0.90 ;
%                 0.00  0.00  0.00  0.00 ;
%                 0.00  0.00  0.00  0.00 ];


% SMOOTH_N=3 best results:
% COMPAND_TAB = [ 0.11  0.50  0.84 ;
%                 0.21  0.51  0.79 ;
%                 0.31  0.53  0.73 ;
%                 0.07  0.45  0.90 ];
% EXPAND_TAB =  [ 0.04  0.19  0.75  0.91 ;
%                 0.09  0.30  0.65  0.90 ;
%                 0.15  0.39  0.57  0.83 ;
%                 0.03  0.10  0.80  0.95 ];


%COMPAND_TAB = [ 0.31  0.53  0.73 ;
%                0.21  0.51  0.79 ;
%                0.11  0.50  0.84 ;
%                0.00  0.00  0.00 ];

%EXPAND_TAB =  [ 0.15  0.39  0.57  0.83 ;
%                0.09  0.30  0.65  0.90 ;
%                0.05  0.36  0.74  0.92 ;
%                0.00  0.00  0.00  0.00 ];


% COMPAND_TAB = [ 0.760879588172096      0.875668771878477       1.00000000000000 ;
%                 0.0228600607754657     0.279913825250624       0.43047613398753 ;
%                 0.240792131894572      0.483264440024092       0.833471423714025;
%                 0.22730508063815       0.249322089084526       0.828440870179719 ];
%
% EXPAND_TAB = [  0.281857709145939      0.594314891954025       0.730315094547013         0.954002207240868 ;
%                 0.362723192531359      0.391706005645765       0.466465959071239         0.83601144838768  ;
%                 0.0539289910679345     0.328090061711381       0.549129161997424         0.86052120944435  ;
%                 0.186930408564556      0.285121677080573       0.654944028565684         0.983529546965341 ];


% COMPAND_TAB = [ 0.601614925236554   0.64973462969734    0.854700552130306 ;
%                 0.259445393401767   0.618607989189453   0.679743633881324 ;
%                 0.172939381757136   0.400448663914491   0.796379945182316 ;
%                 0.186562293336232   0.832256226288896   0.957380139603836 ];
%
% EXPAND_TAB = [  0.174060817505317   0.280272915806575   0.281549150921766   0.545897606041759 ;
%                 0.159291804958765   0.505516436584851   0.530309063995688   0.784336265501396 ;
%                 0.0454563521594964  0.145191090662119   0.31067227478809    0.610398179381997 ;
%                 0.315861199636449   0.361821805306545   0.601362936832442   0.858286106138351 ];


% COMPAND_TAB = [ 0.304804564061337   0.504192820446196  0.815768899252792 ;
%                 0.208628755824188   0.48340676824544   0.813839420438917 ;
%                 0.377613582603449   0.388795078055009  0.682093969709169 ;
%                 0.0461426823957297  0.51971964697022   0.882437242796043 ];
%
% EXPAND_TAB = [  0.0667246904993566  0.0817989411070382  0.164357552845993   0.91365961560275  ;
%                 0.0939478004381111  0.160171652076631   0.316727631650444   0.494825660300968 ;
%                 0.126723597171871   0.387869145195619   0.43033077639602    0.532132488692816 ;
%                 0.115800126151197   0.345457576683296   0.762404458114853   0.967216656082202 ];


% COMPAND_TAB = [   0.281303933746248         0.484342616391621          0.90408251381697 ;
%                   0.109719454862443         0.356105403750682         0.763642229219244 ;
%                   0.207417745933468         0.349036340108655         0.476857355459708 ;
%                   0.286749275043488         0.658933581530482         0.976373534023516 ];
%
% EXPAND_TAB =  [   0.128392323477871         0.321215934347915         0.848793702336888         0.981925448493355 ;
%                   0.039379508715452         0.183361253960411         0.340294616076952         0.463764779096477 ;
%                   0.241150138225132          0.40689651526914         0.701188223619436         0.837783415241555 ;
%                   0.143081787332901         0.416024957696825         0.605099030088593          0.78033904419793 ];

% COMPAND_TAB = [ 0.204230886627919          0.56433169137145         0.630882349446669 ;
%                 0.270134009983334          0.73967554936557          0.96606938529019 ;
%                 0.158249559917809           0.4503711622863         0.776559978069253 ;
%                 0.530473662460314         0.873855915963011         0.976758396787908 ];
%
% EXPAND_TAB = [  0.0882471442050873          0.19908535823431         0.325154312721331         0.911143466392932 ;
%                 0.0601811965588051         0.169971105382315         0.410576061466429         0.917522802581884 ;
%                 0.0962263566704486         0.275106236560315         0.542086721936989           0.9451422073622 ;
%                 0.199993779191417         0.262624426877404         0.346684541227224          0.77957477642587  ];

% COMPAND_TAB = [ 0.185951429491261         0.586728692821101         0.757879215797336  ;
%                 0.0783201445418242         0.250848716613904         0.307826898259364 ;
%                 0.089305855465155         0.513313942653527         0.842509043301135  ;
%                 0.0249550180848522         0.175550511236449         0.968603615580022 ];
%
% EXPAND_TAB = [  0.0772009660416726         0.312045394922356         0.603872251785482         0.945634177958842 ;
%                 0.035126565293832          0.14238802892884         0.708950299477868          0.99992588372356  ;
%                 0.263385939972362         0.384958746441968          0.46437202910722          0.51625415894814  ;
%                 0                         0.0512924812124326          0.45331987756309         0.830363730018842 ];

% COMPAND_TAB = [  0.125628369306923         0.676818344018937         0.952810654930602 ;
%                  0.156484021590679         0.415270113443453         0.756123450235932 ;
%                  0.350041159466486         0.658415582415131         0.816919415372098 ;
%                  0.474715660737069          0.74564925575227         0.818585742539806 ];
%
% EXPAND_TAB = [   0.09918586069468         0.394084989967106         0.650290313521531         0.840625697408339 ;
%                  0.0533123851575368         0.256112507418842          0.51175616679433         0.895478311453931 ;
%                  0.170517278936432         0.417096927513683         0.645627440459426         0.826546838997482 ;
%                  0.188076233294509         0.388314217706329         0.433309695468881         0.582848076871235 ];


% COMPAND_TAB = [  0.173021442344709         0.346517306179434         0.446541966132989 ;
%                  0.156383899933566         0.381583097812934         0.69843264044131  ;
%                  0.245751946684779         0.478605100211757         0.8190808192914   ;
%                  0.429405987788427         0.666209039143538         0.754828483550561 ];
%
% EXPAND_TAB = [   0.00633365090840431       0.162444087432355         0.508097094812372         0.605061081431529 ;
%                  0.0431823584713371        0.214906710849483         0.412449437263058         0.764992214641702 ;
%                  0.11929666716071          0.319574851939871         0.564286435482543         0.879266599994234 ;
%                  0.267824492584548         0.363528468616021         0.732193146422095         0.925429832999143 ];

%COMPAND_TAB = [  0.191184755784574         0.486243245656153         0.794673798641878 ;
%                 0.197417002303613         0.423217474219451         0.654518866888976 ;
%                 0.324893872456416         0.569824221609805         0.964152002107628 ;
%                 0.536994482421878         0.631602826113085         0.934442049315058 ];

%EXPAND_TAB = [   0.0920318624021621         0.281753539761463         0.524054377326534         0.820948123654954 ;
%                 0.0972375371484031         0.267992731166413         0.454449084013503         0.964957843901945 ;
%                 0.127518890053468         0.477631145865368         0.683930738091903         0.923470397200536  ;
%                 0.529872180983466         0.634664960516274         0.700131234893207         0.994873390439763  ];

%COMPAND_TAB = [  0.485538   0.787296   0.861956 ;
%                 0.225478   0.478825   0.798537 ;
%                 0.131863   0.459980   0.473481 ;
%                 0.027093   0.116304   0.944247 ];
%EXPAND_TAB = [   0.0010566   0.1201805   0.1277728   0.7530114 ;
%                 0.0945659   0.3690838   0.6635903   0.9591390 ;
%                 0.2384846   0.7449469   0.8702568   0.8940504 ;
%                 0.1323886   0.4840645   0.5270719   0.5981822 ];

% COMPAND_TAB = [   0.199307921754928     0.495774310225107    0.784998684897682 ;
%                   0.0197641829750384    0.559522710434548    0.964263293060209 ;
%                   0.540054731543569     0.714789748571551    0.755077388509728 ;
%                   0.0362543556488602    0.611470754370024    0.748588611365344 ];
% 
% EXPAND_TAB =  [   0.0970164503665673    0.322005486853794    0.649485964350444    0.970481495264401 ;
%                   0.100565756844168     0.183057818341359    0.229318280586532    0.425727972485942 ;
%                   0.283898768302807     0.365002016661494    0.540743343713733    0.701151934064757 ;
%                   0.596530983204526     0.636215284968669    0.864282128300644    0.946283897951382 ];


%COMPAND_TAB = [  0.35138462583469    0.606408050673778    0.89661664776492 ];
%
%EXPAND_TAB  = [  0.221034838973976   0.468542907322479    0.749920730279022    1.0000000 ];


% COMPAND_TAB = [ 0.35138462583469         0.606408050673778          0.89661664776492 ;
%                 0.231357816122273         0.388270082082767         0.649564753840096 ];
% 
% EXPAND_TAB = [  0.221034838973976         0.468542907322479         0.749920730279022                         1 ;
%                 0.108790995717465         0.304083960418986         0.465577159224541         0.877154353400846 ];

% COMPAND_TAB = [  0.35138462583469         0.606408050673778          0.89661664776492  ;
%                  0.231357816122273         0.388270082082767         0.649564753840096 ;
%                  0.286617358963593         0.544090895206425         0.806864652414241 ];
% 
% EXPAND_TAB = [ 0.221034838973976         0.468542907322479         0.749920730279022                         1 ;
%                0.108790995717465         0.304083960418986         0.465577159224541         0.877154353400846 ;
%                0.143535135647119         0.433183162058597         0.636426858521661         0.972580271564057 ];

COMPAND_TAB = [  0.35138462583469         0.606408050673778          0.89661664776492  ;
                 0.231357816122273         0.388270082082767         0.649564753840096 ;
                 0.286617358963593         0.544090895206425         0.806864652414241 ;
                 0.339099951923647         0.589205875949828         0.839949895178397 ];

EXPAND_TAB = [   0.221034838973976         0.468542907322479         0.749920730279022                         1 ;
                 0.108790995717465         0.304083960418986         0.465577159224541         0.877154353400846 ;
                 0.143535135647119         0.433183162058597         0.636426858521661         0.972580271564057 ;
                 0.233448454993711         0.450960381902636         0.727205456661375                         1 ];

COMPAND_TABLE = [ -fliplr(COMPAND_TAB), zeros(SMOOTH_N,1), COMPAND_TAB ];
EXPAND_TABLE  = [ -fliplr(EXPAND_TAB), EXPAND_TAB ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files, generate signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%voice_filename  = '../samples/cmu/sample1_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample2_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = -3;  %female
%voice_filename  = '../samples/cmu/sample4_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample5_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample6_8000.wav';          VOICE_AMP_DB = -3;  %male
%voice_filename  = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/ask2.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/fsk2.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/psk4.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/psk8.wav';       VOICE_AMP_DB = -3;
voice_filename   = '../samples/modems_matlab/qask16.wav';     VOICE_AMP_DB = -3;  %modem
%voice_filename  = '../samples/modems_matlab/qask32.wav';     VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/qask64.wav';     VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/various.wav';                   VOICE_AMP_DB = -3;  %male+female+modem

%noise_filename  = '../samples/noise/noise_white.wav';        NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_pink.wav';         NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_brown.wav';        NOISE_AMP_DB = -99;
noise_filename   = '../samples/noise/noise_badbearing.wav';   NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_diesel.wav';       NOISE_AMP_DB = -99;  %
%noise_filename  = '../samples/noise/noise_lacetti.wav';      NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_lacetti2.wav';     NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_tractor.wav';      NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_yamzdiesel.wav';   NOISE_AMP_DB = -99;

[x_voice,ffs_voice,bits_voice] = wavread(voice_filename);
if ffs_voice~=FS
    error('invalid sample frequency of input voice wavefile');
end

[x_noise,ffs_noise,bits_noise] = wavread(noise_filename);
if ffs_noise~=FS
    error('invalid sample frequency of input noise wavefile');
end

% Make horizontal vectors. If wavefiles are stereo, use only the first channels
% now x_voice, x_noise have range [-1..+1]
x_voice = x_voice(:,1).';
x_voice = fix(x_voice * MAXX);
N_voice = size(x_voice,2);

% Limit lenght of signal, if needed.
if size(SAMPLES,2) > 1
    x_voice = x_voice(SAMPLES);
    N_voice = size(x_voice,2);
end

x_noise = x_noise(:,1).';
x_noise = fix(x_noise * MAXX);
N_noise = size(x_noise,2);

% Normalize power of signals, if needed
if USE_AUTOSCALE==1
    x_voice = fix( autoscale(x_voice, MAXX) );
    x_noise = fix( autoscale(x_noise, MAXX) );
end

% Add noise to voice
x = fix( mixer( x_voice, VOICE_AMP_DB, x_noise, NOISE_AMP_DB ) );
N = length(x);

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

% Save input signal into input wavefile
wavwrite( (x/MAXX).', FS, bits_voice, INPUT_FILENAME );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create decoder and encoder structures
switch CODEC_VERSION
case 0
    enc = [];
    dec = [];
case 1
    enc = [];
    dec = [];
case 2
    enc = encoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX, FIXP );
    dec = decoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX, FIXP );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main processing loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% now we have x,t

frame_pos = 1;
frame_vinp = zeros(1,SAMPLES_PER_FRAME);
frame_vout = zeros(1,SAMPLES_PER_FRAME);

ttt_vinp = zeros(1,N);
ttt_vout = zeros(1,N);
y = zeros(1,N); %output voice

smooth0_N = 0;
smooth1_N = 0;
smooth2_N = 0;
smooth3_N = 0;

i = 1;
while i<=N-SAMPLES_PER_FRAME+1

    % scale input, get enc_voice[] buffer
    enc_voice = x(i:i+SAMPLES_PER_FRAME-1);
    enc_voice = my_clip( enc_voice, MAXX );

    % encode frame
    switch CODEC_VERSION
    case 0
        enc_data = [ 0, 0, 0, enc_voice ];
    case 1
        [enc_data] = encoder(enc_voice);
    case 2
        [enc_data,enc] = encoder2(enc_voice,enc,dec,FIXP);
    end

    % count smooth-es
    if enc_data(1)<=enc_data(2)
        smooth0 = 0;
    else
        smooth0 = 1;
    end
    smooth1 = enc_data(3);

    if smooth0==0 && smooth1==0
        smooth0_N = smooth0_N + 1;
    elseif smooth0==1 && smooth1==0
        smooth1_N = smooth1_N + 1;
    elseif smooth0==0 && smooth1==1
        smooth2_N = smooth2_N + 1;
    else
        smooth3_N = smooth3_N + 1;
    end

    % decode data frame to voice
    switch CODEC_VERSION
    case 0
        dec_voice = enc_data(4:end);
    case 1
        [dec_voice] = decoder(enc_data);
    case 2
        [dec_voice,dec] = decoder2(enc_data,dec,FIXP);
    end

    %scale back, output voice
    y(i:i+SAMPLES_PER_FRAME-1) = fix( dec_voice );

    ttt_vinp(i:i+SAMPLES_PER_FRAME-1) = enc_voice;
    ttt_vout(i:i+SAMPLES_PER_FRAME-1) = dec_voice;

    i = i + SAMPLES_PER_FRAME;
end

fprintf(fid,'smooth_N:  0=%6d  1=%6d  2=%6d  3=%6d\n', smooth0_N, smooth1_N, smooth2_N, smooth3_N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make error estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate and print errors values
erry = x - y;
avg_erry = mean( abs(erry) );
max_erry = max( abs(erry) );
std_erry = std( abs(erry) );
mse_erry = mean(erry.^2);

nerry = (x - y)/MAXX;
avg_nerry = mean( abs(nerry) );
max_nerry = max( abs(nerry) );
std_nerry = std( abs(nerry) );
mse_nerry = mean(nerry.^2);

fprintf(fid,'\n');
fprintf(fid,'x,y errors:\n');
fprintf(fid,'  avg errory=%12.8f\n',avg_erry);
fprintf(fid,'  max errory=%12.8f\n',max_erry);
fprintf(fid,'  std errory=%12.8f\n',std_erry);
fprintf(fid,'  mse errory=%12.8f\n',mse_erry);

fprintf(fid,'x,y normalized errors:\n');
fprintf(fid,'  avg nerrory=%12.8f\n',avg_nerry);
fprintf(fid,'  max nerrory=%12.8f\n',max_nerry);
fprintf(fid,'  std nerrory=%12.8f\n',std_nerry);
fprintf(fid,'  mse nerrory=%12.8f\n',mse_nerry);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if SHOW_GRAPHICS==1

% Plot waveforms of signals
figure(1);
subplot(2,1,1);
    plot(t,x);
    title('original signal');
    xlabel('t,sec');
    ylabel('x');
    ylim([-MAXX, +MAXX]);
    grid on;
subplot(2,1,2);
    plot(t,y);
    title('encoded/decoded signal');
    xlabel('t,sec');
    ylabel('y');
    ylim([-MAXX, +MAXX]);
    grid on;
print('-dpng','out/test_waveforms.png');

% Build and plot spectrogramms of signals
figure(2);
subplot(3,1,1);
    sx = spectrogram( x, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('original signal spectrogramm');
subplot(3,1,2);
    sy = spectrogram( y, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('encoded/decoded signal spectrogramm');
subplot(3,1,3);
    time = (0:N)/FS;
    freq = 0:FS/2/SPECTROGRAM_WIDTH:FS/2;
    imagesc(time,freq,abs(sx - sy) );
    axis xy;
    xlabel('time,sec');
    %colorbar;
    title('difference of spectrogramms');
print('-dpng','out/test_spectrogramms.png');

% Show compand/expand functions tables
if CODEC_VERSION==2
    figure(3);

    subplot(4,2,1);
    hist(enc.table0,100);
    title('compand');
    subplot(4,2,3);
    hist(enc.table1,100);
    subplot(4,2,5);
    hist(enc.table2,100);
    subplot(4,2,7);
    hist(enc.table3,100);

    subplot(4,2,2);
    hist(dec.table0,100);
    title('expand');
    subplot(4,2,4);
    hist(dec.table1,100);
    subplot(4,2,6);
    hist(dec.table2,100);
    subplot(4,2,8);
    hist(dec.table3,100);

    print('-dpng','out/test_expandcompand.png');
end

% Compare input/output waveforms [-MAXX..MAXX] scale
figure(4);
    subplot(2,1,1);
    plot( t, x,'r.-',  t, y,'b.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal');
    legend('x','y');
    ylim([-MAXX MAXX]);

    subplot(2,1,2);
    plot( t, x - y,'r.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal error');
    legend('error(x,y)');
    ylim([-MAXX MAXX]);
    print('-dpng','out/test_restored_signal.png');

figure(5);

    %plot graphics near the first max(error)/2
    if length(t) <= 600
        tz = t;
        xz = x;
        yz = y;
    else
        iz = 0;
        errz = abs(x-y);
        maxerrz = max(errz);
        Nz = length(t);
        for i=200:Nz-200
            if errz(i) >= maxerrz/2
                iz = i;
            end
        end
        if iz>0
            iz = iz-100 : iz+100;
        else
            iz = 1:200;
        end
        tz = t(iz);
        xz = x(iz);
        yz = y(iz);
    end

    subplot(2,1,1);
    plot( tz, xz,'r.-',  tz, yz,'b.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal (zoom)');
    legend('x','y');
    ylim([-MAXX MAXX]);

    subplot(2,1,2);
    plot( tz, xz - yz,'r.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal error (zoom)');
    legend('error(x,y)');
    ylim([-MAXX MAXX]);
    print('-dpng','out/test_restored_signal_zoom.png');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed (clean) signal into output wavefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch CODEC_VERSION
case 0
    wavwrite( (y/MAXX).', FS, bits_voice, OUTPUT_FILENAME_0 );
case 1
    wavwrite( (y/MAXX).', FS, bits_voice, OUTPUT_FILENAME_1 );
case 2
    wavwrite( (y/MAXX).', FS, bits_voice, OUTPUT_FILENAME_2 );
end

fprintf(fid,'test finished! %d samples processed!\n', N);

if fid~=1
    fclose(fid);
end

disp('finished!');
