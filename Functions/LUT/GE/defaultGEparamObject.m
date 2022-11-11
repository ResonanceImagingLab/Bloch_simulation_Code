function [T1wInfo, PDwInfo] = defaultGEparamObject(Params)

%% Standard GE parameters:
Params = CalcImagingParams(Params);

if ~isfield(Params,'WExcDur') % if not defined,assume spoiling in readout
    Params.WExcDur = 0.1/1000;  %in seconds
end

% GE specific spoiling value
Params.RFspoilingPhaseInc = 117;



%% T1w images
% Lines = 240/2+32
% Partitions = 240
T1wInfo                = Params; % copy over parameters
T1wInfo.ellipMask      = 0;
T1wInfo.Readout        = 'centric';
T1wInfo.Orientation    = 'Sagittal';
T1wInfo.Grappa         = 1;
T1wInfo.ReferenceLines = 32;
T1wInfo.NumLines       = 240;
T1wInfo.NumPartitions  = 96;
T1wInfo.Slices         = 240;
T1wInfo.TurboFactor    = 98;
T1wInfo.DummyEcho      = 0;
T1wInfo.numExcitation  = T1wInfo.TurboFactor;
T1wInfo.AccelerationFactor = 2;
T1wInfo.SplitBrain     = 1;

T1wInfo.TI             = 1100/1000; % in seconds
T1wInfo.TD             = 1000/1000; % in seconds

T1wInfo.InvPulseDur    = 10.24e-3; % seconds - long adiabatic
T1wInfo.InversionEfficiency = 0.96; % percentage

%% PDw images
% Lines = 240/2+32
% Partitions = 240
PDwInfo                 = Params; % copy over parameters
PDwInfo.ellipMask       = 0;
PDwInfo.Readout         = 'linear';
PDwInfo.Orientation     = 'Sagittal';
PDwInfo.Grappa          = 1;
PDwInfo.ReferenceLines  = 32;
PDwInfo.NumLines        = 240;
PDwInfo.NumPartitions   = 180;
PDwInfo.Slices          = 240;
PDwInfo.TurboFactor     = 1;
PDwInfo.DummyEcho       = 0;
PDwInfo.numExcitation   = PDwInfo.TurboFactor;
PDwInfo.AccelerationFactor = 2;
PDwInfo.SplitBrain      = 0;
PDwInfo.echoSpacing     = 0;









