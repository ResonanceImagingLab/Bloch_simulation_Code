function Params = CR_getSeqParams_r3(turbofactor)
% Based on the batch simulations in Batch_sim/3T_r3/
% These give the best SNR for each turbofactor. 


%filled with values from simulation results:
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);

Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echospacing = 7.66/1000;
Params.PerfectSpoiling = 1;

%% MT params
if  turbofactor == 200
    Params.delta = 8000;
    Params.flipAngle = 11; % excitation flip angle water.
    Params.TR = 2.9; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 8;
    Params.TurboFactor = 200;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 162.24; % microTesla
    Params.satTrainPerBoost = 12; % *
    Params.TR_MT = 0.04; % *
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 1;
    Params.ihmtrSNR = 7.1127;
    Params.B1rmsPerSatPulse = 16.8803;
    Params.B1rmsPerSatPeriod = 6.6157;
    Params.B1rmsPerTR = 2.7567;
    Params.DutyCycleSatPeriod = 0.1644;
    Params.DutyCycleTR = 0.0323;

elseif turbofactor == 160
    Params.delta = 8000;
    Params.flipAngle = 11; % excitation flip angle water.
    Params.TR = 2.3; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 6;
    Params.TurboFactor = 160;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 160.2498; % microTesla
    Params.satTrainPerBoost = 13;
    Params.TR_MT = 0.04;    
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 1;
    Params.ihmtrSNR = 5.8694;
    Params.B1rmsPerSatPulse = 16.6730;
    Params.B1rmsPerSatPeriod = 5.659;
    Params.B1rmsPerTR = 2.7566;
    Params.DutyCycleSatPeriod = 0.1232;
    Params.DutyCycleTR =  0.0330;

elseif turbofactor == 120
    Params.delta = 8000;
    Params.flipAngle = 11; % excitation flip angle water.
    Params.TR = 1.75; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 6;
    Params.TurboFactor = 120;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 159.417; % microTesla
    Params.satTrainPerBoost = 10;
    Params.TR_MT = 0.04;
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 1;
    Params.ihmtrSNR = 4.5771; 
    Params.B1rmsPerSatPulse = 16.5864;
    Params.B1rmsPerSatPeriod = 5.6296;
    Params.B1rmsPerTR = 2.7563;
    Params.DutyCycleSatPeriod = 0.1258;
    Params.DutyCycleTR = 0.0332;

elseif turbofactor == 90
    Params.delta = 8000;
    Params.flipAngle = 8; % excitation flip angle water.
    Params.TR = 1.25; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 6;
    Params.TurboFactor = 90;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 162.7743; % microTesla
    Params.satTrainPerBoost = 7;
    Params.TR_MT = 0.04;
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 1;
    Params.ihmtrSNR = 3.3312;
    Params.B1rmsPerSatPulse = 16.9357;
    Params.B1rmsPerSatPeriod = 5.7482;
    Params.B1rmsPerTR = 2.7563;
    Params.DutyCycleSatPeriod = 0.1309;
    Params.DutyCycleTR = 0.0330;

elseif turbofactor == 80
    Params.delta = 8000;
    Params.flipAngle = 9; % excitation flip angle water.
    Params.TR = 1.25; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 6;
    Params.TurboFactor = 80;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 162.494; % microTesla
    Params.satTrainPerBoost = 7;
    Params.TR_MT = 0.04;
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 1;
    Params.ihmtrSNR = 3.6052;
    Params.B1rmsPerSatPulse = 16.9065;
    Params.B1rmsPerSatPeriod = 5.7383;
    Params.B1rmsPerTR = 2.7562;
    Params.DutyCycleSatPeriod = 0.1309;
    Params.DutyCycleTR = 0.0322;

elseif turbofactor == 48
    Params.delta = 8000;
    Params.flipAngle = 7; % excitation flip angle water.
    Params.TR = 0.75; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 4;
    Params.TurboFactor = 48;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 163.0962; % microTesla
    Params.satTrainPerBoost = 6;
    Params.TR_MT = 0.04;
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 1;
    Params.ihmtrSNR = 2.7914;
    Params.B1rmsPerSatPulse = 16.9682;
    Params.B1rmsPerSatPeriod = 4.7026;
    Params.B1rmsPerTR = 2.6852;
    Params.DutyCycleSatPeriod = 0.0902;
    Params.DutyCycleTR =  0.0310;
    
elseif turbofactor == 10
    Params.delta = 8000;
    Params.flipAngle = 5; % excitation flip angle water.
    Params.TR = 0.140; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 6;
    Params.TurboFactor = 10;
    Params.pulseDur = 0.768/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 145.1782; % degrees
    Params.satTrainPerBoost = 0;
    Params.TR_MT = 0; 
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 2;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 0;
    Params.ihmtrSNR = 1.93;
    Params.B1rmsPerSatPulse = 15.1;
    Params.B1rmsPerSatPeriod = 12.52;
    Params.B1rmsPerTR = 2.75;
    Params.DutyCycleSatPeriod = 0.7191;
    Params.DutyCycleTR = 0.0401;
else
    error('turbofactor input was not one of the options')

end 

% MT parameters that will be consistent:
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.
Params.TD_MT =  Params.TR_MT - Params.numSatPulse* (Params.pulseDur + Params.pulseGapDur) ;   


Params = CalcVariableImagingParams(Params);



% 
% 
% %% Pull parameters using:
% tempS = simResults;
% tempP = convParam;
% 
% TF2 =  tempP(:,6) ~= 10; 
% tempS(TF2,:) = [];
% tempP(TF2,:) = [];
% 
% 
% [temp, top10Effidx] = sort(tempS(:,11), 'descend'); % sort by ihMTsat SNR efficiency
% Top10sorted_b = tempP ( top10Effidx,:);
% Top10sorted_b = array2table(Top10sortedSat_b, 'VariableNames',{'delta', 'flipAngle', ...
%     'TR', 'numSatPulse', 'pulseDur', 'numExc', 'satTrainPerBoost', 'TR_MT',...
%     'SatPulse_FlipAngle','DutyCycle_sat', 'DutyCycle_TR', 'B1rms_1sat_pulse', ...
%     'B1rms full sat block', 'B1rms whole TR'});
% 
% 
% snr_t = temp(1)






























