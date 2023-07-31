%% Generate the M0B mapping to R1 from simulation results and acquired data

%% Download the following: 
% https://github.com/josephdviviano/unring
% https://github.com/christopherrowley/NeuroImagingMatlab
% https://github.com/TardifLab/OptimizeIHMTimaging % Instead of
% Bloch_simulation_Code****
% https://github.com/ulrikls/niak ** this requires minc tools to be
% installed for it to work.

addpath( genpath( '/media/chris/DataHDD/user/code/matlab/niak-master' ));
addpath( genpath( '/media/chris/SSD/GitHub/NeuroImagingMatlab'));
addpath( genpath( '/media/chris/SSD/GitHub/Bloch_simulation_Code'))




%% Load images:

DATADIR = '/media/chris/data8tb/Research/Marmoset/MRI/imaging/longitudinal/20191024_mtsat-qti-smr/nifti';
OutputDir =  '/media/chris/SSD/GitHub/Bloch_simulation_Code/b1Correction/MarmosetGRE/Outputs';


%image names:
% Notes the nifti files are 4D, with each echo time stored in the 4th
% dimension. The minc files are usually separate.
mfn = {'/mni_gre_MTw_helms2k_0_3mm_sFOV_s007.nii' '/mni_gre_MTw_helms2k_0_3mm_sFOV_s023.nii' ...
    '/mni_gre_MTw_helms2k_0_3mm_sFOV_s029.nii' '/mni_gre_PDw_helms2k_0_3mm_sFOV_s009.nii'...
    '/mni_gre_PDw_helms2k_0_3mm_sFOV_s025.nii' '/mni_gre_PDw_helms2k_0_3mm_sFOV_s031.nii'...
    '/mni_gre_T1w_helms2k_0_3mm_sFOV_s005.nii' '/mni_gre_T1w_helms2k_0_3mm_sFOV_s021.nii'...
    '/mni_gre_T1w_helms2k_0_3mm_sFOV_s027.nii'};
                                          
% num contrasts 4
nc = 4;

% With this data, I also had an issue with T1 matrix size:
tmp = zeros(128,2,224,nc);

st = 1; ed = st+ nc-1;
for i = 1:length(mfn)
    
    fn = fullfile( DATADIR, mfn{ i });
    [~, img] = niak_read_vol( fn );
    
    % fix issue with T1w matrix size
    [~,y,~,~] = size(img); 
    if y == 222
        img = cat(2,tmp,img); 
    end
    
    comb_mtw(:, :, :, st:ed) = img; %.img;
    st = ed+1; ed = st+3;
    
end

mask = zeros(128,224,224);
mask (comb_mtw(:,:,:,1) >110) = 1;

figure; imshow3Dfullseg( comb_mtw(:,:,:,1) , [0 550], mask)


%% Run MP-PCA denoising
comb_mtw = double(comb_mtw);
all_PCAcorr = MPdenoising(comb_mtw);


%% separate the images then average the MTw ones
merge_mtw = mean( all_PCAcorr(:,:,:,1:12), 4 );
merge_pdw = mean( all_PCAcorr(:,:,:,13:24), 4 );
merge_t1w = mean( all_PCAcorr(:,:,:,25:36), 4 );

figure; imshow3Dfull( merge_mtw , [0 550], gray)
figure; imshow3Dfull( merge_pdw , [0 550], gray)
figure; imshow3Dfull( merge_t1w , [0 550], gray)

% Optional, sometimes this algorithm crashes matlab
% SAVE PROGRESS BEFORE RUNNING
% tic
%merge_t1w= unring3D(merge_t1w,3);
% merge_mtw= unring3D(merge_mtw,3);
% merge_pdw = unring3D(merge_pdw,3);
% toc


%% Some B1 issues so lets try and load that

[hdr, b1s] = niak_read_vol(strcat(DATADIR,'/fieldmaps/resampled_s_b1field.mnc')); % sag
[~, b1c] = niak_read_vol(strcat(DATADIR,'/fieldmaps/resampled_c_b1field.mnc')); % cor
[~, b1t] = niak_read_vol(strcat(DATADIR,'/fieldmaps/resampled_t_b1field.mnc')); % trans

