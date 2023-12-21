function Params = CR_getSeqParams_Descoteaux(Params)

%filled with values from simulation results:
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);

Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echospacing = 7.66/1000;
Params.PerfectSpoiling = 1;


    Params.delta = 7000;
    Params.flipAngle = 15; % excitation flip angle water.
    Params.TR = 0.112; % total repetition time = MT pulse train and readout.
    Params.numSatPulse = 10;
    Params.TurboFactor = 1;
    Params.pulseDur = 0.9/1000; %duration of 1 MT pulse in seconds
    Params.satFlipAngle = 90; % degrees
    Params.satTrainPerBoost = 1;
    Params.TR_MT = 0; 
    Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
    Params.pulseGapDur = 0.6/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
    Params.DummyEcho = 0;
    Params.numExcitation = Params.TurboFactor + Params.DummyEcho; % number of readout lines/TR
    Params.boosted = 0;
    Params.satTrainPerBoost = 1; 
    Params.TR_MT = 0; 


% MT parameters that will be consistent:
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.
Params.TD_MT =  Params.TR_MT - Params.numSatPulse* (Params.pulseDur + Params.pulseGapDur) ;   
Params = CalcVariableImagingParams(Params);




























