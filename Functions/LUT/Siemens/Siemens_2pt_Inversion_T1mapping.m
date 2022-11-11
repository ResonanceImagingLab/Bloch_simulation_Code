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


function T1map = Siemens_2pt_Inversion_T1mapping(T1wInfo, PDwInfo, MPRAGE, PDw, B1, mask, LUTsavDir, MNIdir, MNISavDir )

% Munsch et al 2021 mentioned a 95% b1 scaling for GE maps, upscale the lookup table to avoid downscaling values
% Not needed for Siemens -> B1_scale = 0.95; 
B1_scale = 1; 

if isempty(mask)
    mask = ones(size(PDw));
end


% Report errors if missing data on image structures
checkSiemensParamObject(T1wInfo, PDwInfo );


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

LUT_str = strcat(Readout, '_TI', num2str(TI), '_TR',num2str(TR), '_flip',num2str(t1flip), ...
        '_echoSp',num2str(echoSpacing), '_turbofact',num2str(numExcitation),'_TE',num2str(t1TE), ...
        '_pdTR',num2str(pdTR), '_pdflip',num2str(pdflip), '_TE',num2str(pdTE) );


% Check if LUT exists for these parameters so that you do not need to recompute them.
if isfile( strcat(LUTsavDir,LUT_str,'.mat'))
    LUT = load(strcat(LUTsavDir,LUT_str,'.mat'));
    LUT = LUT.LUT;
else
    
    disp('Creating new lookup table....')
    disp(LUT_str)

    % Need to generate the sampling tables and pull k-space segmentations
    % The below function does the check for files, and makes if they don't
    % exist
    str1 = GenFlexible_MNI_KspaceMatrix( T1wInfo, MNISavDir, MNIdir );
    str2 = GenFlexible_MNI_KspaceMatrix( PDwInfo, MNISavDir, MNIdir );

    T1w_b    = load(strcat(MNISavDir,str1,'/','brain_m.mat'));
    T1w_fftb = load(strcat(MNISavDir,str1,'/','fft_brain_m.mat'));
    PDw_b    = load(strcat(MNISavDir,str2,'/','brain_m.mat'));
    PDw_fftb = load(strcat(MNISavDir,str2,'/','fft_brain_m.mat'));

    LUT = compute_2pt_inversion_LUT(T1wInfo, PDwInfo, T1w_b.brain_m, T1w_fftb.fft_brain_m,...
        PDw_b.brain_m, PDw_fftb.fft_brain_m, LUT_str, LUTsavDir);

end


%% With the LUT produced, turn the images into vectors then fit to the gridded interpolant

q = find( (mask(:)>0));
b1_v = B1_scale * abs(B1(q));
signal_v = abs(MPRAGE(q)./ PDw(q));

t1_v = LUT(b1_v,  signal_v);

T1map = zeros( size(PDw));
T1map(q) = t1_v;
    




