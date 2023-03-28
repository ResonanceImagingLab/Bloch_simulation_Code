baseDir = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\';
ref_kspace_dir = strcat(baseDir,'kspaceWeighting/Atlas_reference/');
load( strcat( ref_kspace_dir,'GM_seg_MNI_152_image.mat')) % keep these here so you know what files you are setting directory to
load( strcat( ref_kspace_dir,'GM_seg_MNI_152_kspace.mat'))

%% GM first
clear Params
Params.B0 = 3; % in Tesla
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params.b1 = 4; % microTesla
Params.numSatPulse = 1;
Params.pulseDur = 4/1000; %duration of 1 MT pulse in seconds
Params.TR = 27/1000; % total repetition time = MT pulse train and readout.
Params.numExcitation = 1; % number of readout lines/TR
Params.flipAngle = 5; % excitation flip angle water.
Params.delta = 2000;
Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echoSpacing = 7.66/1000;
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.
Params.PerfectSpoiling = 1;



Params.NumLines = 216;
Params.NumPartitions = 192; 
Params.Slices = 176; 
Params.Grappa = 1;
Params.ReferenceLines = 32;
Params.AccelerationFactor = 2;
Params.Segments = []; 
Params.TurboFactor = []; %Params.numExcitation- Params.DummyEcho;
Params.ellipMask = 1;

Params = CalcVariableImagingParams(Params);
%% No MT

[noMT1, ~, ~] = BlochSimFlashSequence_v2(Params,'b1',0,'MTC',0); % reference signal simulation

%% With MT

[MT1, ~, ~] = BlochSimFlashSequence_v2(Params,'freqPattern','single'); % reference signal simulation

%% T1w
Params.TR = 15/1000; % total repetition time = MT pulse train and readout
Params.flipAngle = 21; % excitation flip angle water..
[T1w1, ~, ~] = BlochSimFlashSequence_v2(Params,'b1',0,'MTC',0); % reference signal simulation
T1w1 = T1w1*1.25;

MTR1 = (noMT1 - MT1)./ noMT1;
T1_1 = 1./Params.Raobs*1000;
M0 = 1;
MTsat1 = calcMTsatThruLookupTablewithDummyV3(MT1, 1, T1_1, 1, M0, 0, 1, 27, 5,0);

[ T11c, M01c, MTsat1c] = fitHelms2008_MTsat(T1w1, MT1, noMT1,...
        5, 15, 27, 15);

%%%%%%%%%%%%%%%%%%%
%% WM
clear Params

Params.B0 = 3; % in Tesla
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'WM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params.b1 = 4; % microTesla
Params.numSatPulse = 1;
Params.pulseDur = 4/1000; %duration of 1 MT pulse in seconds
Params.TR = 27/1000; % total repetition time = MT pulse train and readout.
Params.numExcitation = 1; % number of readout lines/TR
Params.flipAngle = 5; % excitation flip angle water.
Params.delta = 2000;
Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echoSpacing = 7.66/1000;
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.
Params.PerfectSpoiling = 1;



Params.NumLines = 216;
Params.NumPartitions = 192; 
Params.Slices = 176; 
Params.Grappa = 1;
Params.ReferenceLines = 32;
Params.AccelerationFactor = 2;
Params.Segments = []; 
Params.TurboFactor = []; %Params.numExcitation- Params.DummyEcho;
Params.ellipMask = 1;

Params = CalcVariableImagingParams(Params);
%% No MT

[noMT, ~, ~] = BlochSimFlashSequence_v2(Params,'b1',0,'MTC',0); % reference signal simulation

%% With MT

[MT, ~, ~] = BlochSimFlashSequence_v2(Params,'freqPattern','single'); % reference signal simulation

%% T1w
Params.TR = 15/1000; % total repetition time = MT pulse train and readout
Params.flipAngle = 21; % excitation flip angle water..
[T1w, ~, ~] = BlochSimFlashSequence_v2(Params,'b1',0,'MTC',0); % reference signal simulation
T1w = T1w*1.2;

% Calc
MTR = (noMT - MT)./ noMT;
T1 = 1./Params.Raobs *1000;
M0 = 1;
MTsat = calcMTsatThruLookupTablewithDummyV3(MT, 1, T1, 1, M0, 0, 1, 27, 5,0);



[ T1c, M0c, MTsatc] = fitHelms2008_MTsat(T1w, MT, noMT,...
        5, 15, 27, 15)





%%

% Questions:
% 1:
% Using the equations from Helms 2008 (and Helms 2010 erratum to 2008), calculate the MTsat, T1 and Aapp, aswell as MTR values for the GM and WM given the following inputs:
% GM:
% S_MT = 464; S_noMT = 726; S_T1w = 615
% WM:
% S_MT = 462; S_noMT = 776; S_T1w = 744
% 
% Sequence parameters:
% T1w image: TR = 15ms, flip angle = 21 degrees
% Other images: TR = 27ms, flip angle = 5 degrees.
% 
% Assuming a relative noise value of 5% in each of the maps. Which, map provides better contrast to noise ratio between grey matter and white matter, and why?
% 
% 2:
% 
% Which two sequence parameters are often modulated in qMT imaging as they modulate the sensitivity of the image to MT effects? If you look at the set of differential equations for a two-pool model, which tissue parameters/characteristics are particularly sensitive to this.
% 
% Answers:
% GM
% MTR = 36.13%, MTsat =1.29% T1 = 1423 ms   Aapp = 1.00
% 
% WM
% MTR = 40.38%, MTsat = 2.44% T1 = 837ms   Aapp = 0.994
% 
% 
% MTsat provides better GM contrast to noise ratio. (1)
% The calculation of MTsat removes the contribution of T1 (1) from the maps, which acts in an opposing direction to the MT effect (1).
% 
% 
% (q2) The offset frequency, and the applied field strength (either B1 or omega 1). For the second part, we are looking for them to describe the lineshape of the tissue/sample, along with its T2 value.
% 
% 
% 
% 

















