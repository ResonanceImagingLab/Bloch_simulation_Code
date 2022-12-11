%% GE get subject file names and header info for T1 calculation

% This generates a list of subjects, and then for each subject makes calls
% to GE_2pt_Inversion_T1mapping and compute_2pt_inversion_LUT (if necessary)

function [B1, T1, Subnames, missingData] = GE_SubList_makeCalcT1(location, b1corr)

%% Initialize Variables
% Location of the Dicom Header script
if location == 1
    SITE = 'McMaster';
elseif location == 2
    SITE = 'Dal';
    elseif location == 3
    SITE = 'Calgary';
elseif location == 4
    %SITE = 'Queens';
    error('Make call to Siemens script instead of the GE script')
elseif location == 5
    %SITE = 'UNH';
    error('Make call to Siemens script instead of the GE script')
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
    LUTsavDir = [filePath,'Research\Bipolar\Longitudinal_ICM_BD\LUT_files']; 
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
    LUTsavDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\LUT_files\'; 
    MNIdir =  'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';
    MNISavDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\LUT_files\'; 

    T = readcell(strcat('F:\user\Research\Longitudinal_ICM_BD/data/',SITE,'/subjectNames.xlsx') );

else
    disp('Platform not supported')
end








%% The rest is code you DO NOT need to touch!

% Load the Dicom Header file
storageMat_table = load( strcat(headerDir, SITE, '_header_info.mat'));
storageMat_table = storageMat_table.storageMat_table;
% if location == 3
%     storageMat_table = storageMat_table.T;
% else
%     storageMat_table = storageMat_table.storageMat_table;
% end



%% First sort and pull unique subject names from the dicom header file
sub = storageMat_table(:,1);
%sub = table2cell(sub);
sub = table2array(sub);
sub = sub(~cellfun(@isempty, sub(:,1)), :); % remove empty rows for unique to work

% Debugging line: notChar_rowIndex = find(~cellfun(@ischar,sub))
[ExamNames, ~]=unique( sub);


%% For each unique name, find the matching name from excel file T
Subnames = cell(size(ExamNames));
missingData = cell(size(ExamNames));
idx_m = 1; % counter for missing data
idx_s = 1; % counter for surfaces

for i = 1:length(ExamNames)
    
    tmpName = ExamNames{i};
    % Find matching index
    tf = strcmp(tmpName, T(:,1));
    checkData = T(tf,2);
    
    if isempty( checkData )
        missingData{idx_m} = ExamNames{i};
        idx_m = idx_m + 1;
    else
        Subnames(idx_s) = T(tf,2);
        idx_s = idx_s + 1;
    end
    
end

missingData = missingData(~cellfun(@isempty, missingData(:,1)), :); % remove empty rows for unique to work
Subnames = Subnames(~cellfun(@isempty, Subnames(:,1)), :); 

 % remove exam names 
 for i = 1: length(missingData)
     ExamNames( strcmp(ExamNames,missingData{i} )) = [];
 end

%% Replicated the dicom header file with the surface folder name

% if location == 3 % issues with how this was made...
%     storageMat_table.TR = num2cell(storageMat_table.TR);
%     storageMat_table.TE = num2cell(storageMat_table.TE);
%     storageMat_table.TI = num2cell(storageMat_table.TI);
%     storageMat_table.FlipAngle = num2cell(storageMat_table.FlipAngle);
%     storageMat_table.RecGainAnalog = num2cell(storageMat_table.RecGainAnalog);
%     storageMat_table.RecGainDigital = num2cell(storageMat_table.RecGainDigital);
%     storageMat_table.TransmitGain = num2cell(storageMat_table.TransmitGain);
% end

dcmHdr = table2array(storageMat_table);

repSubnames = cell(size(dcmHdr(:,1)));

for i = 1:length(ExamNames)
    tf = strcmp( dcmHdr(:,1), ExamNames{i} );
    repSubnames(tf) = cellstr(Subnames{i});
end
    
