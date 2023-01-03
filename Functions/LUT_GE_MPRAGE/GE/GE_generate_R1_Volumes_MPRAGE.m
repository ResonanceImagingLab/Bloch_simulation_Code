%% GE_generate_R1_Volumes_MPRAGE
% base script to show how to use this code to generate T1 maps from 2-point
% inversion recovery data. 

% The imaging parameters are as outlines in defaultGEparamObject_MPRAGE.m

addpath(genpath('this/folder'))

%% Generate R1 maps for GE with DICOM header info
% Expects image files in path is DATA_DIR/Subject/processed/space/ ->
% Subject and Space are variables that change.

% Currently it exports R1maps to the input directory.

%% Initialize Variables
% Location of the Dicom Header script
LUTsavDir = 'this/folder/LUT_files/'; 

% Location of data
DATA_DIR='/home/bockn/Data/NSERC/';
Subject = 'Sub0001';


% In order of T1WHC, T1WLC, B1
% If you use the EPI B1 map toggle this:
useEPI_B1map = false;
CONTRASTS = ["T1WHC", "T1WLC", "B1"];


% Loop over both spaces
SPACE=["MNI_152", "MNI_152_nl"];
B1scale = 1;
Params = [];
j = 1;

for j=1:2

    BaseFldr = fullfile(DATA_DIR,Subject, 'processed');

    [T1wInfo, PDwInfo] = defaultGEparamObject_MPRAGE(Params, 0);

    disp(Subject)
   
    %% load the volumes:
    [T1W, PD, B1, size_vol, Hdrinfo] = loadVols_MPRAGE_R1mapping(BaseFldr,...
                                SPACE(j), CONTRASTS, B1scale,useEPI_B1map);

    % T1w images were added, not averaged. So divide by 2.
    T1W = T1W/2;
  
    %% calculate R1
    lutPrefix = 'MAC_MPR_';
    T1 = MPRAGE_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, T1W,...
            PD, B1, [], LUTsavDir,lutPrefix, 0 );

    
    %% Put back into cube and export
    % current export path is DATA_DIR/Subject/space/R1_map.nii
    R1 = cleanAndExportR1maps(T1, size_vol, BaseFldr, SPACE(j), Hdrinfo);
end





% % If you grab the code from here, you can view 3D https://github.com/christopherrowley/NeuroImagingMatlab
% q = 1:length(T1);
% T1_vol = zeros( size_vol);
% T1_vol(q)  = T1;
%  
% figure; imshow3Dfull(T1_vol, [400, 2500], jet)
% 
% 
% B1_vol = zeros( size_vol);
% B1_vol(q)  = B1;
% figure; imshow3Dfull(B1_vol, [0.6, 1.9], jet)

















