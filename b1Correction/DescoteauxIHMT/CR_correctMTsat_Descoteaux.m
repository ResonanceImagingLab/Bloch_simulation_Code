%% Correct MTsat maps from 3 protocols after running:
%   simSeq_M0B_R1obs_3prot.m  and...
%   CR_R1vsM0B_correlation.m


%% Add functions to path.
setUp_Descoteaux;

% Set up folders:
b1Dir = 'Directory/to/b1Correction/Files';
OutputDir = 'Directory\b1Correction\outputs';
DATADIR = 'H:\Research\b1_correction\sherbrooke';

%% Load images:
%image names:
% in the order of dual, hfa, neg, lfa, pos
mtw_fn = { 'ref_low_flip_angle.nii.gz', ...
    'ref_high_flip_angle.nii.gz', ...  
    'pos_single.nii.gz', ... 
    'neg_single.nii.gz', ...             
    'pos_neg_dual.nii.gz', ...  
    'neg_pos_dual.nii.gz', ...         
    'b1_map.nii.gz', ... 
          };                                            


info = niftiinfo(fullfile(DATADIR,mtw_fn{1}));

for i = 1:size(mtw_fn,2)
    fn = fullfile(DATADIR,mtw_fn{i});
    % info = niftiinfo( fn );
    img = niftiread(fn);
    % Phillips data is scaled
    %img = scl_slope * img + scl_inter
    comb_mtw(:,:,:,i) = img; %.img;
end



%% Load the mask
% fn = fullfile(DATADIR,'../freeSurfer/itkmask.nii.gz');
% [~, mask] = niak_read_vol(fn);
% mask1 = permute(mask,[2 3 1]); % conversion between minc and nii reorients it

%% Some B1 issues so lets try and load that
b1 = double(comb_mtw(:,:,:,7));
mask1 = zeros(size(b1));
mask1(b1 >0) = 1;
b1 = limitHandler(b1, 0.5,1.4);
b1 = CR_imgaussfilt3_withMask(b1, mask1, 2); %light smoothing to the map OPTIONAL

figure; imshow3Dfull(b1, [0.6 1.2],jet)
figure; imshow3Dfull(mask1, [0.6 1.2],jet)

%% Run MP-PCA denoising

comb_mtw = double(comb_mtw(:,:,:,1:6));
all_PCAcorr = MPdenoising(comb_mtw);


%% separate the images then average the MTw ones
lfa = all_PCAcorr(:,:,:,1);
hfa  = all_PCAcorr(:,:,:,2);
pos = all_PCAcorr(:,:,:,3);
neg = all_PCAcorr(:,:,:,4);
dual1 = all_PCAcorr(:,:,:,5);
dual2  = all_PCAcorr(:,:,:,6);

dual = (dual1+dual2)/2;

%% Now from the MP2RAGE:
  
low_flip_angle = 15;    % flip angle in degrees -> Customize
high_flip_angle = 30;  % flip angle in degrees -> Customize
TR1 = 112;               % low flip angle repetition time of the GRE kernel in milliseconds -> Customize
TR2 = 20;               % high flip angle repetition time of the GRE kernel in milliseconds -> Customize

a1 = deg2rad(low_flip_angle) * b1; 
a2 = deg2rad(high_flip_angle)* b1; 

R1 = 0.5 .* (hfa.*a2./ TR2 - lfa.*a1./TR1) ./ (lfa./(a1) - hfa./(a2));
App = lfa .* hfa .* (TR1 .* a2./a1 - TR2.* a1./a2) ./ (hfa.* TR1 .*a2 - lfa.* TR2 .*a1);

T1 = 1./R1 .*mask1;
figure; imshow3Dfull( T1, [600 2500],jet)

niftiwrite(T1,fullfile(OutputDir,'processing/T1'),info, 'Compressed',true);
niftiwrite(App,fullfile(OutputDir,'processing/S0'),info, 'Compressed',true);

