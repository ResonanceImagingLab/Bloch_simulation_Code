function [T1wInfo, PDwInfo] = defaultSiemensParamObject(Params, location)
% We aren't using header info here, so we will just set all the location
% info here.

% Note that the PDW image uses the TFL sequence, but I have converted the
% parameters so TR = echospacing, and turbofactor = 1; real parameters
% commented out

% Vendor specific spoiling value
Params.RFspoilingPhaseInc = 50;

if location == 4

    Params.GradientSpoilingStrength = 22; % mT/m
    Params.IncreasedGradSpoil = false; % binary
    Params.G_t = 1.8e-3; % RUP = 0.170, 1.6069 flat, RDT = 0.22 (RUP/2 +flat +RDT/2)

elseif location == 5

    % the other options are already set as default (based on Prisma)
    Params.IncreasedGradSpoil = true; % binary
end



%% Standard Siemens parameters:
Params = CalcImagingParams(Params);

if ~isfield(Params,'WExcDur') % if not defined,assume spoiling in readout
    Params.WExcDur = 0.1/1000;  %in seconds
end





%% T1w images
% Lines = 240/2+32
% Partitions = 240
T1wInfo                = Params; % copy over parameters
T1wInfo.ellipMask      = 0;
T1wInfo.Readout        = 'linear';
T1wInfo.Orientation    = 'Sagittal';
T1wInfo.Grappa         = true;
T1wInfo.ReferenceLines = 32;
T1wInfo.NumLines       = 240;
T1wInfo.NumPartitions  = 176;
T1wInfo.Slices         = 256;
T1wInfo.TurboFactor    = 176;
T1wInfo.DummyEcho      = 0;
T1wInfo.numExcitation  = T1wInfo.TurboFactor;
T1wInfo.AccelerationFactor = 2;
T1wInfo.SplitBrain     = 0;

T1wInfo.InvPulseDur    = 10.24e-3; % seconds - long adiabatic
T1wInfo.InversionEfficiency = 0.96; % percentage

%% PDw images -> Flash image, ignore TI value
% Lines = 240/2+32
% Partitions = 240
PDwInfo                 = Params; % copy over parameters
PDwInfo.ellipMask       = 0;
PDwInfo.Readout         = 'linear';
PDwInfo.Orientation     = 'Sagittal';
PDwInfo.Grappa          = true;
PDwInfo.ReferenceLines  = 32;
PDwInfo.NumLines        = 240;
PDwInfo.NumPartitions   = 176;
PDwInfo.Slices          = 256;
%PDwInfo.TurboFactor     = 176;
PDwInfo.TurboFactor     = 1;
PDwInfo.DummyEcho       = 0;
PDwInfo.numExcitation   = PDwInfo.TurboFactor;
PDwInfo.AccelerationFactor = 2;
PDwInfo.SplitBrain      = 0;




%% Image acquisition info, if not pulled from header

T1wInfo.flipAngle    = 12 ;
T1wInfo.TI           = 1100e-3; % in seconds                                                 
T1wInfo.TR           = 3650e-3; % in seconds

PDwInfo.flipAngle    = 4;
PDwInfo.TE           = 2.01e-3;

if location == 4

    T1wInfo.TE          = 2.01e-3;
    T1wInfo.echoSpacing = 6.08e-3;
    T1wInfo.TD          = 2.0156; % in seconds
    %PDwInfo.TR          = 1090e-3;
    PDwInfo.echoSpacing  = 6.0812e-3;
    PDwInfo.TR =   PDwInfo.echoSpacing;

elseif location == 5

    T1wInfo.TE          = 2.96e-3;
    T1wInfo.echoSpacing = 8.1e-3;
    T1wInfo.TD          = 1.8372; % in seconds
    % PDwInfo.TR          = 1270e-3;
    PDwInfo.echoSpacing = 7.2e-3;
    PDwInfo.TR =   PDwInfo.echoSpacing;

end





% TD calculated as below for linear encoded
% TD = T1wInfo.TR - T1wInfo.TI - 176/2*T1wInfo.echoSpacing





















