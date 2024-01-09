%% NM protocol batch sim
% Look to loop through some NM boosted protocols

outDir = 'E:\Github\Bloch_simulation_Code\Investigations\Neuromelanin\batchOutput2';
mkdir(outDir)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF MODIFY FOR CUSTOM PATHS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up Param Structure.

Params.B0 = 7;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.numExcitation = 1;
Params.echoSpacing = 10/1000;
Params.PerfectSpoiling = 1;
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

%% Imaging Parameters:
Params.numSatPulse = 1;
Params.pulseDur = 5e-3; %duration of 1 MT pulse in seconds
Params.TR = 35/1000; % total repetition time = MT pulse train and readout.
Params.DummyEcho = 0;
Params.numExcitation = 1 + Params.DummyEcho; % number of readout lines/TR
Params.flipAngle = []; % excitation flip angle water.
Params.delta = 3000;
Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params.pulseGapDur = 0.1/1000; %ms gap between MT pulses in train
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gausshann'; % gausshann
Params.satFlipAngle = 1;
Params.TE = 3.0/1000;

Params.NumLines = 216;
Params.NumPartitions = 192; 
Params.Slices = 176;
Params.Grappa = 1;
Params.ReferenceLines = 32;
Params.AccelerationFactor = 2;
Params.Segments = []; 
Params.TurboFactor = []; %Params.numExcitation- Params.DummyEcho;
Params.ellipMask = 1;

%% Simulation Variable

Offset_freq = 3000; 
flipAngle = 8;
pulseDur = [5, 7]./1000; % in seconds
TR = [850:50:1200 ]./1000; % in seconds
numSatPulse = 4:2:10;
numExc = [ 60:4:80];
Params.boosted = 1; % 
satTrainPerBoost = 2:14; % total number of pulses per TR = numSatPul *SatTrainPerBoost
TR_MT = [40, 60,70, 80, 90, 100]./1000; % repetition time of satpulse train in seconds



c1 = length(Offset_freq);
c2 = length(flipAngle);
c3 = length(TR);
c4 = length(numSatPulse);
c5 = length(pulseDur);
c6 = length(numExc);
c7 = length(satTrainPerBoost);
c8 = length(TR_MT);

simLength = c1*c2*c3*c4*c5*c6*c7*c8;

%% First make parameter set variable that stores sequence options.
ParameterSet = zeros(simLength,8);
idx = 1;

% cutoff time
imgTime = 6*60; 
refVal = imgTime/((Params.NumLines/Params.AccelerationFactor+Params.ReferenceLines) * Params.NumPartitions *0.7) ; 

for a = 1:c1
    for b = 1:c2
        for c = 1:c3
            for d = 1:c4
                for e = 1:c5
                    for f = 1:c6
                        for g = 1:c7
                            for h = 1:c8

                                if numExc(f) == 1
                                   DummyEcho = 0;
                                elseif numExc(f) < 4
                                    DummyEcho = 1;
                                else 
                                    DummyEcho = 2;
                                end

                                
                                chkTime = TR_MT(h)*satTrainPerBoost(g) - ... % add sat time X repetitions
                                          (TR_MT(h) - numSatPulse(d)* (pulseDur(e)+Params.pulseGapDur) ) + ... % put back in TD_MT after last sat train
                                          (DummyEcho+numExc(f))*Params.echoSpacing + Params.G_time_elapse_MT; % add excitation time and spoiler gradient
                                
                                if (TR(c)/numExc(f) < refVal) && (chkTime < TR(c)) % then parameters will fit within scan time
                                    ParameterSet(idx,:) = [Offset_freq(a),...
                                        flipAngle(b), TR(c), numSatPulse(d),...
                                        pulseDur(e), numExc(f), satTrainPerBoost(g),...
                                        TR_MT(h) ]; 
        
                                    idx = idx+1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

ParameterSet(idx:end,:) = [];
simLength = idx-1;

save( strcat(outDir,'/ParameterSet_7T_batch_boost.mat'),'ParameterSet')

clearvars -except Params outDir ParameterSet numExc simLength