%% Mask -> bet result touched up in itk, then threshold CSF and some dura

mask = mask1;
mask(spT1_map > 2500) = 0;
mask(spT1_map < 500) = 0;
mask(isnan(spT1_map)) = 0;
mask = bwareaopen(mask, 10000,6);
figure; imshow3Dfullseg(spT1_map, [300 2500],mask1)


%% Compute MTsat ihMTsat

%% Protocol 1
echoSpacing = 1; % The echo spacing of the GRE readout
numExcitation = 1; 
TR = 112;
flipA = 15; % flip angle
DummyEcho = 0;

sat_dual = calcMTsatThruLookupTablewithDummyV3( dual, b1, T1, mask1,App, echoSpacing, numExcitation, TR, flipA, DummyEcho);
sat_pos  = calcMTsatThruLookupTablewithDummyV3( pos, b1, T1, mask1, App, echoSpacing, numExcitation, TR, flipA, DummyEcho);
sat_neg  = calcMTsatThruLookupTablewithDummyV3( neg, b1, T1, mask1, App, echoSpacing, numExcitation, TR, flipA, DummyEcho);

figure; imshow3Dfull(sat_dual , [0 0.06], jet); 
figure; imshow3Dfull(sat_pos , [0 0.06], jet);  
figure; imshow3Dfull(sat_neg , [0 0.06], jet); 


%% load in the fit results
fitValues_SP_8 = load(fullfile(b1Dir,'fitValues_SP_1.mat'));
fitValues_SP_8 = fitValues_SP_8.fitValues;
fitValues_SN_8 = load(fullfile(b1Dir,'fitValues_SN_1.mat'));
fitValues_SN_8 = fitValues_SN_8.fitValues;
fitValues_D_8 = load(fullfile(b1Dir,'fitValues_D_1.mat'));
fitValues_D_8 = fitValues_D_8.fitValues;

%% Now use these results to B1 correct the data:
OutputDir = DATADIR;

R1_s = (1./T1) *1000; % convert to 1/ms to 1/s
corr_prot1_d = MTsat_B1corr_factor_map(b1, R1_s, 1, fitValues_D_1);
corr_prot1_p = MTsat_B1corr_factor_map(b1, R1_s, 1, fitValues_SP_1);
corr_prot1_n = MTsat_B1corr_factor_map(b1, R1_s, 1, fitValues_SN_1);

% Part 2, apply correction map
sat_dual1_c = (sat_dual + sat_dual.* corr_prot1_d) .* mask1;
sat_pos1_c  = (sat_pos + sat_pos.* corr_prot1_p) .* mask1;
sat_neg1_c  = (sat_neg + sat_neg.* corr_prot1_n) .* mask1;
ihmt1_c      = sat_dual1_c - (sat_pos1_c + sat_neg1_c)/2;

ihmt1_c = double(limitHandler(ihmt1_c,0, 0.05));
ihmt1_c( ihmt1_c >= 0.05) = 0;


%% View results
figure; imshow3Dfull(sat_dual1_c , [0 0.06], jet); 
figure; imshow3Dfull(sat_pos1_c , [0 0.045], jet)
figure; imshow3Dfull(sat_neg1_c , [0 0.045], jet); 
figure; imshow3Dfull(ihmt1_c , [0 0.01], gray)


%% Other things, save if you want

niftiwrite(sat_dual1_c,fullfile(OutputDir,'processing/MTsat_dual_1'),info, 'Compressed',true);
niftiwrite(sat_pos1_c,fullfile(OutputDir,'processing/MTsat_pos_1'),info, 'Compressed',true);
niftiwrite(sat_neg1_c,fullfile(OutputDir,'processing/MTsat_neg_1'),info, 'Compressed',true);
niftiwrite(sat_neg1_c,fullfile(OutputDir,'processing/ihMTsat_1'),info, 'Compressed',true);







































            