%% Here we might get missing data in the other direction!
% remove the rows from dcmHdr and store these values in MissingData ->
% likely the same ones as above

tf = cellfun(@isempty, repSubnames);
Mexams =     dcmHdr(tf);
Mexams = Mexams(~cellfun(@isempty, Mexams(:,1)), :); % remove empty rows for unique to work
[Mexams_u]=unique( Mexams);
missingData = vertcat(missingData, Mexams_u);
[missingData]=unique( missingData);

dcmHdr(tf,:) = [];
repSubnames(tf,:) = [];
dcmHdr = horzcat(dcmHdr, repSubnames);


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
mdIDX = length(missingData);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize Parameter structures:
Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultGEparamObject(Params);

mdIDX = 1;
%% for each unique surface folder
for i = 1:length(ExamNames)
    tic

    % deal with issues with folder naming not being consistent
    % find the folder that 'contains the subject name:
     sub_fldr =  SUBJECTS(contains(SUBJECTS,Subnames{i}));

    if isempty(sub_fldr)
        % If we don't match, then report that
        missingData{mdIDX} = Subnames{i};     mdIDX = mdIDX+1;
        idx = idx +1;
        continue; % skip
    end
   
%% load the surfaces:

% B1
        filenameL = strcat(BaseFldr, sub_fldr, '/32k/lh.', CONTRASTS(3),'.32k_fs_LR.func.gii' );
        filenameR = strcat(BaseFldr, sub_fldr, '/32k/rh.', CONTRASTS(3),'.32k_fs_LR.func.gii' );
        
        if ~isfile(filenameL) ||  ~isfile(filenameR) % File exists.
            missingData{mdIDX} = strcat( Subnames{i}, '/32k/lh.', CONTRASTS(3),'.32k_fs_LR.func.gii' );
            mdIDX = mdIDX+1; idx = idx+1; 
        end
        

        % Open gifti label files
        % NOTE THE B1 IMAGES NEED TO BE DIVIDED BY 150 FROM GE!!!!!
        temp_L = gifti( char( filenameL ));
        B1_L(i,:) = double(temp_L.cdata)'/150;

        temp_R = gifti( char( filenameR ));
        B1_R(i,:) = double(temp_R.cdata)'/150;
        
        if max(B1_L(i,:),[],2) == 0 || max(B1_R(i,:),[],2) == 0
            missingData{mdIDX} = Subnames{i}; mdIDX = mdIDX+1;
            idx = idx +1;
            continue;
        end
                

        
%% T1w
        filenameL = strcat(BaseFldr, sub_fldr, '/32k/lh.', CONTRASTS(1),'.32k_fs_LR.func.gii' );
        filenameR = strcat(BaseFldr, sub_fldr, '/32k/rh.', CONTRASTS(1),'.32k_fs_LR.func.gii' );
        
        if ~isfile(filenameL) ||  ~isfile(filenameR) % File exists.
            missingData{mdIDX} = strcat( Subnames{i}, '/32k/lh.', CONTRASTS(1),'.32k_fs_LR.func.gii' );
            mdIDX = mdIDX+1; idx = idx+1; 
        end
               
        
        % Open gifti label files
        temp_L = gifti( char( filenameL ));
        T1W_L(i,:) = double(temp_L.cdata)';
        
        temp_R = gifti( char( filenameR ));
        T1W_R(i,:) = double(temp_R.cdata)';
        
        if max(T1W_L(i,:),[],2) == 0 ||  max(T1W_R(i,:),[],2) == 0
            missingData{mdIDX} = Subnames{i};   mdIDX = mdIDX+1;
            idx = idx +1;
            continue;
        end
        

        
