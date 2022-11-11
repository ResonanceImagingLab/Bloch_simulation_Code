addpath(genpath('C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4')) % new sim code.
addpath(genpath('C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\qMRLab-master')) %using some of their code.
addpath(genpath( 'E:\Research\Code\NeuroImagingMatlab\NeuroImagingMatlab')) % for limitHandler, and CR_calc_std_residuals


%SavDir =  'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\20220204_ihMT_3prot_test_boost\fitTissParams\';
SavDir = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\fitTissParams\outputs\';
load( strcat( 'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\20220204_ihMT_3prot_test_boost\fitTissParams\','MTsat_vals2fit.mat'))   
load( strcat( 'E:\Research\SeqDevelopment\CorticalihMT\cortical_ihMT_sim\data\20220204_ihMT_3prot_test_boost\fitTissParams\','MTsat_vals2fit_Mar16.mat'))
load( strcat( 'E:\Research\SeqDevelopment\CorticalihMT/cortical_ihMT_sim/kspaceWeighting\','GM_seg_MNI_152_image.mat'))
load( strcat( 'E:\Research\SeqDevelopment\CorticalihMT/cortical_ihMT_sim/kspaceWeighting\','GM_seg_MNI_152_kspace.mat'))


%% Sort Input data first:
[~, sortidx_b1] = sort(  exportMat(10,:) , 'ascend');

% Sort the whole matrix:
mat_sort = exportMat( :, sortidx_b1);

% Smooth matrix
mat_ss = smoothdata( mat_sort,2, 'movmedian', 10);

% Make sure you have B1rms values! Multiply B1 map by the B1rms of the sequence 
b1_1 =11.4* mat_ss(10,:) ; 
b1_2 = 13.3 * mat_ss(10,:) ; 
b1_3 = 11.6*mat_ss(10,:) ; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start with dual to largely get rid of the impact of T1D

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
Params.SatPulseShape = 'gausshann';

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

Params3.DummyEcho = 2;
Params3.numExcitation = Params3.numExcitation + Params3.DummyEcho; % number of readout lines/TR WITH dummy

Params3.boosted = 1; % use gaps in RF sat train -> NOTE this modifies the definition of numSatPul
Params3.satTrainPerBoost = 9; % total number of pulses per TR = numSatPul *SatTrainPerBoost
Params3.TR_MT = 60/1000; % repetition time of satpulse train in seconds
Params3 = CalcVariableImagingParams(Params3);

Params3.TD_MT = Params3.TR_MT - Params3.numSatPulse* (Params3.pulseDur + Params3.pulseGapDur) ;
Params3.TurboFactor = Params3.numExcitation- Params3.DummyEcho;
[outputSamplingTable3, ~, Params3.Segments] = Step1_calculateKspaceSampling_v3 (Params3);


%% Simulations
Params.ModelSpinDiffusion =1;
Params2.ModelSpinDiffusion =1;
Params3.ModelSpinDiffusion =1;

tempSavDir = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\Figures\temp\';

imgIdx = 18;


Params.Ra = [];
Params2.Ra = [];
Params3.Ra = [];

tic
R = 50;
T2a = 30e-3;
T1D = 1e-3;
T2b = 10e-6;
M0b = 0.05;
R1b = 1;
QuickParamTest(R,T2a,T1D, T2b,M0b,R1b,Params, Params2, Params3, outputSamplingTable, outputSamplingTable2, outputSamplingTable3, gm_m, fft_gm_m,mat_ss,b1_1,b1_2,b1_3)
saveas(gcf,strcat(tempSavDir,'testFit_',num2str(imgIdx),'.png')); imgIdx = imgIdx+1; 

R = 35;
T2a = 30e-3;
T1D = 1e-3;
T2b = 10e-6;
M0b = 0.057;
R1b = 1;
QuickParamTest(R,T2a,T1D, T2b,M0b,R1b,Params, Params2, Params3, outputSamplingTable, outputSamplingTable2, outputSamplingTable3, gm_m, fft_gm_m,mat_ss,b1_1,b1_2,b1_3)
saveas(gcf,strcat(tempSavDir,'testFit_',num2str(imgIdx),'.png')); imgIdx = imgIdx+1; 


R = 25;
T2a = 30e-3;
T1D = 1e-3;
T2b = 10e-6;
M0b = 0.05;
R1b = 1;
QuickParamTest(R,T2a,T1D, T2b,M0b,R1b,Params, Params2, Params3, outputSamplingTable, outputSamplingTable2, outputSamplingTable3, gm_m, fft_gm_m,mat_ss,b1_1,b1_2,b1_3)
saveas(gcf,strcat(tempSavDir,'testFit_',num2str(imgIdx),'.png')); imgIdx = imgIdx+1; 
toc

% From Melany Mclean's Masters

Params.Ra = 0.53;
Params2.Ra = 0.53;
Params3.Ra = 0.53;


R = 11.6;
T2a = 32.3e-3;
T1D = 1e-3;
T2b = 10e-6;
M0b = 0.067;
Params.Ra = 0.53;
R1b = 1;
QuickParamTest(R,T2a,T1D, T2b,M0b,R1b,Params, Params2, Params3, outputSamplingTable, outputSamplingTable2, outputSamplingTable3, gm_m, fft_gm_m,mat_ss,b1_1,b1_2,b1_3)
saveas(gcf,strcat(tempSavDir,'testFit_',num2str(imgIdx),'.png')); imgIdx = imgIdx+1; 


















Params2.PerfectSpoiling = 0;
Params2.GradientSpoiling = 1;
Params2.ModelSpinDiffusion = 1;

R = 15;
T2a = 100e-3;
T1D = 5.25e-3;
T2b = 12e-6;
M0b = 0.05;
R1b = 1;
QuickParamTest_1Prot(R,T2a,T1D, T2b,M0b,R1b,Params2, outputSamplingTable2, gm_m, fft_gm_m,mat_ss(5,:)',b1_2)

R = 35;
T2a = 100e-3;
T1D = 5.25e-3;
T2b = 12e-6;
M0b = 0.05;
R1b = 1;
QuickParamTest_1Prot(R,T2a,T1D, T2b,M0b,R1b,Params2, outputSamplingTable2, gm_m, fft_gm_m,mat_ss(5,:)',b1_2)

R = 50;
T2a = 100e-3;
T1D = 5.25e-3;
T2b = 12e-6;
M0b = 0.05;
R1b = 1;
QuickParamTest_1Prot(R,T2a,T1D, T2b,M0b,R1b,Params2, outputSamplingTable2, gm_m, fft_gm_m,mat_ss(5,:)',b1_2)






Params.Ra = Params.Raobs - ((R * M0b * (R1b - Raobs)) / (R1b - Raobs + R));

























tic % Took 90 hours to run
B1rms = 0:2:18;

R = 50;
T2a = 60e-3;
T1D = 5e-3;
T2b = 11e-6;
M0b = 0.085;
R1b = 1;

% Ssig1 = zeros(Params.TurboFactor,length(B1rms));
% Ssig2 = zeros(Params2.TurboFactor,length(B1rms));
% Ssig3 = zeros(Params3.TurboFactor,length(B1rms));
Dsig1 = zeros(Params.TurboFactor,length(B1rms));
Dsig2 = zeros(Params2.TurboFactor,length(B1rms));
Dsig3 = zeros(Params3.TurboFactor,length(B1rms));

% parfor i = 1:length(B1rms)
%      [Ssig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'single', 'b1', B1rms(i),...
%          'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );           
% end
% parfor i = 1:length(B1rms)
%      [Ssig2(:,i),~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'single', 'b1', B1rms(i),...
%          'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );
% end
% parfor i = 1:length(B1rms)
%      [Ssig3(:,i),~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'single', 'b1', B1rms(i),...
%          'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );
% end

parfor i = 1:length(B1rms)
     [ Dsig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b ); 
end
parfor i = 1:length(B1rms)
     [ Dsig2(:,i),~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );
end

parfor i = 1:length(B1rms)
     [ Dsig3(:,i),~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );  
end
                                                        
toc


%% Then from the excitation train values, determine the realized GM value.

% Single_sig1_gm = zeros( 1, length(B1rms));
% Single_sig2_gm = zeros( 1, length(B1rms));
% Single_sig3_gm = zeros( 1, length(B1rms));
Dual_sig1_gm = zeros( 1, length(B1rms));
Dual_sig2_gm = zeros( 1, length(B1rms));
Dual_sig3_gm = zeros( 1, length(B1rms));

tic
parfor j = 1:length(B1rms)
%     Single_sig1_gm(j) = CR_generate_BSF_scaling_v1( squeeze(Ssig1(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;  
%     Single_sig2_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Ssig2(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m) ;
%     Single_sig3_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Ssig3(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;
    Dual_sig1_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig1(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;
    Dual_sig2_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig2(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m);
    Dual_sig3_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig3(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;  

end
toc


%% Calculate MTsat on the whole matrix of signal values.
T1obs = ones(size(Dual_sig1_gm)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig1_gm)) ;


% MTsat_sim_Single1 = calcMTsatThruLookupTablewithDummyV3( Single_sig1_gm, [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
% MTsat_sim_Single2 = calcMTsatThruLookupTablewithDummyV3( Single_sig2_gm, [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
% MTsat_sim_Single3 = calcMTsatThruLookupTablewithDummyV3( Single_sig3_gm, [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( Dual_sig2_gm,   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( Dual_sig3_gm,   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);


%% Fit the data
fit_degree = 7;
                   
     % With B1's simulated ->Fit polynomial: 
%  Single_c1 = polyfit(B1rms, MTsat_sim_Single1, fit_degree);
%  Single_c2 = polyfit(B1rms, MTsat_sim_Single2, fit_degree);
%  Single_c3 = polyfit(B1rms, MTsat_sim_Single3, fit_degree);
 Dual_c1   = polyfit(B1rms, MTsat_sim_Dual1, fit_degree);
 Dual_c2   = polyfit(B1rms, MTsat_sim_Dual2, fit_degree);
 Dual_c3   = polyfit(B1rms, MTsat_sim_Dual3, fit_degree);
     
     % Try again using this: polyfitweighted, with the B1 as the weight!


%% Calculate Standardized Residuals
% this can take a few minutes of run time.
std_resid_d1 = CR_calc_std_residuals( b1_1, mat_ss(1,:) , Dual_c1);
std_resid_d2 = CR_calc_std_residuals( b1_2, mat_ss(2,:) , Dual_c2);
std_resid_d3 = CR_calc_std_residuals( b1_3, mat_ss(3,:) , Dual_c3);

% std_resid_s1 = CR_calc_std_residuals( b1_1, mat_ss(4,:) , Single_c1);
% std_resid_s2 = CR_calc_std_residuals( b1_2, mat_ss(5,:) , Single_c2);
% std_resid_s3 = CR_calc_std_residuals( b1_3, mat_ss(6,:) , Single_c3);

%standardized_residuals = [std_resid_d1, std_resid_d2, std_resid_d3, std_resid_s1, std_resid_s2, std_resid_s3];
standardized_residuals = [std_resid_d1, std_resid_d2, std_resid_d3];


%%  add the columns
 errorScore = sum( abs(standardized_residuals) , 2 ); % can have negatives, so combine abs of each
 
 % Dual Only
  %errorScore = sum( abs(standardized_residuals(:,1:3)) , 2 ); % can have negatives, so combine abs of each
 %errorScore = sum( abs(standardized_residuals(:,2)) , 2 ); % can have negatives, so combine abs of each
 
 
 % Sort based on this, then store in table :) 
 
% for best protocol, take top 10 most efficient protocols. Then sort by
% absolute ihMT

[~, sortidx] = sort(errorScore, 'ascend');
% Top50sorted = parametersSet ( sortidx(1:end),:);
% Top50Errors = errorScore ( sortidx(1:end),:);
% Top50sortedTable = array2table(Top50sorted, 'VariableNames',{'R', 'T2a', 'T1D', 'T2b', 'M0b','R1b'});

SortIndex = sortidx(1); % select the sorted line you want
x1_line = linspace(0,18,100);
y1 = polyval( Dual_c1(SortIndex,:), x1_line);
y2 = polyval( Dual_c2(SortIndex,:), x1_line);
y3 = polyval( Dual_c3(SortIndex,:), x1_line);



figure;
% subplot(1,2,1)
heatscatter(b1_1', mat_ss(4,:)' ); 
hold on
heatscatter(b1_2', mat_ss(5,:)' ); 
heatscatter(b1_3', mat_ss(6,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
title('Dual');
colorbar off
ax = gca; ax.FontSize = 20; 
hold off
ylim([0 0.3]) ;
set(gcf,'position',[10,400,800,600])    

% 
% y1 = polyval( Single_c1( SortIndex,:), x1_line);
% y2 = polyval( Single_c2( SortIndex,:), x1_line);
% y3 = polyval( Single_c3( SortIndex,:), x1_line);
% 
% subplot(1,2,2)
% heatscatter(b1_1', mat_ss(4,:)' ); 
% hold on
% heatscatter(b1_2', mat_ss(5,:)' ); 
% heatscatter(b1_3', mat_ss(6,:)' ); 
% hold on
% plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
% xlim([0 18]) ; % ylim([0 0.04]) ;
% title('Single')
% ax = gca; ax.FontSize = 20; 
% colorbar off
% hold off                     
%   set(gcf,'position',[10,400,1200,400])    



















































