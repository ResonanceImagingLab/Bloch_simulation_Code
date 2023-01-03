% This script takes an MPRAGE (GE - BRAVO) scan as one input,
% a PD-weighted FLASH scan as a second input,
% and a B1 map as a third input to calculate T1 values
% optional mask input. 

% Main difference in this GE versus the Siemens version:
% RF spoil increment: 117 deg
% ReadoutOrder: centric (BRAVO scan)

% Look towards function [B1, T1, Subnames, missingData] = CR_Pull_GE_R1_matrixNoGains_func(location, b1corr), and CR_generateB1_R1_relationship.m
% for how to incorporate this call with the initial filename loading



% MNIdir = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';
% SavDir = 'C:\Users\crowle1\OneDrive - McGill University\BipolarStudy\BlochSimSpoil\';
% Params.Orientation = 'Sagittal';
% Params.NumLines = 216;
% Params.NumPartitions = 192; 
% Params.Slices = 96; 
% Params.SplitBrain = 1;
% 
% PDw = PD_L(i,:);
% MPRAGE = T1W_L(i,:);


function T1map = MPRAGE_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, MPRAGE, PDw, B1, mask, LUTsavDir, lutPrefix, calcLUT )

% Munsch et al 2021 mentioned a 95% b1 scaling for GE maps, upscale the lookup table to avoid downscaling values
% Not needed for Siemens -> B1_scale = 0.95; 
B1_scale = 1; 


% Report errors if missing data on image structures
checkGEparamObject_MPRAGE(T1wInfo, PDwInfo );


% Extract imaging params.
TI = T1wInfo.TI;
echoSpacing = T1wInfo.echoSpacing;
numExcitation = T1wInfo.numExcitation;
Readout = T1wInfo.Readout;
TR = T1wInfo.TR;
t1TE = T1wInfo.TE;
t1flip = T1wInfo.flipAngle;
pdTR = PDwInfo.TR;
pdflip = PDwInfo.flipAngle;
pdTE = PDwInfo.TE;

% Build LUT filename string:

LUT_str = strcat(lutPrefix, Readout, '_TI', num2str(TI), '_TR',num2str(TR), '_flip',num2str(t1flip), ...
        '_echoSp',num2str(echoSpacing), '_turbofact',num2str(numExcitation),'_TE',num2str(t1TE), ...
        '_pdTR',num2str(pdTR), '_pdflip',num2str(pdflip), '_TE',num2str(pdTE) );


% Check if LUT exists for these parameters so that you do not need to recompute them.
if isfile( fullfile(LUTsavDir, strcat(LUT_str,'.mat')))
    LUT = load(fullfile(LUTsavDir, strcat(LUT_str,'.mat')));
    LUT = LUT.LUT;

elseif calcLUT
    
    disp('Creating new lookup table....')
    disp(LUT_str)

    LUT = compute_2pt_inversion_LUT_1pool(T1wInfo, PDwInfo, LUT_str, LUTsavDir, [], []);
else 
    error('Lookup table missing. Check filenames or contact Chris Rowley');

end


%% With the LUT produced, turn the images into vectors then fit to the gridded interpolant

if ~isempty(MPRAGE)

    if isempty(mask)
        mask = ones(size(PDw));
    end
    q = find( (mask(:)>0));
    b1_v = B1_scale * abs(B1(q));
    signal_v = abs(MPRAGE(q)./ PDw(q));
    
    t1_v = LUT(b1_v,  signal_v);
    t1_v(isnan(t1_v)) = 0;
    T1map = zeros( size(PDw));
    T1map(q) = t1_v;
else
    T1map = [];
end
    




