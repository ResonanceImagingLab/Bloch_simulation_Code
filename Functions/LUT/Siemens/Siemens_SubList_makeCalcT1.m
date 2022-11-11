% % % % % %% GE get subject file names and header info for T1 calculation

% This generates a list of subjects, and then for each subject makes calls
% to GE_2pt_Inversion_T1mapping and compute_2pt_inversion_LUT (if necessary)

function [B1, T1, ExamNames, missingData] = Siemens_SubList_makeCalcT1(location, b1corr)

LUTsavDirEnd = 'LUT_files_t2_50ms';

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








%% The rest is code you DO NOT need to touch!

% % Load the Dicom Header file
% storageMat_table = load( strcat(headerDir, SITE, '_header_info.mat'));
% storageMat_table = storageMat_table.storageMat_table;


%% First sort and pull unique subject names from the dicom header file
% sub = storageMat_table(:,1); % We don't have header info for Siemens, so use subject names
% sub = table2array(sub);

sub = T(:,2);
sub = sub(~cellfun(@isempty, sub(:,1)), :); % remove empty rows for unique to work

% Debugging line: notChar_rowIndex = find(~cellfun(@ischar,sub))
[ExamNames, ~]=unique( sub);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now the fun bit!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
CONTRASTS = ["T1WHC", "PDW", "B1"];
BaseFldr = strcat(DATA_DIR, SITE, '/surfaces/');
SUBJECTS = dir ( BaseFldr );
SUBJECTS = struct2cell(SUBJECTS);
SUBJECTS = SUBJECTS(1,:)'; % convert for use with functions
TF = strcmp(SUBJECTS, ".") | strcmp(SUBJECTS, "..") ;% make more specific
SUBJECTS(TF == 1) = []; % remove folder names that don't fit template.

%% Load a surface first

% view surface
S_L=gifti( strcat( BalsaSurf_dir, 'Q1-Q6_RelatedParcellation210.L.inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii')) ;
S_R=gifti( strcat( BalsaSurf_dir, 'Q1-Q6_RelatedParcellation210.R.inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii'));

