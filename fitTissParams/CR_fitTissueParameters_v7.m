%% Changes:
% 
% % To Simulation page, define additional parameter for sat pulse. 
% Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.


% V7 - needed to run with higher M0b option than 0.06. To save time, run
% above, and load the results from v6.





%% Estimate tissue parameters for B1 correction simulations
% Version 1 i think I got stuck at the wrong local minimum... try again.
% This one builds off of the results of v2, with a more local search.
% With a focus towards the variables that seem to have the greatest impact:
% T2b, R and T1D.
%
% Version 6 modifies the looping structure for better parallelizations
% Version 5 is a complete overhaul of simulation code. 
% Version 4.1 - needs longer T1D and possibly lower M0b?
% Version 4 uses a new dataset.
% Version 3 uses rescaling of values based on kspace weighting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Note! cubic interpolation looks INSUFFICIENT for large B1 deviations.
% Moving to a 7th order polynomial with B1. The other dimensions seem more
% linear, so It should be OK to just change this one...
% Will need to make changes all the way down the pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Looks like you might need to come up with your own tissue parameters.
% Instead of guessing them, we can fit them!

% Ideally get two or more B1 data points for MTsat (dual and single)
% T1 maps and B1 maps

% Simulate the sequence for a range of tissue parameters.
% For set of tissue parameters, simulate for full range of satFlipAngle
% Fit these simulated data points with a cubic polynomial of B1.

% With a list of polynomials for each parameter set, calculate the residual
% value from the acquired data (within a small T1 range to assume it as 1
% value...). Do separately for each single and dual 

% To further weight away from high residuals, we will combine the square of
% the residuals from the dual and single. The best tissue parameter set
% will have the lowest combined residuals for dual and single!  

