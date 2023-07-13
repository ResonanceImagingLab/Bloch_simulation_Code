%% Simulate sequence and generate fitequation to cover the spectrum of MTsat
% results for varying B1rms, R1obs and M0b. 
% Please consult README document first to be sure you have downloaded all
% necessary packages. 

addpath( genpath('E:\GitHub\Bloch_simulation_Code'))
addpath( genpath( 'E:\GitHub\qMRLab-master'))

DATADIR = 'E:\GitHub\Bloch_simulation_Code\b1Correction\MarmosetGRE';

OutputDir =  'E:\GitHub\Bloch_simulation_Code\b1Correction\MarmosetGRE\Outputs';



% Set up Param structure

Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);


%% Custom fit cortex parameters, should already be set in DefaultCortexTissueParams()


%% Sequence Parameters
Params.b1 = 3.26; % microTesla
Params.pulseDur = 12.8/1000; %duration of 1 MT pulse in seconds

% Note the above isn't accurate as we have implemented it. Use flipangle
% instead:
gam = 42.576; % leave off e6 because b1 is in microtesla
Params.satFlipAngle = 360*(Params.b1 * gam * Params.pulseDur); % here = 639.6
Params.b1 = []; % clear to avoid errors

Params.numSatPulse = 1;

Params.TR = 30; % total repetition time = MT pulse train and readout.
Params.numExcitation = 1; % number of readout lines/TR
Params.flipAngle = 5; % excitation flip angle water.
Params.delta = 2000;
Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params.pulseGapDur = 0.1/1000; %ms gap between MT pulses in train
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echoSpacing = 0.1/1000;
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gaussian';
Params.DummyEcho = 0;
Params.PerfectSpoiling = 1;
Params.boosted = 0;
Params.satTrainPerBoost = 1; 
Params.TR_MT = 0; 
Params.IncludeDipolar = 1;

Params = CalcVariableImagingParams(Params);


%% If interested, you can dig through code and check the pulse using qMRlab:
Params.PulseOpt.bw = 160;
% satPulse = GetPulse(alpha, Params.delta, Params.pulseDur, Params.SatPulseShape, Params.PulseOpt);
% figure; ViewPulse(satPulse, 'b1')

%% Acquistion matrix 
Params.NumLines = 224;
Params.NumPartitions = 224; 
Params.Slices = 128;
Params.Grappa = 1;
Params.ReferenceLines = 32;
Params.AccelerationFactor = 2;
Params.Segments = []; 
Params.TurboFactor = 1; %Params.numExcitation- Params.DummyEcho;
Params.ellipMask = 0;
[outputSamplingTable, ~, Params.Segments] = Step1_calculateKspaceSampling_v3 (Params);

%% loop parameters
satFlipAngle = linspace(0, 2*Params.satFlipAngle, 25);
M0b = 0:0.03:0.18; 
T1obs = horzcat(0.6:0.075:2,2.1:0.4:3); %600ms to 4500ms to cover WM to CSF. 
Raobs = 1./T1obs;



tic
%% Start sims
% Loop variables:
Params.M0b =  []; % going to loop over this
Params.Raobs = [];
Params.Ra = [];


GRE_sigs = zeros(size(satFlipAngle,2),size(M0b,2),size(Raobs,2));

tic
for i = 1:size(satFlipAngle,2) % took nearly 5 hours for matrix 25x41x33.
    for j = 1:size(M0b,2)
        Params.M0b = M0b(j);
        
        for k = 1:size(Raobs,2)
            Params.Raobs = Raobs(k);
            temp = BlochSimFlashSequence_v2(Params,'satFlipAngle',satFlipAngle(i));    
            % Since this is single line GRE, we can skip the scaling.
            % GRE_sigs(i,j,k) = CR_generate_BSF_scaling_v1( temp, Params, outputSamplingTable, gm_m, fft_gm_m) ;
            GRE_sigs(i,j,k) = temp;
        end
    end
    disp(i/size(satFlipAngle,2) *100)  % print percent done...
    toc
end


%% MTsat calculation
%reformat Aapp and R1app matrices for 3D calculation
Aapp = ones(size(GRE_sigs));
T1app = repmat(T1obs,[7,1,size(satFlipAngle,2)]);
T1app = permute(T1app,[3,1,2]);

flip_rad = Params.flipAngle*pi/180 ; % use the nominal value here 

MTsat_sim_S = calcMTsatThruLookupTablewithDummyV3( GRE_sigs,   [], T1app* 1000, [], Aapp,...
    Params.echoSpacing * 1000, Params.numExcitation, Params.TR * 1000, Params.flipAngle, Params.DummyEcho);


MTsatValue_fn = fullfile(OutputDir, strcat('MTsat_sim_Marm.mat')); 
save(MTsatValue_fn,'MTsat_sim_S')



%% Clean up then fit:
MTsat_sim_S(MTsat_sim_S < 0) = NaN;

% Single
[fit_SS_eqn, fit_SS_eqn_sprintf, fit_SSsat, numTerms] = CR_generateFitequationsV2(M0b(1:7), satFlipAngle, Raobs, MTsat_sim_S(:,1:7,:));

% put into one variable for export
fitValues.fitvals_coeff = fit_SSsat.Coefficients;
fitValues.fit_SS_eqn = fit_SS_eqn;
fitValues.fit_SS_eqn_sprintf = fit_SS_eqn_sprintf;
fitValues.Params = Params; % export params to reference later if desired
fitValues.numTerms = numTerms; % for fitting later...

fitValue_fn = fullfile(OutputDir, strcat('fitValues_Marm.mat')); 
save(fitValue_fn,'fitValues')

img_fn = fullfile(OutputDir, strcat('simFig_Marm.png')); 
CR_generateFitSimFigures(M0b(1:7), satFlipAngle, Raobs, MTsat_sim_S(:,1:7,:), fit_SS_eqn, img_fn)



disp("DONE")
toc