%%%%%%%%%%%%%%%%%%%%%%%%%%%% SECTION SHOULD BE CORRECT %%%%%%%%%%%%%%%%%%%%%%%
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

%% Loop through ParameterSet to get magnetization vector over excitation train

maxExc = max(numExc);

BSsig = zeros(simLength, maxExc);
SNsig = zeros(simLength, maxExc);
LCsig = zeros(simLength, maxExc);
CSFsig = zeros(simLength, maxExc);
satFlipAngle_val = zeros(simLength, 1);


parpool;


% Need to break into chunks to allow for saving.
loopVec = 1:simLength;
numChunk = 5;
st = round(linspace( min(loopVec),max(loopVec), numChunk +1));
ed = st(2:end); % remove start index
ed(1:end-1) = ed(1:end-1)-1; % increment to prevent overlap
st = st(1:end-1); % remove last index


tic
for i = 1:numChunk
    stVal = st(i);
    edVal = ed(i);


    parfor qi = stVal:edVal

        % make calls to BlochSimFlashSequence_v1
        [inputMag, B1_val] = CR_batch_simSequenceFunction(ParamBrainStem, ...
            'delta', ParameterSet(qi,1),...
            'flipAngle', ParameterSet(qi,2),...
            'TR', ParameterSet(qi,3),...
            'numSatPulse', ParameterSet(qi,4),...
            'pulseDur', ParameterSet(qi,5),...
            'numExcitation', ParameterSet(qi,6),...
            'satTrainPerBoost', ParameterSet(qi,7),...
            'TR_MT', ParameterSet(qi,8),...
            'freqPattern','single');

        tV = zeros(1,maxExc);
        tV(1:ParameterSet(qi,6)) = inputMag;
        BSsig(qi,:) = tV;
        satFlipAngle_val(qi) = B1_val;

        [inputMag, ~] = CR_batch_simSequenceFunction(ParamSN, ...
            'delta', ParameterSet(qi,1),...
            'flipAngle', ParameterSet(qi,2),...
            'TR', ParameterSet(qi,3),...
            'numSatPulse', ParameterSet(qi,4),...
            'pulseDur', ParameterSet(qi,5),...
            'numExcitation', ParameterSet(qi,6),...
            'satTrainPerBoost', ParameterSet(qi,7),...
            'TR_MT', ParameterSet(qi,8),...
            'freqPattern','single');

        tV = zeros(1,maxExc);
        tV(1:ParameterSet(qi,6)) = inputMag;
        SNsig(qi,:) = tV;

        [inputMag, ~] = CR_batch_simSequenceFunction(ParamLC, ...
            'delta', ParameterSet(qi,1),...
            'flipAngle', ParameterSet(qi,2),...
            'TR', ParameterSet(qi,3),...
            'numSatPulse', ParameterSet(qi,4),...
            'pulseDur', ParameterSet(qi,5),...
            'numExcitation', ParameterSet(qi,6),...
            'satTrainPerBoost', ParameterSet(qi,7),...
            'TR_MT', ParameterSet(qi,8),...
            'freqPattern','single');

        tV = zeros(1,maxExc);
        tV(1:ParameterSet(qi,6)) = inputMag;
        LCsig(qi,:) = tV;

        [inputMag, ~] = CR_batch_simSequenceFunction(ParamCSF, ...
            'delta', ParameterSet(qi,1),...
            'flipAngle', ParameterSet(qi,2),...
            'TR', ParameterSet(qi,3),...
            'numSatPulse', ParameterSet(qi,4),...
            'pulseDur', ParameterSet(qi,5),...
            'numExcitation', ParameterSet(qi,6),...
            'satTrainPerBoost', ParameterSet(qi,7),...
            'TR_MT', ParameterSet(qi,8),...
            'freqPattern','single');

        tV = zeros(1,maxExc);
        tV(1:ParameterSet(qi,6)) = inputMag;
        CSFsig(qi,:) = tV;
        
    end

    % In the event that things can go wrong, lets periodically save intermediate results
    save( strcat(outDir,'/Boost_BS_Signal_intermed_',num2str(i),'.mat'),'BSsig')
    save( strcat(outDir,'/Boost_SN_Signal_intermed_',num2str(i),'.mat'),'SNsig')
    save( strcat(outDir,'/Boost_LC_Signal_intermed_',num2str(i),'.mat'),'LCsig')
    save( strcat(outDir,'/Boost_CSF_Signal_intermed_',num2str(i),'.mat'),'CSFsig')
    save( strcat(outDir,'/Boost_satFlipAngle_val_intermed_',num2str(i),'.mat'),'satFlipAngle_val')

    disp( i/numChunk *100) % print percent done
    toc

