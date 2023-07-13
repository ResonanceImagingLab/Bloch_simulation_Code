%% Generate the M0B mapping to R1 from simulation results and acquired data

addpath(genpath('Directory/niak-master' ))
addpath(genpath('Directory/NeuroImagingMatlab'))
addpath(genpath( 'Directory/MP2RAGE'   ))

OutputDir =  'E:\GitHub\Bloch_simulation_Code\b1Correction\MarmosetGRE\Outputs';

%% Load images:


DATADIR = 'Image/Directory';

%image names:
% in the order of dual, hfa, neg, lfa, pos
fn = {'/mni_gre_MTw_helms2k_0_3mm_sFOV_s007.nii' '/mni_gre_MTw_helms2k_0_3mm_sFOV_s023.nii' ...
    '/mni_gre_MTw_helms2k_0_3mm_sFOV_s029.nii' '/mni_gre_PDw_helms2k_0_3mm_sFOV_s009.nii'...
    '/mni_gre_PDw_helms2k_0_3mm_sFOV_s025.nii' '/mni_gre_PDw_helms2k_0_3mm_sFOV_s031.nii'...
    '/mni_gre_T1w_helms2k_0_3mm_sFOV_s005.nii' '/mni_gre_T1w_helms2k_0_3mm_sFOV_s021.nii'...
    '/mni_gre_T1w_helms2k_0_3mm_sFOV_s027.nii'};
                                          

for i = 1:3
    fn = fullfile(DATADIR,mtw_fn{i});
    [hdr, img] = niak_read_vol(fn);
    comb_mtw(:,:,:,i) = img; %.img;
end

mask = zeros(128,224,224);
mask (comb_mtw(:,:,:,1) >110) = 1;


%% Run MP-PCA denoising
comb_mtw = double(comb_mtw);
all_PCAcorr = MPdenoising(comb_mtw);


%% separate the images then average the MTw ones
merge_mtw = mean(all_PCAcorr(:,:,:,1:3));
merge_pdw = mean(all_PCAcorr(:,:,:,4:6));
merge_t1w = mean(all_PCAcorr(:,:,:,7:9));

% tmp = zeros(128,2,224,12);
% merge_t1w = cat(2,tmp,merge_t1w); % for some reason matrix is slightly smaller


% tic
% final_t1w_ur= unring3D(final_t1w,3);
% final_mtw_ur= unring3D(final_mtw,3);
% final_pdw_ur = unring3D(final_pdw,3);
% toc


%% Some B1 issues so lets try and load that

[hdr, b1s] = niak_read_minc2(strcat(DATADIR,'/fieldmaps/resampled_s_b1field.mnc')); % sag
[~, b1c] = niak_read_minc2(strcat(DATADIR,'/fieldmaps/resampled_c_b1field.mnc')); % cor
[~, b1t] = niak_read_minc2(strcat(DATADIR,'/fieldmaps/resampled_t_b1field.mnc')); % trans
comb_b1= cat(4,b1s,b1c,b1t);

b1 = median(comb_b1,4);

b1cp = b1;
b1cp( :,:,end-19:end) = []; % for some reason its the wrong size
tmp = zeros(128,2,224);
b1cp = cat(2,tmp,b1cp);
% final_t1w2 = cat(2,tmp,final_t1w); %for some reason this one is off too. 
% figure; imshow3Dfullseg(final_t1w2,[100 600],mask)

b1 = b1cp;

b1(b1<0.2) = 0;
b1(b1>1.8) = 0;


[~, b1] = niak_read_vol(fullfile(DATADIR,'resampled_b1field.mnc')); 
b1 = double(b1);
b1 = limitHandler(b1, 0.5,1.4);
b1 = CR_imgaussfilt3_withMask(b1, mask, 5); %light smoothing to the map

figure; imshow3Dfull(b1, [0.6 1.2],jet)


%% Compute MTsat 
a1 = 5*pi/180 .* b1;
a2 = 20*pi/180 .* b1; 
TR_mt = 30; %ms ->
TR_t1 = 21;

