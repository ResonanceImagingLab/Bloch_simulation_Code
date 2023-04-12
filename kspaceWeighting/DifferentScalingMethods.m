% K-space weighting came about as a way to match simulations to acquired
% values. This script shows how this compares to doing PSF based scaling.


% Lets use the values from the fitTissueParameters:

load( strcat( 'E:\GitHub\Bloch_simulation_Code\fitTissParams\','MTsat_vals2fit.mat'))   
load( strcat( 'E:\GitHub\Bloch_simulation_Code\fitTissParams\','MTsat_vals2fit_Mar16.mat'))
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_image.mat'))
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_kspace.mat'))

%% Extract values of MTsat around b1 = 1.
[x,y] = size(exportMat);
TF_b1 = zeros(1,y);
TF_b1(exportMat(10,:) > 0.99 & exportMat(10,:) < 1.01 ) = 1;

mat_sort = exportMat;
mat_sort(:, ~TF_b1) = [];

% Make a 1x6 vector of mtsat values
acqMTsat = median(mat_sort(1:6,:),2);

%% Set up Simulation parameters
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);


Params.satFlipAngle = 134; % microTesla
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
[outputSamplingTable, ~, ~] = Step1_calculateKspaceSampling_v3 (Params);

Params2 = Params;
Params3 = Params;

Params2.satFlipAngle = 157; % microTesla
Params2.numSatPulse = 10;
Params2.TR = 3000/1000; % total repetition time = MT pulse train and readout.
Params2.numExcitation = 200; % number of readout lines/TR
Params2.flipAngle = 11; % excitation flip angle water.
Params2.PulseOpt.bw = 0.0002./Params2.pulseDur; % override default Hann pulse shape.
Params2.numExcitation = Params2.numExcitation + Params2.DummyEcho; % number of readout lines/TR WITH dummy
Params2.boosted = 1; % use gaps in RF sat train -> NOTE this modifies the definition of numSatPul
Params2.satTrainPerBoost = 10; % total number of pulses per TR = numSatPul *SatTrainPerBoost
Params2.TR_MT = 90/1000; % repetition time of satpulse train in seconds
Params2.TD_MT = Params2.TR_MT - Params2.numSatPulse* (Params2.pulseDur + Params2.pulseGapDur) ;
Params2 = CalcVariableImagingParams(Params2);
Params2.TurboFactor = Params2.numExcitation- Params2.DummyEcho;
[outputSamplingTable2, ~, ~] = Step1_calculateKspaceSampling_v3 (Params2);

Params3.satFlipAngle = 136; % microTesla
Params3.numSatPulse = 6;
Params3.TR = 1140/1000; % total repetition time = MT pulse train and readout.
Params3.numExcitation = 80; % number of readout lines/TR
Params3.flipAngle = 7; % excitation flip angle water.
Params3.PulseOpt.bw = 0.0002./Params3.pulseDur; % override default Hann pulse shape.
Params3.numExcitation = Params3.numExcitation + Params3.DummyEcho; % number of readout lines/TR WITH dummy
Params3.boosted = 1; % use gaps in RF sat train -> NOTE this modifies the definition of numSatPul
Params3.satTrainPerBoost = 9; % total number of pulses per TR = numSatPul *SatTrainPerBoost
Params3.TR_MT = 60/1000; % repetition time of satpulse train in seconds
Params3 = CalcVariableImagingParams(Params3);
Params3.TD_MT = Params3.TR_MT - Params3.numSatPulse* (Params3.pulseDur + Params3.pulseGapDur) ;
Params3.TurboFactor = Params3.numExcitation- Params3.DummyEcho;
[outputSamplingTable3, ~, ~] = Step1_calculateKspaceSampling_v3 (Params3);

%% Get the magnetization vector for 6 metrics

[Ssig1,~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'single');              
[Ssig2,~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'single');
[Ssig3,~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'single');
[Dsig1,~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate' ); 
[Dsig2,~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate' );
[Dsig3,~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate' ); 


%% Start with the proposed method:
Single_sig1_gm = CR_generate_BSF_scaling_v1( Ssig1, Params, outputSamplingTable, gm_m, fft_gm_m) ;  
Single_sig2_gm = CR_generate_BSF_scaling_v1( Ssig2, Params2, outputSamplingTable2, gm_m, fft_gm_m) ;
Single_sig3_gm = CR_generate_BSF_scaling_v1( Ssig3, Params3, outputSamplingTable3, gm_m, fft_gm_m) ;
Dual_sig1_gm = CR_generate_BSF_scaling_v1( Dsig1, Params, outputSamplingTable, gm_m, fft_gm_m) ;
Dual_sig2_gm = CR_generate_BSF_scaling_v1( Dsig2, Params2, outputSamplingTable2, gm_m, fft_gm_m);
Dual_sig3_gm = CR_generate_BSF_scaling_v1( Dsig3, Params3, outputSamplingTable3, gm_m, fft_gm_m) ;  

T1obs = ones(size(Dual_sig3_gm)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig3_gm)) ;


MTsat_sim_Single1 = calcMTsatThruLookupTablewithDummyV3( Single_sig1_gm, [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Single2 = calcMTsatThruLookupTablewithDummyV3( Single_sig2_gm, [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Single3 = calcMTsatThruLookupTablewithDummyV3( Single_sig3_gm, [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( Dual_sig2_gm,   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( Dual_sig3_gm,   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);

simMTsat = [MTsat_sim_Dual1; MTsat_sim_Dual2; MTsat_sim_Dual3; ...
    MTsat_sim_Single1; MTsat_sim_Single2; MTsat_sim_Single3];


%% Now look at PSF based approach
% get the PSF of each of the magnetization vectors

% fill kspace
ks1 = CR_fillKspaceSamplingTable_v2( Ssig1, outputSamplingTable, Params);
ks2 = CR_fillKspaceSamplingTable_v2( Ssig2, outputSamplingTable2, Params2);
ks3 = CR_fillKspaceSamplingTable_v2( Ssig3, outputSamplingTable3, Params3);
kd1 = CR_fillKspaceSamplingTable_v2( Dsig1, outputSamplingTable, Params);
kd2 = CR_fillKspaceSamplingTable_v2( Dsig2, outputSamplingTable2, Params2);
kd3 = CR_fillKspaceSamplingTable_v2( Dsig3, outputSamplingTable3, Params3);

% add grappa lines
ks1 = CR_interpolateMissingGrappaLines( ks1);
ks2 = CR_interpolateMissingGrappaLines( ks2);
ks3 = CR_interpolateMissingGrappaLines( ks3);
kd1 = CR_interpolateMissingGrappaLines( kd1);
kd2 = CR_interpolateMissingGrappaLines( kd2);
kd3 = CR_interpolateMissingGrappaLines( kd3);

% figure; imagesc(log(kd1*1000)); caxis([3.8, 4.0])

% reference values defined as first value in mag train
refV = [Ssig1(1); Ssig2(1); Ssig3(1); Dsig1(1); Dsig2(1); Dsig3(1)];
refMat = ones(size(ks1));
refMat(ks1 == 0) = 0; % apply elliptical mask

% Compare the peaks of the FT values
% lets try with and without interpolating.

psfs1 = abs(ifftshift(ifft2(ks1)));
psfs2 = abs(ifftshift(ifft2(ks2)));
psfs3 = abs(ifftshift(ifft2(ks3)));
psfd1 = abs(ifftshift(ifft2(kd1)));
psfd2 = abs(ifftshift(ifft2(kd2)));
psfd3 = abs(ifftshift(ifft2(kd3)));

% rev vales
psfs1Ref = abs(ifftshift(ifft2( refV(1) * refMat )));
psfs2Ref = abs(ifftshift(ifft2( refV(2) * refMat )));
psfs3Ref = abs(ifftshift(ifft2( refV(3) * refMat )));

psfd1Ref = abs(ifftshift(ifft2( refV(4) * refMat )));
psfd2Ref = abs(ifftshift(ifft2( refV(5) * refMat )));
psfd3Ref = abs(ifftshift(ifft2( refV(6) * refMat )));


attenuationVector = [ max(psfs1,[],'all')/max(psfs1Ref,[],'all');...
                        max(psfs2,[],'all')/max(psfs2Ref,[],'all');...
                        max(psfs3,[],'all')/max(psfs3Ref,[],'all');...
                        max(psfd1,[],'all')/max(psfd1Ref,[],'all');...
                        max(psfd2,[],'all')/max(psfd2Ref,[],'all');...
                        max(psfd3,[],'all')/max(psfd3Ref,[],'all')];


attenMag = attenuationVector .* refV;

MTsat_sim_Single1 = calcMTsatThruLookupTablewithDummyV3( attenMag(1), [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Single2 = calcMTsatThruLookupTablewithDummyV3( attenMag(2), [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Single3 = calcMTsatThruLookupTablewithDummyV3( attenMag(3), [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( attenMag(4),   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( attenMag(5),   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( attenMag(6),   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);

psfMTsat1 = [MTsat_sim_Dual1; MTsat_sim_Dual2; MTsat_sim_Dual3; ...
    MTsat_sim_Single1; MTsat_sim_Single2; MTsat_sim_Single3];


%% repeat above but we will upsample the matrices
[x, y] = size(ks1);
xVec =  -1*(x/2)+1: (x/2);     % X vectors to center on 0
yVec =  -1*(y/2)+1: (y/2);     % X vectors to center on 0
IncrementVal = 0.01;
interXVec = -1*(x/2)+1 :IncrementVal: (x/2)+1; 
interYVec = -1*(y/2)+1 :IncrementVal: (y/2)+1; 
[xVecM, yVecM] = ndgrid(xVec,yVec);
[interXVec,interYVec] = ndgrid(interXVec,interYVec);


Interpolated_psfs1 = interpn(xVecM, yVecM, psfs1, interXVec, interYVec, 'spline');
Interpolated_psfs2 = interpn(xVecM, yVecM, psfs2, interXVec, interYVec, 'spline');
Interpolated_psfs3 = interpn(xVecM, yVecM, psfs3, interXVec, interYVec, 'spline');
Interpolated_psfd1 = interpn(xVecM, yVecM, psfd1, interXVec, interYVec, 'spline');
Interpolated_psfd2 = interpn(xVecM, yVecM, psfd2, interXVec, interYVec, 'spline');
Interpolated_psfd3 = interpn(xVecM, yVecM, psfd3, interXVec, interYVec, 'spline');


Interpolated_psfs1Ref = interpn(xVecM, yVecM, psfs1Ref, interXVec, interYVec, 'spline');
Interpolated_psfs2Ref = interpn(xVecM, yVecM, psfs2Ref, interXVec, interYVec, 'spline');
Interpolated_psfs3Ref = interpn(xVecM, yVecM, psfs3Ref, interXVec, interYVec, 'spline');
Interpolated_psfd1Ref = interpn(xVecM, yVecM, psfd1Ref, interXVec, interYVec, 'spline');
Interpolated_psfd2Ref = interpn(xVecM, yVecM, psfd2Ref, interXVec, interYVec, 'spline');
Interpolated_psfd3Ref = interpn(xVecM, yVecM, psfd3Ref, interXVec, interYVec, 'spline');


attenuationVector = [ max(Interpolated_psfs1,[],'all')/max(Interpolated_psfs1Ref,[],'all');...
                        max(Interpolated_psfs2,[],'all')/max(Interpolated_psfs2Ref,[],'all');...
                        max(Interpolated_psfs3,[],'all')/max(Interpolated_psfs3Ref,[],'all');...
                        max(Interpolated_psfd1,[],'all')/max(Interpolated_psfd1Ref,[],'all');...
                        max(Interpolated_psfd2,[],'all')/max(Interpolated_psfd2Ref,[],'all');...
                        max(Interpolated_psfd3,[],'all')/max(Interpolated_psfd3Ref,[],'all')];


attenMag = attenuationVector .* refV;

MTsat_sim_Single1 = calcMTsatThruLookupTablewithDummyV3( attenMag(1), [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Single2 = calcMTsatThruLookupTablewithDummyV3( attenMag(2), [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Single3 = calcMTsatThruLookupTablewithDummyV3( attenMag(3), [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( attenMag(4),   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( attenMag(5),   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( attenMag(6),   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);

psfMTsat2 = [MTsat_sim_Dual1; MTsat_sim_Dual2; MTsat_sim_Dual3; ...
    MTsat_sim_Single1; MTsat_sim_Single2; MTsat_sim_Single3];








%% Plot
% percentDiff_simVsacq = (acqMTsat - simMTsat)./ acqMTsat;
% avgPerDiff = mean(percentDiff_simVsacq);
sortRows = [4, 6, 5, 1, 3, 2];

figure;
scatter(1:6, acqMTsat(sortRows,:), 50, "o")
hold on
scatter(1:6, simMTsat(sortRows,:), 50, "diamond")
scatter(1:6, psfMTsat1(sortRows,:), 100, "+")
scatter(1:6, psfMTsat2(sortRows,:), 100,"x")
legend('Acquired Data','Manuscript Simulations','PSF Attenuated',...
    'PSF Attenuated Upsampled','location','best','FontSize', 14)
ylabel('MT_{sat} (a.u.)')
xlim([0.5 6.5])
xticks(1:6)
xticklabels({'Single TF=8','Single TF=80','Single TF=200',...
    'Dual TF=8','Dual TF=80','Dual TF=200'})
ax = gca;    ax.FontSize = 16; 