surface_L.coord = double(S_L.vertices');       % make sure this is 3*numverticies, if not transpose
surface_L.tri = double(S_L.faces);    

surface_R.coord = double(S_R.vertices');       % make sure this is 3*numverticies, if not transpose
surface_R.tri = double(S_R.faces);     

l_L2 = cifti_read(strcat(BalsaSurf_dir, 'Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii'));
label_L = CR_CIFTIcdata(l_L2.cdata, 32492, l_L2.diminfo{1,1}.models{1,1}.vertlist);

l_R2 = cifti_read(strcat(BalsaSurf_dir, 'Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii'));
label_R = CR_CIFTIcdata(l_R2.cdata, 32492, l_R2.diminfo{1,1}.models{1,1}.vertlist);


% Initialize matrices
T1_L = zeros(length(ExamNames), length(label_R));
T1_R = zeros(length(ExamNames), length(label_R));
T1W_L = zeros(length(ExamNames), length(label_R));
T1W_R = zeros(length(ExamNames), length(label_R));
PD_L = zeros(length(ExamNames), length(label_R));
PD_R = zeros(length(ExamNames), length(label_R));
B1_L = zeros(length(ExamNames), length(label_R));
B1_R = zeros(length(ExamNames), length(label_R));

idx = 1;
mdIDX = 1;
missingData = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize Parameter structures:
Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultSiemensParamObject(Params, location);


%% for each unique surface folder
for i = 1:length(ExamNames)
    tic

    % deal with issues with folder naming not being consistent
    % find the folder that 'contains the subject name:
    try
        sub_fldr =  SUBJECTS{i}; %(contains(SUBJECTS,Subnames{i}));   
    catch
        % If we don't match, then report that
        missingData{idx} = ExamNames{i}; mdIDX = mdIDX+1;
        idx = idx +1;
    end
    
    if isempty(sub_fldr)
        % If we don't match, then report that
        missingData{mdIDX} = ExamNames{i};     mdIDX = mdIDX+1;
        idx = idx +1;
        continue; % skip
    end
   
%% load the surfaces:

% B1
        filenameL = strcat(BaseFldr, sub_fldr, '/32k/lh.', CONTRASTS(3),'.32k_fs_LR.func.gii' );
        filenameR = strcat(BaseFldr, sub_fldr, '/32k/rh.', CONTRASTS(3),'.32k_fs_LR.func.gii' );
        
        if ~isfile(filenameL) ||  ~isfile(filenameR) % File exists.
            missingData{mdIDX} = strcat( ExamNames{i}, '/32k/lh.', CONTRASTS(3),'.32k_fs_LR.func.gii' );
            mdIDX = mdIDX+1; idx = idx+1; 
        end
        
        
        % Open gifti label files
        % NOTE THE B1 IMAGES NEED TO BE DIVIDED BY 150 FROM GE!!!!!
        temp_L = gifti( char( filenameL ));
        B1_L(i,:) = double(temp_L.cdata)'; 

        temp_R = gifti( char( filenameR ));
        B1_R(i,:) = double(temp_R.cdata)';
        
        if max(B1_L(i,:),[],2) == 0 || max(B1_R(i,:),[],2) == 0
            missingData{mdIDX} = ExamNames{i}; mdIDX = mdIDX+1;
            idx = idx +1;
            continue;
        end
        
        
%% T1w
        filenameL = strcat(BaseFldr, sub_fldr, '/32k/lh.', CONTRASTS(1),'.32k_fs_LR.func.gii' );
        filenameR = strcat(BaseFldr, sub_fldr, '/32k/rh.', CONTRASTS(1),'.32k_fs_LR.func.gii' );
        
        if ~isfile(filenameL) || ~isfile(filenameR) % File exists.
            missingData{mdIDX} = strcat( ExamNames{i}, '/32k/lh.', CONTRASTS(1),'.32k_fs_LR.func.gii' );
            mdIDX = mdIDX+1; idx = idx+1; 
        end
        
        % Open gifti label files
        temp_L = gifti( char( filenameL ));
        T1W_L(i,:) = double(temp_L.cdata)';
        
        temp_R = gifti( char( filenameR ));
        T1W_R(i,:) = double(temp_R.cdata)';
        
        if max(T1W_L(i,:),[],2) == 0 ||  max(T1W_R(i,:),[],2) == 0
            missingData{mdIDX} = ExamNames{i};   mdIDX = mdIDX+1;
            idx = idx +1;
            continue;
        end
        

        
%% PDw
        filenameL = strcat(BaseFldr, sub_fldr, '/32k/lh.', CONTRASTS(2),'.32k_fs_LR.func.gii' );
        filenameR = strcat(BaseFldr, sub_fldr, '/32k/rh.', CONTRASTS(2),'.32k_fs_LR.func.gii' );
        
        if ~isfile(filenameL) || ~isfile(filenameR) % File exists.
            missingData{mdIDX} = strcat( ExamNames{i}, '/32k/lh.', CONTRASTS(2),'.32k_fs_LR.func.gii' );
            mdIDX = mdIDX+1; idx = idx+1; 
        end
        
        
        % Open gifti label files
        temp_L = gifti( char( filenameL ));
        PD_L(i,:) = double(temp_L.cdata)';
        
        temp_R = gifti( char( filenameR ));
        PD_R(i,:) = double(temp_R.cdata)';
        
        if max(PD_L(i,:),[],2) == 0 ||  max(PD_R(i,:),[],2) == 0
            missingData{mdIDX} = ExamNames{i};    mdIDX = mdIDX+1;
            idx = idx +1;
            continue;
        end
        
        
%          %% Note for Siemens, there is a gain factor of 2.5 between the MPRAGE and PDw image
%          % Fix the PDw intensity. 
         PD_L(i,:) =  PD_L(i,:)*1.75;
         PD_R(i,:) =  PD_R(i,:)*1.75;


%         temp = T1W_L(i,:) ./ PD_L(i,:);


%% calculate R1
b1corr = 1; % idk, maybe remove this.
        if strcmp(b1corr, 'noB1corr')
            null_B1 = ones(size(PD_L(i,:))); % not speed optimized, but it should... always work. 

            T1_L(i,:) = Siemens_2pt_Inversion_T1mapping(T1wInfo, PDwInfo, T1W_L(i,:),...
                PD_L(i,:), null_B1, [], LUTsavDir, MNIdir, MNISavDir );
            
            T1_R(i,:) = Siemens_2pt_Inversion_T1mapping(T1wInfo, PDwInfo, T1W_R(i,:),...
                PD_R(i,:), null_B1, [], LUTsavDir, MNIdir, MNISavDir );

        else

            T1_L(i,:) = Siemens_2pt_Inversion_T1mapping(T1wInfo, PDwInfo, T1W_L(i,:),...
                PD_L(i,:), B1_L(i,:), [], LUTsavDir, MNIdir, MNISavDir );
            
            T1_R(i,:) = Siemens_2pt_Inversion_T1mapping(T1wInfo, PDwInfo, T1W_R(i,:),...
                PD_R(i,:), B1_R(i,:), [], LUTsavDir, MNIdir, MNISavDir );

 
        end

 disp(i/length(ExamNames))
 toc
end

B1 = cat(3, B1_L, B1_R);
T1 = cat(3, T1_L, T1_R);




