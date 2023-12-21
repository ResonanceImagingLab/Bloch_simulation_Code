%% Generate the M0B mapping to R1 from simulation results and acquired data

addpath(genpath('Directory/niak-master' ))
addpath(genpath('Directory/NeuroImagingMatlab'))
addpath(genpath( 'Directory/MP2RAGE'   ))

OutputDir = 'E:\Github\Bloch_simulation_Code\b1Correction\DescoteauxIHMT/outputs';
%% Load images:


DATADIR = 'H:\Research\b1_correction\sherbrooke';

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


figure; imshow3Dfull( comb_mtw(:,:,:,1), [500000, 5000000], jet)
figure; imshow3Dfull( comb_mtw(:,:,:,2), [500000, 1000000], jet)

%% Load the mask
% fn = fullfile(DATADIR,'itkmask.nii.gz');
% [~, mask] = niak_read_vol(fn);
% mask1 = permute(mask,[2 3 1]); % conversion between minc and nii reorients it


%% Some B1 issues so lets try and load that

b1 = double(comb_mtw(:,:,:,7));
mask1 = zeros(size(b1));
mask1(b1 >0) = 1;
b1 = limitHandler(b1, 0.5,1.4);
b1 = CR_imgaussfilt3_withMask(b1, mask1, 2); %light smoothing to the map

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


%% Now from the VFA:

low_flip_angle = 15;    % flip angle in degrees -> Customize
high_flip_angle = 30;  % flip angle in degrees -> Customize
TR1 = 107;               % low flip angle repetition time of the GRE kernel in milliseconds -> Customize
TR2 = 20;               % high flip angle repetition time of the GRE kernel in milliseconds -> Customize

shft= -0.15;
expt = 1.15;
shft= 0;
expt = 1;
a1 = deg2rad(low_flip_angle) * (b1-shft).^expt; 
a2 = deg2rad(high_flip_angle)* (b1-shft).^expt; 

R1 = 0.5 .* (hfa.*a2./ TR2 - lfa.*a1./TR1) ./ (lfa./(a1) - hfa./(a2));
App = lfa .* hfa .* (TR1 .* a2./a1 - TR2.* a1./a2) ./ (hfa.* TR1 .*a2 - lfa.* TR2 .*a1);

T1 = 1./R1;
T1 = limitHandler(T1, 0, 4000);
figure; imshow3Dfull( T1, [600 2500],jet  )




T1 = 1./R1 .*mask1;
figure; imshow3Dfull( T1, [600 2500],jet)

%% Mask -> bet result touched up in itk, then threshold CSF and some dura

mask = mask1;
mask(T1 > 2500) = 0;
mask(T1 < 650) = 0;
mask(isnan(T1)) = 0;
mask = bwareaopen(mask, 10000,6);
figure; imshow3Dfullseg(T1, [300 2500],mask)


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



%% With MTsat maps made, perform M0b mapping


% load in the fit results for VFA - Optimal
fitValues_S_1 = load(fullfile(OutputDir,'fitValues_S_1.mat'));
fitValues_S_1 = fitValues_S_1.fitValues;
fitValues_D_1 = load(fullfile(OutputDir,'fitValues_D_1.mat'));
fitValues_D_1 = fitValues_D_1.fitValues;



% need to convert to 1/s from 1/ms -> ONLY USE MP2RAGE values, VFA are too
% far off.
R1_s = (1./T1) *1000;

% initialize matrices
M0b_1_dual = zeros(size(sat_dual));
M0b_1_pos = zeros(size(sat_dual));
M0b_1_neg = zeros(size(sat_dual));


%% SPEED IT UP BY DOING A FEW AXIAL SLICES
axialStart = 50; % 65
axialStop = axialStart+50;%115;
% check
 figure; imshow3Dfull(sat_dual( :,:,axialStart:axialStop).*mask( :,:,axialStart:axialStop) , [0 0.06], jet)