% Linux
% addpath(genpath( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/simCode' ))
% addpath(genpath('/media/chris/SSD/Research/Code/NeuroImagingMatlab/NeuroImagingMatlab')) % for limitHandler, and CR_calc_std_residuals
% addpath(genpath( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/PSF' ))
%  
% SavDir =  '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/data/20220204_ihMT_3prot_test_boost/fitTissParams/';
% load( strcat( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/data/20220204_ihMT_3prot_test_boost/fitTissParams/','MTsat_vals2fit.mat'))   
% load( strcat( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/data/20220204_ihMT_3prot_test_boost/fitTissParams/','MTsat_vals2fit_Mar16.mat'))
% load( strcat( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/data/20220204_ihMT_3prot_test_boost/fitTissParams/','avg_kspace_sc.mat'))
% load( strcat( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/kspaceWeighting\','GM_seg_MNI_152_image.mat'))
% load( strcat( '/media/chris/SSD/Research/SeqDevelopment/CorticalihMT/cortical_ihMT_sim/kspaceWeighting\','GM_seg_MNI_152_kspace.mat'))

%cd 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\Batch_sim'


% Windows
%addpath(genpath( 'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\simCode' ))
addpath(genpath('E:\GitHub\Bloch_simulation_Code')) % new sim code.
addpath(genpath('E:\GitHub\qMRLab-master')) %using some of their code.
addpath(genpath( 'E:\GitHub\NeuroImagingMatlab\NeuroImagingMatlab')) % for limitHandler, and CR_calc_std_residuals

%SavDir =  'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\20220204_ihMT_3prot_test_boost\fitTissParams\';
SavDir = 'E:\GitHub\Bloch_simulation_Code\fitTissParams\outputs\';
load( strcat( 'E:\GitHub\Bloch_simulation_Code\fitTissParams\','MTsat_vals2fit.mat'))   
load( strcat( 'E:\GitHub\Bloch_simulation_Code\fitTissParams\','MTsat_vals2fit_Mar16.mat'))
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_image.mat'))
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_kspace.mat'))


fit_version = '7p0_BSF'; % used as naming convention

SavDir = [SavDir,fit_version,'/'];
mkdir(SavDir)

%% Start including a change log:
logString= strcat('Rework for revision of manuscript.');

fid = fopen(strcat(SavDir,'log.txt'),'wt');
fprintf(fid, logString);
fclose(fid);


R = linspace(15,60,6);
T2a = linspace(20e-3,90e-3,3);
T1D =  [5e-4 1e-3 5e-3];% Varma 2017 was 6ms
T2b = linspace(8e-6, 12e-6, 3);
%M0b =  linspace(0.0475, 0.06, 5);  % include this to give all parameters a chance...
M0b = [0.065, 0.07, 0.075]; 
R1b = [0.25];  % can do brief sims with this one at end... Has very little impact on its own.
satFlipAngle = round(linspace(0, 220, 10));

%simLength = length(R)* length(T2a)* length(T1D)* length(T2b)* length(M0b)* length(R1b);
simLength2 = length(R)* length(T2a)* length(T1D)* length(T2b)* length(M0b)* length(R1b);

gam = 42.576;

%%
% First set a couple of initial params, then fill defaults, then set the
% rest. 
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);


Params.b1 = 0; % microTesla
Params.numSatPulse = 6;
Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train
Params.TR = 120/1000; % total repetition time = MT pulse train and readout.
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.numExcitation = 8; % number of readout lines/TR
Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params.delta = 8000;
Params.flipAngle = 5; % excitation flip angle water.
Params.echoSpacing = 7.66/1000;
Params.TD = Params.TR - (Params.numSatPulse *(Params.pulseDur+Params.pulseGapDur)) - (Params.numExcitation*Params.echoSpacing);
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.0002./Params.pulseDur; % override default Hann pulse shape.

Params.DummyEcho = 2;
Params.numExcitation = Params.numExcitation + Params.DummyEcho; % number of readout lines/TR WITH dummy

Params.boosted = 0; % use gaps in RF sat train -> NOTE this modifies the definition of numSatPul
Params.satTrainPerBoost = 1; % total number of pulses per TR = numSatPul *SatTrainPerBoost
Params.TR_MT = 0; % repetition time of satpulse train in seconds
Params = CalcVariableImagingParams(Params);


Params.NumLines = 216;
Params.NumPartitions = 192; 
Params.Slices = 176;
Params.Grappa = 1;
Params.ReferenceLines = 32;
Params.AccelerationFactor = 2;
Params.Segments = []; 
Params.TurboFactor = Params.numExcitation- Params.DummyEcho;
Params.ellipMask = 1;
[outputSamplingTable, ~, Params.Segments] = Step1_calculateKspaceSampling_v3 (Params);




% viewResult = reshape(outputSamplingTable,Params.NumLines/Params.AccelerationFactor +Params.ReferenceLines,Params.NumPartitions);
% figure;
% imagesc(viewResult)
% axis image

%% Other 2 sequences:

Params2 = Params;
Params3 = Params;

Params2.b1 = 0; % microTesla
Params2.numSatPulse = 10;
Params2.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
Params2.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train
Params2.TR = 3000/1000; % total repetition time = MT pulse train and readout.
Params2.WExcDur = 0.1/1000; % duration of water pulse
Params2.numExcitation = 200; % number of readout lines/TR
Params2.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params2.delta = 8000;
Params2.flipAngle = 11; % excitation flip angle water.
Params2.echoSpacing = 7.66/1000;
Params2.SatPulseShape = 'gausshann';
Params2.PulseOpt.bw = 0.0002./Params2.pulseDur; % override default Hann pulse shape.

Params2.DummyEcho = 2;
Params2.numExcitation = Params2.numExcitation + Params2.DummyEcho; % number of readout lines/TR WITH dummy

Params2.boosted = 1; % use gaps in RF sat train -> NOTE this modifies the definition of numSatPul
Params2.satTrainPerBoost = 10; % total number of pulses per TR = numSatPul *SatTrainPerBoost
Params2.TR_MT = 90/1000; % repetition time of satpulse train in seconds
Params2.TD_MT = Params2.TR_MT - Params2.numSatPulse* (Params2.pulseDur + Params2.pulseGapDur) ;
Params2 = CalcVariableImagingParams(Params2);

Params2.TurboFactor = Params2.numExcitation- Params2.DummyEcho;
[outputSamplingTable2, ~, Params2.Segments] = Step1_calculateKspaceSampling_v3 (Params2);


Params3.b1 = 0; % microTesla
Params3.numSatPulse = 6;
Params3.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
Params3.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train
Params3.TR = 1140/1000; % total repetition time = MT pulse train and readout.
Params3.WExcDur = 0.1/1000; % duration of water pulse
Params3.numExcitation = 80; % number of readout lines/TR
Params3.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params3.delta = 8000;
Params3.flipAngle = 7; % excitation flip angle water.
Params3.echoSpacing = 7.66/1000;
Params3.SatPulseShape = 'gausshann';
Params3.PulseOpt.bw = 0.0002./Params3.pulseDur; % override default Hann pulse shape.

Params3.DummyEcho = 2;
Params3.numExcitation = Params3.numExcitation + Params3.DummyEcho; % number of readout lines/TR WITH dummy

Params3.boosted = 1; % use gaps in RF sat train -> NOTE this modifies the definition of numSatPul
Params3.satTrainPerBoost = 9; % total number of pulses per TR = numSatPul *SatTrainPerBoost
Params3.TR_MT = 60/1000; % repetition time of satpulse train in seconds
Params3 = CalcVariableImagingParams(Params3);

Params3.TD_MT = Params3.TR_MT - Params3.numSatPulse* (Params3.pulseDur + Params3.pulseGapDur) ;
Params3.TurboFactor = Params3.numExcitation- Params3.DummyEcho;
[outputSamplingTable3, ~, Params3.Segments] = Step1_calculateKspaceSampling_v3 (Params3);



%% Tissue parameters

%% Setup parameter structure
parametersSet2 = zeros( simLength2,  6);

idx = 1;
for a = 1:length(R)    
    for b = 1:length(T2a) 
        for c = 1:length(T1D)
            for d = 1:length(T2b)
                for e = 1:length(M0b)
                    for f = 1:length(R1b)
                        
                        parametersSet2(idx,:) = [R(a),...
                            T2a(b), T1D(c), T2b(d),...
                            M0b(e), R1b(f) ]; 

                        idx = idx+1;
                    end
                end
            end
        end
    end
end

save(strcat(SavDir,'parametersSet2_v7.mat'),'parametersSet2') % save this just incase I change it at some point...




%% Run simulations
TF1 = Params.TurboFactor;
TF2 = Params2.TurboFactor;
TF3 = Params3.TurboFactor;

Single_sig1_v7 = zeros( simLength2, TF1, length(satFlipAngle));
Single_sig2_v7 = zeros( simLength2, TF2, length(satFlipAngle));
Single_sig3_v7 = zeros( simLength2, TF3, length(satFlipAngle));
Dual_sig1_v7 = zeros( simLength2, TF1,  length(satFlipAngle));
Dual_sig2_v7 = zeros( simLength2, TF2, length(satFlipAngle));
Dual_sig3_v7 = zeros( simLength2, TF3, length(satFlipAngle));

% run the
parpool

tic % Took 90 hours to run

parfor qi = 1:simLength2

    t1 = parametersSet2(qi,1);
    t2 = parametersSet2(qi,2);
    t3 = parametersSet2(qi,3);
    t4 = parametersSet2(qi,4);
    t5 = parametersSet2(qi,5);
    t6 = parametersSet2(qi,6);

    Ssig1 = zeros(TF1, length(satFlipAngle) );
    Ssig2 = zeros(TF2, length(satFlipAngle) );
    Ssig3 = zeros(TF3, length(satFlipAngle) );
    Dsig1 = zeros(TF1, length(satFlipAngle) );
    Dsig2 = zeros(TF2, length(satFlipAngle) );
    Dsig3 = zeros(TF3, length(satFlipAngle) );

    for i = 1:10
         [Ssig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'single', 'satFlipAngle', satFlipAngle(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 ); 
                        
         [Ssig2(:,i),~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'single', 'satFlipAngle', satFlipAngle(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
         
         [Ssig3(:,i),~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'single', 'satFlipAngle', satFlipAngle(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
         
         [Dsig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
              
         [Dsig2(:,i),~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );

         [Dsig3(:,i),~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 ); 
    end
                        
    Single_sig1_v7(qi,:,:) = Ssig1; 
    Single_sig2_v7(qi,:,:) = Ssig2;
    Single_sig3_v7(qi,:,:) = Ssig3; 
    Dual_sig1_v7(qi,:,:)   = Dsig1;
    Dual_sig2_v7(qi,:,:)   = Dsig2;
    Dual_sig3_v7(qi,:,:)   = Dsig3;
                                               
    if rem(qi, 50) == 0

        qi/simLength2 *100 % print percent done
    end   
end
toc

save(strcat(SavDir,'Single_sig1_v7.mat'),'Single_sig1_v7')
save(strcat(SavDir,'Single_sig2_v7.mat'),'Single_sig2_v7')
save(strcat(SavDir,'Single_sig3_v7.mat'),'Single_sig3_v7')
save(strcat(SavDir,'Dual_sig1_v7.mat'),'Dual_sig1_v7')
save(strcat(SavDir,'Dual_sig2_v7.mat'),'Dual_sig2_v7')
save(strcat(SavDir,'Dual_sig3_v7.mat'),'Dual_sig3_v7')



%% Then from the excitation train values, determine the realized GM value.

Single_sig1_gm_v7 = zeros( simLength2, length(satFlipAngle));
Single_sig2_gm_v7 = zeros( simLength2, length(satFlipAngle));
Single_sig3_gm_v7 = zeros( simLength2, length(satFlipAngle));
Dual_sig1_gm_v7 = zeros( simLength2,  length(satFlipAngle));
Dual_sig2_gm_v7 = zeros( simLength2, length(satFlipAngle));
Dual_sig3_gm_v7 = zeros( simLength2,  length(satFlipAngle));

for i = 1:simLength2
    %parfor j = 1:length(satFlipAngle)
    for j = 1:length(satFlipAngle)

        Single_sig1_gm_v7(i,j) = CR_generate_BSF_scaling_v1( squeeze(Single_sig1_v7(i,:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;  
        Single_sig2_gm_v7(i,j) = CR_generate_BSF_scaling_v1(squeeze(Single_sig2_v7(i,:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m) ;
        Single_sig3_gm_v7(i,j) = CR_generate_BSF_scaling_v1(squeeze(Single_sig3_v7(i,:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;
        Dual_sig1_gm_v7(i,j) = CR_generate_BSF_scaling_v1(squeeze(Dual_sig1_v7(i,:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;
        Dual_sig2_gm_v7(i,j) = CR_generate_BSF_scaling_v1(squeeze(Dual_sig2_v7(i,:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m);
        Dual_sig3_gm_v7(i,j) = CR_generate_BSF_scaling_v1(squeeze(Dual_sig3_v7(i,:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;  

    end
end


save(strcat(SavDir,'Single_sig1_gm_v7.mat'),'Single_sig1_gm_v7')
save(strcat(SavDir,'Single_sig2_gm_v7.mat'),'Single_sig2_gm_v7')
save(strcat(SavDir,'Single_sig3_gm_v7.mat'),'Single_sig3_gm_v7')
save(strcat(SavDir,'Dual_sig1_gm_v7.mat'),'Dual_sig1_gm_v7')
save(strcat(SavDir,'Dual_sig2_gm_v7.mat'),'Dual_sig2_gm_v7')
save(strcat(SavDir,'Dual_sig3_gm_v7.mat'),'Dual_sig3_gm_v7')


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Concatenate these values with those from v6. 
% load( strcat(SavDir,'Dual_sig3_gm_v7.mat'))


Single_sig1_gm = vertcat(Single_sig1_gm, Single_sig1_gm_v7);
Single_sig2_gm = vertcat(Single_sig2_gm, Single_sig2_gm_v7);
Single_sig3_gm = vertcat(Single_sig3_gm, Single_sig3_gm_v7);
Dual_sig1_gm = vertcat(Dual_sig1_gm, Dual_sig1_gm_v7);
Dual_sig2_gm = vertcat(Dual_sig2_gm, Dual_sig2_gm_v7); 
Dual_sig3_gm = vertcat(Dual_sig3_gm, Dual_sig3_gm_v7); 

parametersSet2 =   vertcat(parametersSet, parametersSet2);

%% Calculate MTsat on the whole matrix of signal values.
T1obs = ones(size(Dual_sig3_gm)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig3_gm)) ;


MTsat_sim_Single1 = calcMTsatThruLookupTablewithDummyV3( Single_sig1_gm, [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Single2 = calcMTsatThruLookupTablewithDummyV3( Single_sig2_gm, [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Single3 = calcMTsatThruLookupTablewithDummyV3( Single_sig3_gm, [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( Dual_sig2_gm,   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( Dual_sig3_gm,   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);




%% Debugging:
%  satFlipAngle = 0:2:18;
% 
%  
%  [outputSamplingTable2, elem, Params2.Segments] = Step1_calculateKspaceSampling_v3 (Params2);
%  [outputSamplingTable3, ~, Params3.Segments] = Step1_calculateKspaceSampling_v3 (Params3);
%  
% t1 = 0.5; %R1b(f);
% t2 = 0.05; %M0b(e);
% t3 = 8e-6; %T2b(d);
% t4 = 1e-4; %T1D(c);
% t5 = 60e-3; %T2a(b);
% t6 = 15; %R
%  t2 = 0.045; %M0b(e);
%  
% [~, ~, inputMag] = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),'Rb', t1, 'M0b', t2, 'T2b',t3, 'T1D', t4, 'T2a', t5, 'R', t6 ); % MT-weighted signal simulation
% 
% temp = CR_generate_BSF_scaling_v1(inputMag, Params2, outputSamplingTable2, gm_m, fft_gm_m)
% temp1   = calcMTsatThruLookupTablewithDummyV3( temp,   [], 1.4.*1000, [], 1, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho)
% 
% 
% inputMag1 = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),'Rb', t1, 'M0b', t2, 'T2b',t3, 'T1D', t4, 'T2a', t5, 'R', t6 ); % MT-weighted signal simulation
% temp2 = CR_generate_BSF_scaling_v1(inputMag1, Params3, outputSamplingTable3,  gm_m, fft_gm_m)
% temp3   = calcMTsatThruLookupTablewithDummyV3( temp2,   [], 1.4.*1000, [], 1, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho)
% 


%% Remove row zeros to save time:
maxRowS = max(MTsat_sim_Dual1,[],2);

MTsat_sim_Single1(maxRowS == 0,:) = [];
MTsat_sim_Single2(maxRowS == 0,:) = [];
MTsat_sim_Single3(maxRowS == 0,:) = [];
MTsat_sim_Dual1(maxRowS == 0,:) = [];
MTsat_sim_Dual2(maxRowS == 0,:) = [];
MTsat_sim_Dual3(maxRowS == 0,:) = [];
parametersSet2(maxRowS == 0,:) = [];

%% Fit the data
fit_degree = 7;
Single_c1 = zeros( length(MTsat_sim_Single1),  fit_degree+1);
Single_c2 = zeros( length(MTsat_sim_Single1),  fit_degree+1);
Single_c3 = zeros( length(MTsat_sim_Single1),  fit_degree+1);
Dual_c1 = zeros( length(MTsat_sim_Dual1), fit_degree+1);
Dual_c2 = zeros( length(MTsat_sim_Dual1), fit_degree+1);
Dual_c3 = zeros( length(MTsat_sim_Dual1), fit_degree+1);

tic % super fast, few seconds  
for i = 1:length(MTsat_sim_Dual1)
                    
     % With B1's simulated ->Fit polynomial: 
     Single_c1(i,:) = polyfit(satFlipAngle, MTsat_sim_Single1(i,:), fit_degree);
     Single_c2(i,:) = polyfit(satFlipAngle, MTsat_sim_Single2(i,:), fit_degree);
     Single_c3(i,:) = polyfit(satFlipAngle, MTsat_sim_Single3(i,:), fit_degree);
     Dual_c1(i,:)   = polyfit(satFlipAngle, MTsat_sim_Dual1(i,:), fit_degree);
     Dual_c2(i,:)   = polyfit(satFlipAngle, MTsat_sim_Dual2(i,:), fit_degree);
     Dual_c3(i,:)   = polyfit(satFlipAngle, MTsat_sim_Dual3(i,:), fit_degree);
     
     % Try again using this: polyfitweighted, with the B1 as the weight!
     
end
toc

% % Can do a quick check if you want!
% i = 1;
% x1 = linspace(0,18,100);
% y1 = polyval(Single_c1(i,:),x1);
% figure
% plot(satFlipAngle, MTsat_sim_Single1(i,:),'o')
% hold on
% plot(x1,y1)
% hold off

                         
 %% With fitted data, calculate residuals: https://www.mathworks.com/help/matlab/ref/polyfit.html
 % To see how good the fit is, evaluate the polynomial at the data points and generate a table showing the data, fit, and error.      


% stack matrices:
% Sort B1 , then sat values, then smooth them
[~, sortidx_b1] = sort(  exportMat(10,:) , 'ascend');

% Sort the whole matrix:
mat_sort = exportMat( :, sortidx_b1);

% Smooth matrix
mat_ss = smoothdata( mat_sort,2, 'movmedian', 10);

% Make sure you have satFlipAngle values! Multiply B1 map by the satFlipAngle of the sequence 
% Used to be B1, now it is the flip angle. This is how the sequence was
% coded.
b1_1 =(11.4*gam*360*Params.pulseDur)* mat_ss(10,:) ; 
b1_2 = (13.3*gam*360*Params2.pulseDur)* mat_ss(10,:) ; 
b1_3 = (11.6*gam*360*Params3.pulseDur)*mat_ss(10,:) ; 

%% Quick plot of each to see that the data looks OK
% figure; heatscatter(b1_1', mat_ss(1,:)'); %ylim([0 0.04]); xlim([0 15])
% figure; heatscatter(b1_3', mat_ss(6,:)'); %ylim([0 0.04]); xlim([0 15])


%% Calculate Standardized Residuals
% this can take a few minutes of run time.
std_resid_d1 = CR_calc_std_residuals( b1_1, mat_ss(1,:) , Dual_c1);
std_resid_d2 = CR_calc_std_residuals( b1_2, mat_ss(2,:) , Dual_c2);
std_resid_d3 = CR_calc_std_residuals( b1_3, mat_ss(3,:) , Dual_c3);

std_resid_s1 = CR_calc_std_residuals( b1_1, mat_ss(4,:) , Single_c1);
std_resid_s2 = CR_calc_std_residuals( b1_2, mat_ss(5,:) , Single_c2);
std_resid_s3 = CR_calc_std_residuals( b1_3, mat_ss(6,:) , Single_c3);

standardized_residuals = [std_resid_d1, std_resid_d2, std_resid_d3, std_resid_s1, std_resid_s2, std_resid_s3];

 save(strcat(SavDir,'standardized_residuals.mat'),'standardized_residuals')        
 
 
 %%  add the columns
 errorScore = sum( abs(standardized_residuals) , 2 ); % can have negatives, so combine abs of each
 
 % Dual Only
  %errorScore = sum( abs(standardized_residuals(:,1:3)) , 2 ); % can have negatives, so combine abs of each
 %errorScore = sum( abs(standardized_residuals(:,2)) , 2 ); % can have negatives, so combine abs of each
 
 
 % Sort based on this, then store in table :) 
 
% for best protocol, take top 10 most efficient protocols. Then sort by
% absolute ihMT

[~, sortidx] = sort(errorScore, 'ascend');
Top50sorted = parametersSet2 ( sortidx(1:end),:);
Top50Errors = errorScore ( sortidx(1:end),:);
Top50sortedTable = array2table(Top50sorted, 'VariableNames',{'R', 'T2a', 'T1D', 'T2b', 'M0b','R1b'});

save(strcat(SavDir,'Top50sortedTable.mat'),'Top50sortedTable')      


str = ['R = ',num2str(Top50sorted(1,1)),', T2a = ',num2str(Top50sorted(1,2)),...
    ', T1D = ',num2str(Top50sorted(1,3)), ', T2b =',num2str(Top50sorted(1,4)),...
    ', M0b = ',num2str(Top50sorted(1,5)),', R1b = ',num2str(Top50sorted(1,6))];
                         
% Check what the top one looks like with the data!      
  % Check first few, number 1 looked off here, 2 was better
  
SortIndex = sortidx(1); % select the sorted line you want
x1_line = linspace(0,220,100);
y1 = polyval( Dual_c1(SortIndex,:), x1_line);
y2 = polyval( Dual_c2(SortIndex,:), x1_line);
y3 = polyval( Dual_c3(SortIndex,:), x1_line);



figure;
subplot(1,2,1)
heatscatter(b1_1', mat_ss(1,:)' ); 
hold on
heatscatter(b1_2', mat_ss(2,:)' ); 
heatscatter(b1_3', mat_ss(3,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Dual');
colorbar off
ax = gca; ax.FontSize = 20; 
hold off


y1 = polyval( Single_c1( SortIndex,:), x1_line);
y2 = polyval( Single_c2( SortIndex,:), x1_line);
y3 = polyval( Single_c3( SortIndex,:), x1_line);

subplot(1,2,2)
heatscatter(b1_1', mat_ss(4,:)' ); 
hold on
heatscatter(b1_2', mat_ss(5,:)' ); 
heatscatter(b1_3', mat_ss(6,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Single')
ax = gca; ax.FontSize = 20; 
colorbar off
hold off                     
  set(gcf,'position',[10,400,1200,400])                       
     sgtitle(str)             
     
     

   saveas(gcf,strcat(SavDir,'initial_best_parameters_fit2Optimal.png'))  
     
     
     
   
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %% Redo fit with second set of data.

% stack matrices:
% Sort B1 , then sat values, then smooth them
[~, sortidx_b1] = sort(  exportMat2(10,:) , 'ascend');

% Sort the whole matrix:
mat_sort = exportMat2( :, sortidx_b1);

% Smooth matrix
mat_ss = smoothdata( mat_sort,2, 'movmedian', 10);

% Make sure you have satFlipAngle values! Multiply B1 map by the satFlipAngle of the sequence 
b1_1 =(11.4*gam*360*Params.pulseDur)* mat_ss(10,:) ; 
b1_2 = (13.3*gam*360*Params2.pulseDur)* mat_ss(10,:) ; 
b1_3 = (11.6*gam*360*Params3.pulseDur)*mat_ss(10,:) ; 

%% Quick plot of each to see that the data looks OK
% figure; heatscatter(b1_1', mat_ss(1,:)'); %ylim([0 0.04]); xlim([0 15])
% figure; heatscatter(b1_3', mat_ss(6,:)'); %ylim([0 0.04]); xlim([0 15])


%% Calculate Standardized Residuals
% this can take a few minutes of run time.
std_resid_d1 = CR_calc_std_residuals( b1_1, mat_ss(1,:) , Dual_c1);
std_resid_d2 = CR_calc_std_residuals( b1_2, mat_ss(2,:) , Dual_c2);
std_resid_d3 = CR_calc_std_residuals( b1_3, mat_ss(3,:) , Dual_c3);

std_resid_s1 = CR_calc_std_residuals( b1_1, mat_ss(4,:) , Single_c1);
std_resid_s2 = CR_calc_std_residuals( b1_2, mat_ss(5,:) , Single_c2);
std_resid_s3 = CR_calc_std_residuals( b1_3, mat_ss(6,:) , Single_c3);

standardized_residuals2 = [std_resid_d1, std_resid_d2, std_resid_d3, std_resid_s1, std_resid_s2, std_resid_s3];

save(strcat(SavDir,'standardized_residuals2.mat'),'standardized_residuals2')        
 


 %%  add the columns
 errorScore = sum( abs(standardized_residuals2) , 2 ); % can have negatives, so combine abs of each
 
 % Dual Only
 %errorScore = sum( abs(standardized_residuals2(:,1:3)) , 2 ); % can have negatives, so combine abs of each
 
 % Sort based on this, then store in table :) 
 
% for best protocol, take top 10 most efficient protocols. Then sort by
% absolute ihMT

[temp, sortidx2] = sort(errorScore, 'ascend');
Top50sorted2 = parametersSet2 ( sortidx2(1:end),:);
Top50Errors2 = errorScore ( sortidx2(1:end),:);
Top50sortedTable2 = array2table(Top50sorted2, 'VariableNames',{'R', 'T2a', 'T1D', 'T2b', 'M0b','R1b'});

save(strcat(SavDir,'Top50sortedTable2.mat'),'Top50sortedTable2')   


str = ['R = ',num2str(Top50sorted2(1,1)),', T2a = ',num2str(Top50sorted2(1,2)),...
    ', T1D = ',num2str(Top50sorted2(1,3)), ', T2b =',num2str(Top50sorted2(1,4)),...
    ', M0b = ',num2str(Top50sorted2(1,5)),', R1b = ',num2str(Top50sorted2(1,6))];
                         
% Check what the top one looks like with the data!      
  % Check first few, number 1 looked off here, 2 was better
  
SortIndex = sortidx2(1); % select the sorted line you want
x1_line = linspace(0,220,100);
y1 = polyval( Dual_c1(SortIndex,:), x1_line);
y2 = polyval( Dual_c2(SortIndex,:), x1_line);
y3 = polyval( Dual_c3(SortIndex,:), x1_line);



figure;
subplot(1,2,1)
heatscatter(b1_1', mat_ss(1,:)' ); 
hold on
heatscatter(b1_2', mat_ss(2,:)' ); 
heatscatter(b1_3', mat_ss(3,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Dual');
colorbar off
ax = gca; ax.FontSize = 20; 
hold off


y1 = polyval( Single_c1( SortIndex,:), x1_line);
y2 = polyval( Single_c2( SortIndex,:), x1_line);
y3 = polyval( Single_c3( SortIndex,:), x1_line);

subplot(1,2,2)
heatscatter(b1_1', mat_ss(4,:)' ); 
hold on
heatscatter(b1_2', mat_ss(5,:)' ); 
heatscatter(b1_3', mat_ss(6,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Single')
ax = gca; ax.FontSize = 20; 
colorbar off
hold off                     
  set(gcf,'position',[10,400,1200,400])                       
     sgtitle(str)             
     
     

   saveas(gcf,strcat(SavDir,'initial_best_parameters_fit2Optimal_2.png'))  
     
     
     
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   


     
%% Next use the simulation results to build a lookup table to fit tissue parameters more precisely.

TParams  = fitTissueParamsFromLUT( parametersSet2, sum(abs([standardized_residuals,standardized_residuals2]),2) , 20);

save(strcat(SavDir,'TParams.mat'),'TParams')

idx = 25;
fit_degree = 7;

%% These parameters provided a good fit
% TParams = [ 50;...      % R
%             80e-3;...   % T2a
%             0.75e-3;...    % T1D
%             11.5e-6;...  % T2b
%             0.072;...   % M0b
%            0.25];         % R1b

%% Run one more set of simulations with the fit parameters to confirm the fit. 
TParams = [ 50;...      % R
            50e-3;...   % T2a
            0.75e-3;...    % T1D
            11.5e-6;...  % T2b
            0.071;...   % M0b
           0.25];         % R1b
    
t1 = TParams(1);
t2 = TParams(2);
t3 = TParams(3);
t4 = TParams(4);
t5 = TParams(5);
t6 = TParams(6);

Single_sig1_f = zeros(  Params.TurboFactor, length(satFlipAngle));
Single_sig2_f = zeros(  Params2.TurboFactor, length(satFlipAngle));
Single_sig3_f = zeros(  Params3.TurboFactor, length(satFlipAngle));
Dual_sig1_f = zeros( Params.TurboFactor,  length(satFlipAngle));
Dual_sig2_f = zeros( Params2.TurboFactor, length(satFlipAngle));
Dual_sig3_f = zeros( Params3.TurboFactor, length(satFlipAngle));


parfor i = 1:10
     [Ssig1,~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'single', 'satFlipAngle', satFlipAngle(i),...
         'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );           

     [Ssig2,~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'single', 'satFlipAngle', satFlipAngle(i),...
         'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );

     [Ssig3,~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'single', 'satFlipAngle', satFlipAngle(i),...
         'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );

     [Dsig1,~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),...
         'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );

     [Dsig2,~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),...
         'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );

     [Dsig3,~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate', 'satFlipAngle', satFlipAngle(i),...
         'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 ); 

     % store values
     Single_sig1_f(:,i)   = Ssig1;
     Single_sig2_f(:,i)   = Ssig2;
     Single_sig3_f(:,i)   = Ssig3;

     Dual_sig1_f(:,i)   = Dsig1;
     Dual_sig2_f(:,i)   = Dsig2;
     Dual_sig3_f(:,i)   = Dsig3;
end


Single_sig1_gm_f = zeros(length(satFlipAngle),1);
Single_sig2_gm_f = zeros(length(satFlipAngle),1);
Single_sig3_gm_f = zeros(length(satFlipAngle),1);
Dual_sig1_gm_f = zeros(length(satFlipAngle),1);
Dual_sig2_gm_f = zeros(length(satFlipAngle),1);
Dual_sig3_gm_f = zeros(length(satFlipAngle),1);

% calculate values based on full k-space data
for j = 1:length(satFlipAngle)
    Single_sig1_gm_f(j) = CR_generate_BSF_scaling_v1( squeeze(Single_sig1_f(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;  
    Single_sig2_gm_f(j) = CR_generate_BSF_scaling_v1(squeeze(Single_sig2_f(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m) ;
    Single_sig3_gm_f(j) = CR_generate_BSF_scaling_v1(squeeze(Single_sig3_f(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;
    Dual_sig1_gm_f(j) = CR_generate_BSF_scaling_v1(squeeze(Dual_sig1_f(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;
    Dual_sig2_gm_f(j) = CR_generate_BSF_scaling_v1(squeeze(Dual_sig2_f(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m);
    Dual_sig3_gm_f(j) = CR_generate_BSF_scaling_v1(squeeze(Dual_sig3_f(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m);   
end


% calculate MTsat
T1obs = ones(size(Dual_sig1_gm_f)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig1_gm_f)) ;


MTsat_sim_Single1_f = calcMTsatThruLookupTablewithDummyV3( Single_sig1_gm_f, [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Single2_f = calcMTsatThruLookupTablewithDummyV3( Single_sig2_gm_f, [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Single3_f = calcMTsatThruLookupTablewithDummyV3( Single_sig3_gm_f, [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1_f   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm_f,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2_f   = calcMTsatThruLookupTablewithDummyV3( Dual_sig2_gm_f,   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3_f   = calcMTsatThruLookupTablewithDummyV3( Dual_sig3_gm_f,   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);

% fit the simulations with a polynomial
Single_c1_f = polyfit(satFlipAngle, MTsat_sim_Single1_f, fit_degree);
Single_c2_f = polyfit(satFlipAngle, MTsat_sim_Single2_f, fit_degree);
Single_c3_f = polyfit(satFlipAngle, MTsat_sim_Single3_f, fit_degree);
Dual_c1_f   = polyfit(satFlipAngle, MTsat_sim_Dual1_f, fit_degree);
Dual_c2_f   = polyfit(satFlipAngle, MTsat_sim_Dual2_f, fit_degree);
Dual_c3_f   = polyfit(satFlipAngle, MTsat_sim_Dual3_f, fit_degree);

% combine both scatterplots


[~, sortidx_b1] = sort(  exportMat(10,:) , 'ascend');

% Sort the whole matrix:
mat_sort = exportMat( :, sortidx_b1);

% Smooth matrix
mat_ss1 = smoothdata( mat_sort,2, 'movmedian', 10);

% Make sure you have satFlipAngle values! Multiply B1 map by the satFlipAngle of the sequence 
b1_1_1 = (11.4*gam*360*Params.pulseDur)* mat_ss1(10,:) ; 
b1_2_1 = (13.3*gam*360*Params2.pulseDur) * mat_ss1(10,:) ; 
b1_3_1 = (11.6*gam*360*Params3.pulseDur)*mat_ss1(10,:) ; 

% stack matrices:
% Sort B1 , then sat values, then smooth them
[~, sortidx_b1] = sort(  exportMat2(10,:) , 'ascend');

% Sort the whole matrix:
mat_sort = exportMat2( :, sortidx_b1);

% Smooth matrix
mat_ss2 = smoothdata( mat_sort,2, 'movmedian', 10);

% Make sure you have satFlipAngle values! Multiply B1 map by the satFlipAngle of the sequence 
b1_1_2 = (11.4*gam*360*Params.pulseDur)* mat_ss2(10,:) ; 
b1_2_2 = (13.3*gam*360*Params.pulseDur) * mat_ss2(10,:) ; 
b1_3_2 = (11.6*gam*360*Params.pulseDur)*mat_ss2(10,:) ; 


% concatenate:
b1_1 = [b1_1_1, b1_1_2];
b1_2 = [b1_2_1, b1_2_2];
b1_3 = [b1_3_1, b1_3_2];

mat_ss = [mat_ss1, mat_ss2];



%% Now plot the results
x1_line = linspace(0,220,100);
y1 = polyval( Dual_c1_f, x1_line);
y2 = polyval( Dual_c2_f, x1_line);
y3 = polyval( Dual_c3_f, x1_line);

str = ['R = ',num2str(TParams(1)),', T2a = ',num2str(TParams(2)),...
    ', T1D = ',num2str(TParams(3)), ', T2b =',num2str(TParams(4)),...
    ', M0b = ',num2str(TParams(5)),', R1b = ',num2str(TParams(6))];

figure;
subplot(1,2,1)
heatscatter(b1_1', mat_ss(1,:)' ); 
hold on
heatscatter(b1_2', mat_ss(2,:)' ); 
heatscatter(b1_3', mat_ss(3,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Dual');
colorbar off
ax = gca; ax.FontSize = 20; 
hold off


y1 = polyval( Single_c1_f, x1_line);
y2 = polyval( Single_c2_f, x1_line);
y3 = polyval( Single_c3_f, x1_line);

subplot(1,2,2)
heatscatter(b1_1', mat_ss(4,:)' ); 
hold on
heatscatter(b1_2', mat_ss(5,:)' ); 
heatscatter(b1_3', mat_ss(6,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Single')
ax = gca; ax.FontSize = 20; 
colorbar off
hold off                     
  set(gcf,'position',[10,400,1200,400])                       
 sgtitle(str)          
        


saveas(gcf,strcat(SavDir,'temp/Final_best_parameters_fit2Optimal_',num2str(idx),'.png'))  
idx = idx+1;    
     