%% PDw
        filenameL = strcat(BaseFldr, sub_fldr, '/32k/lh.', CONTRASTS(2),'.32k_fs_LR.func.gii' );
        filenameR = strcat(BaseFldr, sub_fldr, '/32k/rh.', CONTRASTS(2),'.32k_fs_LR.func.gii' );
        
        if ~isfile(filenameL) ||  ~isfile(filenameR) % File exists.
            missingData{mdIDX} = strcat( Subnames{i}, '/32k/lh.', CONTRASTS(2),'.32k_fs_LR.func.gii' );
            mdIDX = mdIDX+1; idx = idx+1; 
        end
        
              
        % Open gifti label files
        temp_L = gifti( char( filenameL ));
        PD_L(i,:) = double(temp_L.cdata)';
        
        temp_R = gifti( char( filenameR ));
        PD_R(i,:) = double(temp_R.cdata)';
        
        if max(PD_L(i,:),[],2) == 0 ||  max(PD_R(i,:),[],2) == 0
            missingData{mdIDX} = Subnames{i};    mdIDX = mdIDX+1;
            idx = idx +1;
            continue;
        end
               
        
        %% Pull section of dicom header with the relevant subject data
         temp = dcmHdr (strcmp( dcmHdr(:,1), ExamNames{i} ),:);
         
         % Find index with B1
         %b1_row  =  temp(contains(temp(:,2),'B1'),:); 
         
         % Find index with flash
         pd_row  =  temp(contains(temp(:,2),'FLASH PD'),:); 
        % PD will be same for left and right
         PDwInfo.flipAngle = cell2mat( pd_row(1,6)) ;
         PDwInfo.TR =cell2mat( pd_row(1,3))/1000; % in seconds


         

         % Most parameters are set in function defaultGEparamObject.m
         T1wInfoL = T1wInfo;
         T1wInfoR = T1wInfo;

         % Find index with Left T1w
         t1_row  =  temp(contains(temp(:,2),'LT'),:); 
         T1wInfoL.flipAngle = mean(cell2mat(t1_row(:,6))) ;
         T1wInfoL.echoSpacing = mean(cell2mat(t1_row(:,3)))/1000; % in seconds
         T1wInfoL.TR  =  T1wInfoL.TI  + T1wInfoL.TD + T1wInfoL.echoSpacing*(T1wInfoL.TurboFactor + T1wInfoL.DummyEcho) ;
        
         % Right side
         t1_row  =  temp(contains(temp(:,2),'RT'),:); 
         T1wInfoR.flipAngle = mean(cell2mat(t1_row(:,6))) ;
         T1wInfoR.echoSpacing = mean(cell2mat(t1_row(:,3)))/1000; % in seconds
         T1wInfoR.TR  =  T1wInfoR.TI  + T1wInfoR.TD + T1wInfoR.echoSpacing*(T1wInfoR.TurboFactor + T1wInfoR.DummyEcho) ;  
   
   

%% calculate R1
b1corr = 1; % idk, maybe remove this.
        if strcmp(b1corr, 'noB1corr')
            null_B1 = ones(size(PD_L(i,:))); % not speed optimized, but it should... always work. 

            T1_L(i,:) = GE_2pt_Inversion_T1mapping(T1wInfoL, PDwInfo, T1W_L(i,:),...
                PD_L(i,:), null_B1, [], LUTsavDir, MNIdir, MNISavDir );
            
            T1_R(i,:) = GE_2pt_Inversion_T1mapping(T1wInfoR, PDwInfo, T1W_R(i,:),...
                PD_R(i,:), null_B1, [], LUTsavDir, MNIdir, MNISavDir );
 
        else

            T1_L(i,:) = GE_2pt_Inversion_T1mapping(T1wInfoL, PDwInfo, T1W_L(i,:),...
                PD_L(i,:), B1_L(i,:), [], LUTsavDir, MNIdir, MNISavDir );
            
            T1_R(i,:) = GE_2pt_Inversion_T1mapping(T1wInfoR, PDwInfo, T1W_R(i,:),...
                PD_R(i,:), B1_R(i,:), [], LUTsavDir, MNIdir, MNISavDir );

  
        end

 disp(i/length(ExamNames))
 toc
end

B1 = cat(3, B1_L, B1_R);
T1 = cat(3, T1_L, T1_R);







