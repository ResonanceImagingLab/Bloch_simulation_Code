% Temp script to generate LUTs
LUTsavDirEnd = 'LUT_files_t2_80ms';

%% Initialize Variables
% Location of the Dicom Header script
if location == 1
    %SITE = 'McMaster';
    error('Make call to GE script instead of the Siemens script')
elseif location == 2
    %SITE = 'Dal';
    error('Make call to GE script instead of the Siemens script')
    elseif location == 3
    %SITE = 'Calgary';
    error('Make call to GE script instead of the Siemens script')
elseif location == 4
    SITE = 'Queens';
elseif location == 5
    SITE = 'UHN';
end


% load the excel sheet with sbuject name conversions
if isunix
    filePath  = '/media/chris/SSD/';
    headerDir = '/media/chris/SSD/Research/Bipolar/Longitudinal_ICM_BD/BipolarMatlab/dicomHeaderReader/';
    
    % Location of surface data
    DATA_DIR=[filePath, 'Research/Bipolar/Longitudinal_ICM_BD/Longitudinal_ICM_BD_in_HDD/data/']; % Linux
    BalsaSurf_dir = [filePath, 'Research/Bipolar/Longitudinal_ICM_BD/Atlas/Balsa_Surfaces/' ];

    T = readcell(strcat(filePath, 'Research/Bipolar/Longitudinal_ICM_BD/Longitudinal_ICM_BD_in_HDD/data/',SITE,'/subjectNames.xlsx'));

        %%%%%%%%%%%%%% NEEDS TO BE CHANGED!
    %LUTsavDir = [filePath,'Research\Bipolar\Longitudinal_ICM_BD\LUT_files']; 
    LUTsavDir = [filePath,'Research\Bipolar\Longitudinal_ICM_BD\',LUTsavDirEndLUT_files,'\']; 
    MNIdir =  [filePath,'simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\'];
    MNISavDir = [filePath,'Research\Bipolar\Longitudinal_ICM_BD\LUT_files'];

elseif ispc
    % Code to run on Windows platform
    %filePath  = 'E:\';
    headerDir = 'E:\Research/Bipolar/Longitudinal_ICM_BD/BipolarMatlab/dicomHeaderReader/';
    
    % Location of surface data
    DATA_DIR= 'F:\user\Research\Longitudinal_ICM_BD/data/'; % Linux
    BalsaSurf_dir = 'F:\user\Research\Longitudinal_ICM_BD/Atlas/Balsa_Surfaces/';

    % Location of LUT-related files:
    %LUTsavDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\LUT_files\'; 
    LUTsavDir = ['E:\Research\Bipolar\Longitudinal_ICM_BD\',LUTsavDirEnd,'\']; 
    MNIdir =  'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';
    MNISavDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\LUT_files\'; 

    T = readcell(strcat('F:\user\Research\Longitudinal_ICM_BD/data/',SITE,'/subjectNames.xlsx') );

else
    disp('Platform not supported')
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now the fun bit!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
imgDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\SampleImageData\Queens\MNI_152\';

T1w_1 = niftiread( char([imgDir, 'T1WHC.nii'] ) );
PDw_1 = niftiread( char([imgDir, 'PDW.nii'] ) );
B1_1 = niftiread( char([imgDir, 'B1.nii'] ) );


PDw = double(PDw_1(:));
MPRAGE = double(T1w_1(:));
B1 = double(B1_1(:));


% Need to run most of the code in Siemens_SubList_makeCalcT1
clear Params T1wInfo PDwInfo

Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'WM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultSiemensParamObject(Params, 4);
T1map = Siemens_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, MPRAGE, PDw, B1, [], LUTsavDir );

disp( 'Site 4, complete')

%% Second site
clear Params T1wInfo PDwInfo

Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'WM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultSiemensParamObject(Params, 5);
T1map2 = Siemens_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, MPRAGE, PDw, B1, [], LUTsavDir );

disp( 'Site 5, complete')





