tic %  
for i = 1:size(sat_dual,1) % went to 149
    
    for j = 1:size(sat_dual,2) % for axial slices
        for k =  1:size(sat_dual,3) % sagital slices  65
            
            if mask(i,j,k) > 0 %&& dual_s(i,j,k,3) > 0
                
                 
                 [M0b_1_dual(i,j,k), ~,  ~]  = CR_fit_M0b_v2( b1(i,j,k), R1_s(i,j,k), sat_dual(i,j,k), fitValues_D_1);
                 [M0b_1_pos(i,j,k),  ~,  ~]  = CR_fit_M0b_v2( b1(i,j,k), R1_s(i,j,k), sat_pos(i,j,k), fitValues_S_1);               
                 [M0b_1_neg(i,j,k),  ~,  ~]  = CR_fit_M0b_v2( b1(i,j,k), R1_s(i,j,k), sat_neg(i,j,k), fitValues_S_1);
                 
            end
        end
    end
    disp(i)
end
toc %% this took 30hours for 1mm isotropic full brain dataset. * was running fitting in another matlab
    % instance, so could be easily sped up running on its own and/or adding
    % the parfor loop. 


figure; imshow3Dfull(M0b_1_pos, [0 0.15],jet)
figure; imshow3Dfull(M0b_1_dual, [0 0.15],jet)
figure; imshow3Dfull(M0b_1_neg, [0 0.15],jet)


% export
mkdir(fullfile(OutputDir,'processing'))
% hdr.file_name = fullfile(OutputDir,'processing/M0b_1_dual.mnc.gz'); niak_write_vol(hdr,M0b_1_dual);
% hdr.file_name = fullfile(OutputDir,'processing/M0b_1_pos.mnc.gz'); niak_write_vol(hdr,M0b_1_pos);
% hdr.file_name = fullfile(OutputDir,'processing/M0b_1_neg.mnc.gz'); niak_write_vol(hdr,M0b_1_neg);

niftiwrite(M0b_1_dual,fullfile(OutputDir,'processing/M0b_1_dual'),info, 'Compressed',true);
niftiwrite(M0b_1_pos,fullfile(OutputDir,'processing/M0b_1_pos'),info, 'Compressed',true);
niftiwrite(M0b_1_neg,fullfile(OutputDir,'processing/M0b_1_neg'),info, 'Compressed',true);

%% With M0B maps made, correlate with R1 and update the fitValues file. 

% use this fake mask to get rid of dura. 
tempMask = mask;
tempMask = imerode(tempMask, strel('sphere',4));
figure; imshow3Dfullseg(M0b_1_dual, [0 0.15],tempMask)

mkdir(fullfile(OutputDir,'figures'));

fitValues_D_1  = CR_generate_R1vsM0B_correlation( R1_s, M0b_1_dual, tempMask, fitValues_D_1, fullfile(OutputDir,'figures/R1vsM0b_1_dual.png'), fullfile(OutputDir,'fitValues_D_1.mat'));
fitValues_SP_1 = CR_generate_R1vsM0B_correlation( R1_s, M0b_1_pos, tempMask, fitValues_S_1, fullfile(OutputDir,'figures/R1vsM0b_1_pos.png'), fullfile(OutputDir,'fitValues_SP_1.mat'));
fitValues_SN_1 = CR_generate_R1vsM0B_correlation( R1_s, M0b_1_neg, tempMask, fitValues_S_1, fullfile(OutputDir,'figures/R1vsM0b_1_neg.png'), fullfile(OutputDir,'fitValues_SN_1.mat'));

%% Now use these results to B1 correct the data:
% OutputDir = DATADIR;

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

% hdr.file_name = strcat(DATADIR,'matlab/MTsat_dual_1.mnc.gz'); niak_write_vol(hdr, sat_dual1_c);
% hdr.file_name = strcat(DATADIR,'matlab/MTsat_pos_1.mnc.gz'); niak_write_vol(hdr, sat_pos1_c);
% hdr.file_name = strcat(DATADIR,'matlab/MTsat_neg_1.mnc.gz'); niak_write_vol(hdr, sat_neg1_c);
% hdr.file_name = strcat(DATADIR,'matlab/ihMTsat_1.mnc.gz'); niak_write_vol(hdr, ihmt1_c);

niftiwrite(sat_dual1_c,fullfile(OutputDir,'processing/MTsat_dual_1'),info, 'Compressed',true);
niftiwrite(sat_pos1_c,fullfile(OutputDir,'processing/MTsat_pos_1'),info, 'Compressed',true);
niftiwrite(sat_neg1_c,fullfile(OutputDir,'processing/MTsat_neg_1'),info, 'Compressed',true);
niftiwrite(sat_neg1_c,fullfile(OutputDir,'processing/ihMTsat_1'),info, 'Compressed',true);






