comb_b1= cat(4,b1s,b1c,b1t);
b1 = median(comb_b1,4);
b1cp = b1;
b1cp( :,:,end-19:end) = []; % for some reason its the wrong size
tmp = zeros(128,2,224);
b1cp = cat(2,tmp,b1cp);
b1 = b1cp; clear b1cp

b1 = double(b1);
b1 = limitHandler(b1, 0.5,1.5);

figure; imshow3Dfull(b1, [0.6 1.2],jet)


%% Compute MTsat 
% used am empirical factor to fix T1 map for b1 inconsistency.

% FLip angles
a1 = 5*pi/180 .* b1.^(2.7/2);
a2 = 20*pi/180 .* b1.^(2.7/2); 
TR_mt = 30; %ms ->
TR_t1 = 21;

R1 = 0.5 .* (merge_t1w.*a2./ TR_t1 - merge_pdw.*a1./TR_mt) ./ (merge_pdw./(a1) - merge_t1w./(a2));
R1 = R1.*mask;
T1 = 1/R1;

App = merge_pdw .* merge_t1w .* (TR_mt .* a2./a1 - TR_t1.* a1./a2) ./ (merge_t1w.* TR_mt .*a2 - merge_pdw.* TR_t1 .*a1);
App = App .* mask;

T1 = limitHandler(T1.*mask, 0,6000);
App = limitHandler( App.*mask, 0, 20000);

figure; imshow3Dfull(T1 , [600 2500], jet);
figure; imshow3Dfull(App , [0 15000], gray);

mkdir(fullfile(OutputDir,'processing'))
hdr.file_name = fullfile(OutputDir,'processing/T1.mnc.gz'); niak_write_vol(hdr,T1);
hdr.file_name = fullfile(OutputDir,'processing/App.mnc.gz'); niak_write_vol(hdr,App);

%% Protocol 1
% enter all time units in milliseconds
echoSpacing = 0.1; % The echo spacing of the GRE readout
numExcitation = 1; 
TR = 30; % milliseconds
flipA = 5; % flip angle degrees
DummyEcho = 0;

MTsat = calcMTsatThruLookupTablewithDummyV3( merge_mtw, b1, T1, mask, App,...
    echoSpacing, numExcitation, TR, flipA, DummyEcho);

figure; imshow3Dfull(MTsat , [0 0.02], jet);

hdr.file_name = fullfile(OutputDir,'processing/MTsat_noB1.mnc.gz'); niak_write_vol(hdr,MTsat);

%% With MTsat maps made, perform M0b mapping

% load in the fit results for VFA - Optimal
fitValues = load(fullfile(OutputDir,'fitValues_Marm.mat'));
fitValues = fitValues.fitValues;

% need to convert to 1/s from 1/ms .
R1_s = double(abs( R1*1000));
App = double(App);


% If it is in the right units, then the scaling of 0 to 2 should work!
figure; imshow3Dfull( R1_s , [0 2], jet); 


%% Now use these results to B1 correct the data:
% OutputDir = DATADIR;

satFlipAngle = 639.6; % in degrees
corr_factor = MTsat_B1corr_factor_map( b1, R1_s, satFlipAngle, fitValues);


% Part 2, apply correction map
MTsat_c = (MTsat + MTsat.* corr_factor) .* mask;
MTsat_c = limitHandler(MTsat_c,0, 0.1); % 0.025



%% View results
figure; imshow3Dfull(MTsat_c , [0 0.02], jet); 


%% Other things, save if you want
hdr.file_name = fullfile(OutputDir,'processing/MTsat_marm.mnc.gz'); niak_write_vol(hdr, MTsat_c);
hdr.file_name = fullfile(OutputDir,'processing/b1_highres.mnc.gz'); niak_write_vol(hdr, b1);




