end

toc % DONE SIMULATIONS
 
                           
save( strcat(outDir,'/Boost_BS_Signal.mat'),'BSsig')
save( strcat(outDir,'/Boost_SN_Signal.mat'),'SNsig')
save( strcat(outDir,'/Boost_LC_Signal.mat'),'LCsig')
save( strcat(outDir,'/Boost_CSF_Signal.mat'),'CSFsig')
save( strcat(outDir,'/Boost_satFlipAngle_val.mat'),'satFlipAngle_val')


% Params = ParamSN;
% Params.delta=ParameterSet(qi,1);
% Params.flipAngle=ParameterSet(qi,2);
% Params.TR=ParameterSet(qi,3);
% Params.numSatPulse=ParameterSet(qi,4);
% Params.pulseDur=ParameterSet(qi,5);
% Params.numExcitation=ParameterSet(qi,6);
% Params.satTrainPerBoost=ParameterSet(qi,7);
% Params.TR_MT=ParameterSet(qi,8);
% Params.freqPattern='single';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% convert signal vectors to single values
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
cnr_rms = sqrt(cnr_bs_sn.^2 + cnr_bs_lc.^2 + cnr_csf_lc.^2);
[cnr4_sort, cnr4_idx] = sort(cnr_rms,'descend');

figure; plot(cnr1_idx); hold on; 
plot(cnr2_idx);
plot(cnr3_idx); plot(cnr4_idx); legend


figure; plot(cnr1_sort, 'LineWidth',3); hold on; 
plot(cnr2_sort, 'LineWidth',3);
plot(cnr3_sort, 'LineWidth',3); plot(cnr4_sort, 'LineWidth',3); legend

%% Weight the LC contrast with WM higher (*2)
cnr_rms = sqrt(cnr_bs_sn.^2 + 2*cnr_bs_lc.^2 + cnr_csf_lc.^2);
[cnr4_sort, cnr4_idx] = sort(cnr_rms,'descend');

figure; plot(cnr1_idx); hold on; 
plot(cnr2_idx);
plot(cnr3_idx); plot(cnr4_idx); legend


figure; plot(cnr1_sort, 'LineWidth',3); hold on; 
plot(cnr2_sort, 'LineWidth',3);
plot(cnr3_sort, 'LineWidth',3); plot(cnr4_sort, 'LineWidth',3); legend


% pull the best rms protocols:
BestProt = [ParameterSet(cnr4_idx,:), satFlipAngle_val(cnr4_idx,:), ...
    cnr_bs_sn(cnr4_idx), cnr_bs_lc(cnr4_idx), cnr_csf_lc(cnr4_idx),...
    sbs(cnr4_idx), ssn(cnr4_idx), slc(cnr4_idx), scsf(cnr4_idx)];


BestProt = array2table(BestProt, 'VariableNames',{'delta', 'flipAngle', ...
    'TR', 'numSatPulse', 'pulseDur', 'numExc', 'satTrainPerBoost', 'TR_MT',...
    'satFlipAngle', 'CNR_WM_SN', 'CNR_WM_LC', 'CNR_LC_CSF',...
    'WMsig', 'SNsig', 'LCsig', 'CSFsig'});





sbs = 0.9*BSsig(:,1) + 0.1*BSsig(:,2); 
ssn = 0.9*SNsig(:,1) + 0.1*SNsig(:,2); 
slc = 0.9*LCsig(:,1) + 0.1*LCsig(:,2); 
scsf = 0.9*CSFsig(:,1) + 0.1*CSFsig(:,2); 

















