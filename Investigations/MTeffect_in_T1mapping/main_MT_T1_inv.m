% Look into the impact of MT effects on T1 mapping
% compare IR, MP2RAGE and VFA
addpath(genpath('E:\GitHub\NeuroImagingMatlab\QuantitativeFitting'))

% add necessary paths:
setupSimPaths;
outputPath = 'E:\GitHub\Bloch_simulation_Code\Investigations\MTeffect_in_T1mapping\savedOutputs';

% Lets fix all the tissue parameters to be for the WM:
Params.B0 = 3;
Params.MTC = 0; % Magnetization Transfer Contrast
Params.TissueType = 'WM';
Params.numExcitation = 1;
Params.echoSpacing = 7.7/1000;

Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

Params.PerfectSpoiling = 1;

%% To test the MT effect, we will simulate for a range of bound pool parameters

M0b = linspace(0,0.25,26);
T1 = linspace(600, 2000, 15);

[M0b_m, T1_m] = meshgrid(M0b, T1);

% Then vectorize for easy looping:
M0b_m = M0b_m(:); T1_m = T1_m(:)./1000;

% We actually input Ra_obs in, so invert:
Raobs_m = 1./T1_m;

simNum = length(Raobs_m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We want to see how much the observed T1 changes as a function of the
% bound pool fraction used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Simulate VFA
% two images with differing flip angles:
vfa_sig = zeros( simNum, 2);


% Image 1 - PDw
Params.TR = 27/1000;
Params.flipAngle = 6;

tic % About 13 seconds for 390 options

for i = 1 : simNum
    [vfa_sig(i,1), ~, ~] = BlochSimFlashSequence_v2( Params,...
        'Raobs', Raobs_m(i), 'M0b', M0b_m(i) );
end

% Image 2 - T1w
Params.TR = 15/1000;
Params.flipAngle = 20;

for i = 1: simNum
    [vfa_sig(i,2), ~, ~] = BlochSimFlashSequence_v2( Params,...
        'Raobs', Raobs_m(i), 'M0b', M0b_m(i) );
end
toc

save( fullfile(outputPath,'VFA_sim.mat'),"vfa_sig");

vfa_T1 = Helms_VFA_T1_2008( vfa_sig(:,1), vfa_sig(:,2), 6, 20, 27, 15, 1);

save( fullfile(outputPath,'vfa_T1.mat'),"vfa_T1");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulate Inversion Recovery Signal.

TI = [30.0000; 250.0000; 500.0000; 750.0000; 1000.0000; 1500.0000]/1000;
numTI = length(TI);

% New parameters:
Params.InvPulseDur = 3/1000;
Params.Readout = 'linear';
Params.TR = 2000/1000;
Params.flipAngle = 90;
Params.numExcitation = 1;
Params.TE = 8.5/1000;
Params.InvPulseDur = 3/1000;
Params.CalcVector = 1;
Params.PerfectSpoiling = 1;
Params.DummyEcho = 0;
Params.echoSpacing = 0;

IR_sig = zeros( simNum, numTI);

tic
for i = 1: simNum
    for j = 1:numTI
        [IR_sig(i,j), ~, ~] = BlochSim_MPRAGESequence( Params,...
            'Raobs', Raobs_m(i), 'M0b', M0b_m(i), 'TI', TI(j) );
    end
end
toc

save( fullfile(outputPath,'IR_sim.mat'),"IR_sig");

tic
[IR_T1, resmap] = fit_T1_IR_data(IR_sig, TI);
toc

save( fullfile(outputPath,'IR_T1.mat'),"IR_T1");




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulate MP2RAGE

Params.TR = 5000/1000;
Params.flipAngle = [4,5];
Params.numExcitation = 175;
Params.echoSpacing = 7.7/1000;
Params.Readout = 'linear';
Params.TI = [940, 2830]./1000;
Params.InvPulseDur = 3/1000;
Params.DummyEcho = 0;
Params.PerfectSpoiling = 1;


MP2_sig = zeros( simNum, 2);

tic
for i = 1: simNum
    [MP2_sig(i,:), ~, ~] = BlochSim_MP2RAGESequence( Params,...
        'Raobs', Raobs_m(i), 'M0b', M0b_m(i), 'TI', TI(j) );
end
toc





MP2RAGE.B0          = Params.B0;                  % In Tesla
MP2RAGE.TR          = Params.TR;                  % MP2RAGE TR in seconds
MP2RAGE.TRFLASH     = Params.echoSpacing;             % TR of the GRE readout
MP2RAGE.TIs         = Params.TI;   % Inversion times - time between middle of refocusing pulse and excitatoin of the k-space center encoding
MP2RAGE.NZslices    = Params.numExcitation;            % Slices Per Slab * [PartialFourierInSlice-0.5  0.5]
MP2RAGE.FlipDegrees = Params.flipAngle;              % Flip angle of the two readouts in degrees


[ spT1map, spMP2RAGEcorrected, spAppmap2] = CR_T1B1correctpackageTFL_withM0( B1, MP2RAGEimg, MP2RAGEINV2img, MP2RAGE, brain, 0.96);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulate Inversion Recovery Signal.










