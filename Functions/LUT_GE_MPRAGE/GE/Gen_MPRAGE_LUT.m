
addpath(genpath('C:\Users\chris\Documents\GitHub\Bloch_simulation_Code' ))
addpath(genpath('C:\Users\chris\Documents\GitHub\qMRlab' ))
addpath(genpath('C:\Users\chris\Documents\GitHub\NeuroImagingMatlab'))

% Temp script to generate LUTs
LUTsavDirEnd = 'LUT_files';

%% Initialize Variables

lutPrefix = 'MAC_MPR_';

LUTsavDir = ['C:\Users\chris\Documents\GitHub\Bloch_simulation_Code\Functions\LUT_GE_MPRAGE\',LUTsavDirEnd,'\'];

mkdir(LUTsavDir)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now the fun bit!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% imgDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\SampleImageData\Queens\MNI_152\';
% 
% T1w_1 = niftiread( char([imgDir, 'T1WHC.nii'] ) );
% PDw_1 = niftiread( char([imgDir, 'PDW.nii'] ) );
% B1_1 = niftiread( char([imgDir, 'B1.nii'] ) );
% 
% 
% PDw = double(PDw_1(:));
% MPRAGE = double(T1w_1(:));
% B1 = double(B1_1(:));


% Need to run most of the code in Siemens_SubList_makeCalcT1
clear Params T1wInfo PDwInfo

Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'WM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultGEparamObject_MPRAGE(Params);
T1map = MPRAGE_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, [], [], [], [], LUTsavDir, lutPrefix );



%% % In the future use the following to produce the T1map:
%T1map = MPRAGE_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, MPRAGE, PDw, B1, mask, LUTsavDir, lutPrefix);

ratio = t1w./pdw;
ratio(ratio<0) = 0;
ratio(ratio >1.8) = 0;
figure; imagesc(ratio(:,:,160));colormap('gray'); colorbar

figure; imagesc(b1(:,:,160));colormap('gray'); colorbar

scaleFactor = 1;
b1temp = ones(size(ratio))*1.1;

T1map = MPRAGE_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, mpr, pdw, b1temp, [], LUTsavDir, lutPrefix);

figure; imshow3Dfull(T1map);


figure; imshow3Dfull(b1,[0.5 2], jet);

%% Test it:

DataDir = 'C:\Users\chris\Downloads\TravelBrains\Mac\MPRAGE';

imgName = {'T1w_masked.nii', 'T1WLC.nii', 'MPRAGE.nii', 'B1.nii',...
    'B1_EPI.nii', 'ratio.nii'};

for i = 1:length(imgName)
    img(:,:,:,i) = niftiread(fullfile(DataDir,imgName{i}));
end

img = double(img);

%% Load each image and display

t1w = img(:,:,:,1);
pdw = img(:,:,:,2);
mpr = img(:,:,:,3);
b1 = img(:,:,:,4)/150;
b12 = img(:,:,:,5);
ratio = img(:,:,:,6);


mask = zeros(size(mpr));
mask(t1w>175) = 1;


figure; imshow3Dfull(b1,[0.5 2], jet);
figure; imshow3Dfull(b12,[0.5 2], jet);
figure; imshow3Dfull(ratio,[0.5 2], jet);
figure; imshow3Dfull(mpr./pdw,[0.5 2], jet);
figure; imshow3Dfull(t1w./pdw,[0.5 2], jet);


    q = find( (mask(:)>0));
    b1_v = B1_scale * abs(b1temp(q));
    signal_v = abs(t1w(q)./ pdw(q));
    
    t1_v = LUT(b1_v,  signal_v);
    t1_v(isnan(t1_v)) = 0;
    T1map = zeros( size(pdw));
    T1map(q) = t1_v;







