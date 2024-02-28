%% Parameter search

% Load matrices
DD = 'batchOutput2'; % Directory with the results

load( fullfile(DD, 'ParameterSet_7T_batch_boost.mat'));
load( fullfile(DD, 'Boost_SN_Signal.mat'));
load( fullfile(DD, 'Boost_satFlipAngle_val.mat'));
load( fullfile(DD, 'Boost_LC_Signal.mat'));
load( fullfile(DD, 'Boost_CSF_Signal.mat'));
load( fullfile(DD, 'Boost_BS_Signal.mat'));

Params.B0 = 7; 
ParamBrainStem = Params;
ParamSN = Params;
ParamLC = Params;
ParamCSF = Params;


ParamBrainStem.TissueType = 'brainStemWM';
ParamBrainStem = DefaultTissueParams(ParamBrainStem);

ParamSN.TissueType = 'substantiaNigra';
ParamSN = DefaultTissueParams(ParamSN);

ParamLC.TissueType = 'locusCoeruleus';
ParamLC = DefaultTissueParams(ParamLC);

ParamCSF.TissueType = 'CSF';
ParamCSF = DefaultTissueParams(ParamCSF);

%% Clean up data:
% convert signal vectors to single values - for centric encoding
% assume 90% first value, 10% second - simplistic

sbs = 0.9*BSsig(:,1) + 0.1*BSsig(:,2); 
ssn = 0.9*SNsig(:,1) + 0.1*SNsig(:,2); 
slc = 0.9*LCsig(:,1) + 0.1*LCsig(:,2); 
scsf = 0.9*CSFsig(:,1) + 0.1*CSFsig(:,2); 


% Remove the 0 values
sbs(satFlipAngle_val <  10) = []; 
ssn(satFlipAngle_val <  10) = []; 
slc(satFlipAngle_val <  10) = []; 
scsf(satFlipAngle_val <  10) = []; 
ParameterSet(satFlipAngle_val <  10,:) = []; 
satFlipAngle_val(satFlipAngle_val <  10) = []; 


%% We are concerned with contrast
% mainly SN vs bs, LC vs BS, LC vs CSF
% Incorporate proton density and T2* weighting now
noise = 0.001;
cnr_bs_sn = abs(ParamBrainStem.PD/100*sbs - ParamSN.PD/100*ssn)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sbs - ParamLC.PD/100*slc)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*scsf - ParamLC.PD/100*slc)./noise;



%% Sort each
[cnr1_sort, cnr1_idx] = sort(cnr_bs_sn,'descend');
[cnr2_sort, cnr2_idx] = sort(cnr_bs_lc,'descend');
[cnr3_sort, cnr3_idx] = sort(cnr_csf_lc,'descend');




%%  Lets take root mean square to weight to the best combined CNR
% Weight the LC contrast with WM higher (*2)
cnr_rms = sqrt(cnr_bs_sn.^2 + 2*cnr_bs_lc.^2 + cnr_csf_lc.^2);
[cnr4_sort, cnr4_idx] = sort(cnr_rms,'descend');


% pull the best rms protocols:
BestProt = [ParameterSet(cnr4_idx,:), satFlipAngle_val(cnr4_idx,:), ...
    cnr_bs_sn(cnr4_idx), cnr_bs_lc(cnr4_idx), cnr_csf_lc(cnr4_idx),...
    sbs(cnr4_idx), ssn(cnr4_idx), slc(cnr4_idx), scsf(cnr4_idx)];


BestProt = array2table(BestProt, 'VariableNames',{'delta', 'flipAngle', ...
    'TR', 'numSatPulse', 'pulseDur', 'numExc', 'satTrainPerBoost', 'TR_MT',...
    'satFlipAngle', 'CNR_WM_SN', 'CNR_WM_LC', 'CNR_LC_CSF',...
    'WMsig', 'SNsig', 'LCsig', 'CSFsig'});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% We want to Sort out values:

%% To sort by excitation flip angle:
FA = 8;

temp = [ParameterSet(cnr4_idx,:), satFlipAngle_val(cnr4_idx,:), ...
    cnr_bs_sn(cnr4_idx), cnr_bs_lc(cnr4_idx), cnr_csf_lc(cnr4_idx)  ];
temp(temp(:,2) > FA, :)= [];

tempProt = array2table(temp, 'VariableNames',{'delta', 'flipAngle', ...
    'TR', 'numSatPulse', 'pulseDur', 'numExc', 'satTrainPerBoost', 'TR_MT',...
    'satFlipAngle', 'CNR_WM_SN', 'CNR_WM_LC', 'CNR_LC_CSF'});

%% OR to sort by TR (note it is in seconds):
TR = 1.0;

temp = [ParameterSet(cnr4_idx,:), satFlipAngle_val(cnr4_idx,:), ...
    cnr_bs_sn(cnr4_idx), cnr_bs_lc(cnr4_idx), cnr_csf_lc(cnr4_idx)  ];
temp(temp(:,3) > TR, :)= [];

tempProt = array2table(temp, 'VariableNames',{'delta', 'flipAngle', ...
    'TR', 'numSatPulse', 'pulseDur', 'numExc', 'satTrainPerBoost', 'TR_MT',...
    'satFlipAngle', 'CNR_WM_SN', 'CNR_WM_LC', 'CNR_LC_CSF'});

