R1 = 0.5 .* (final_t1w_ur.*a2./ TR_t1 - final_pdw_ur.*a1./TR_mt) ./ (final_pdw_ur./(a1) - final_t1w_ur./(a2));
R1 = R1.*mask;
T1 = 1/R1;

App = final_pdw_ur .* final_t1w_ur .* (TR_mt .* a2./a1 - TR_t1.* a1./a2) ./ (final_t1w_ur.* TR_mt .*a2 - final_pdw_ur.* TR_t1 .*a1);
App = App .* mask;

figure; imshow3Dfull(T1 , [600 2500], jet);
figure; imshow3Dfull(App , [0 15000], gray);

%% Protocol 1
% enter all time units in milliseconds
echoSpacing = 0.1; % The echo spacing of the GRE readout
numExcitation = 1; 
TR = 30;
flipA = 5; % flip angle
DummyEcho = 0;

MTsat = calcMTsatThruLookupTablewithDummyV3( merge_mtw, b1, T1, mask, Aapp,...
    echoSpacing, numExcitation, TR, flipA, DummyEcho);

figure; imshow3Dfull(MTsat , [0 0.02], jet);


%% With MTsat maps made, perform M0b mapping


% load in the fit results for VFA - Optimal
fitValues = load(fullfile(OutputDir,'fitValues_Marm.mat'));
fitValues = fitValues.fitValues;

% need to convert to 1/s from 1/ms .
R1_s = R1;

% initialize matrices
M0b = zeros(size(merge_mtw));


%% SPEED IT UP BY DOING A FEW AXIAL SLICES
axialStart = 126; % 65
axialStop = axialStart+3;%115;
% check
 figure; imshow3Dfull(merge_mtw(:,axialStart:axialStop,:) , [0 0.06], jet)

satFlipAngle = 639.6; % in degrees

tic %  
for i = 1:size(merge_mtw,1) % went to 149
    
    for j = axialStart:axialStop % 1:size(sat_dual,2) % for axial slices
        for k =  1:size(merge_mtw,3) % sagital slices  65
            
            if mask(i,j,k) > 0 
                                 
                 [M0b(i,j,k), ~,  ~]  = CR_fit_M0b_v2( satFlipAngle*b1(i,j,k), R1_s(i,j,k), merge_mtw(i,j,k), fitValues);
                 
            end
        end
    end
    disp(i)
end
toc %% this took 30hours for 1mm isotropic full brain dataset. * was running fitting in another matlab
    % instance, so could be easily sped up running on its own and/or adding
    % the parfor loop. 

figure; imshow3Dfull(M0b, [0 0.15],jet)


% export
mkdir(fullfile(OutputDir,'processing'))
hdr.file_name = fullfile(OutputDir,'processing/M0b.mnc.gz'); niak_write_vol(hdr,M0b);


%% With M0B maps made, correlate with R1 and update the fitValues file. 

% use this fake mask to get rid of dura. 
tempMask = mask;
tempMask = imerode(tempMask, strel('sphere',2));
figure; imshow3Dfullseg(M0b, [0 0.15],tempMask)

% Optimized Approach
fitValues  = CR_generate_R1vsM0B_correlation( R1_s, M0b, tempMask, fitValues, fullfile(OutputDir,'processing/R1vsM0b_Marm.png'), fullfile(OutputDir,'fitValues.mat'));



%% Now use these results to B1 correct the data:
OutputDir = DATADIR;

satFlipAngle = 639.6; % in degrees
corr_factor = MTsat_B1corr_factor_map(b1, R1_s, satFlipAngle, fitValues);


% Part 2, apply correction map
merge_mtw_c = (merge_mtw + merge_mtw.* corr_factor) .* mask;
merge_mtw_c = limitHandler(merge_mtw_c,0, 0.1);



%% View results
figure; imshow3Dfull(merge_mtw_c , [0 0.06], jet); 


%% Other things, save if you want
hdr.file_name = strcat(DATADIR,'matlab/MTsat_marm.mnc.gz'); niak_write_vol(hdr, merge_mtw_c);
hdr.file_name = strcat(DATADIR,'matlab/b1_highres.mnc.gz'); niak_write_vol(hdr, b1);




















