function CR_Siemens_generate_R1_Volumes_v3(location,B1scale)
% in reality this is version 1, but it just paired with the version 2 of
% the GE one. 

%% include code for mapping
addpath(genpath('/home/bockn/matlab/R1_Mapping/LUT'))
%% Generate R1 maps for Siemens

%% Initialize Variables
% Location of the Dicom Header script
% headerDir = '/home/bockn/matlab/Longitudinal_ICM_in_BD/';
LUTsavDir = '/home/bockn/matlab/R1_Mapping_Longitudinal_ICM_in_BD/LUT_files_t2_80ms/'; 

% Location of data
DATA_DIR='/home/bockn/Data/Longitudinal_ICM_BD/';

% if location == 1
%     SITE = 'McMaster';
% elseif location == 2
%     SITE = 'Dal';
%     elseif location == 3
%     SITE = 'Calgary';
if location == 4
     SITE = 'Queens';
elseif location == 5
     SITE = 'UHN';
elseif location == 6
     SITE = 'Queens_Travelling'
elseif location == 7
     SITE = 'UHN_Travelling'
else
    error('Lcation must be a value between 4 and 5')
end

if isempty(B1scale)
    B1scale = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now the fun bit! -> Load volumes then calc T1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CONTRASTS = ["T1WHC", "PDW", "B1"];

% Loop over both spaces

SPACE=["MNI_152", "MNI_152_nl"];

for j=1:2

BaseFldr = strcat(DATA_DIR, SITE, '/processed/');
OutFldr = strcat(DATA_DIR, SITE, '/R1_maps_',num2str(B1scale),'/');
SUBJECTS = dir ( BaseFldr );
SUBJECTS = struct2cell(SUBJECTS);
SUBJECTS = SUBJECTS(1,:)'; % convert for use with functions
TF = strcmp(SUBJECTS, ".") | strcmp(SUBJECTS, "..") ;% make more specific
SUBJECTS(TF == 1) = []; % remove folder names that don't fit template.
ExamNames = SUBJECTS; % then the rest of the code should be similar to the GE.

%% Load the first volume to get dimensions
sub_fldr =  SUBJECTS(1);   
filenameL = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(3),'.nii' );
%temp = MRIread(char(filenameL));
temp = niftiread(char(filenameL));
size_vol = size(temp);

               
%figure; imshow3Dfull(temp , [0 200]) 

% %% Sample wm_parc ROI:
% filenameL = strcat(BaseFldr, sub_fldr, '/MNI_152/wmparc.nii.gz' );
% temp2 = niftiread(char(filenameL));
% size_vol = size(temp2);
% temp2 = temp2(:);
% 
% figure; imshow3Dfull(temp , [0 200]) 
% figure; imshow3Dfull(temp2 , [0 200]) 

% Initialize matrices
idx = 1;

%% Initialize Parameter structures:
Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'WM';
Params = DefaultCortexTissueParams(Params);

if location == 4 || location == 6
[T1wInfo, PDwInfo] = defaultSiemensParamObject(Params, 4);
else
[T1wInfo, PDwInfo] = defaultSiemensParamObject(Params, 5);
end

%% for each unique surface folder
for i = 1:length(ExamNames)
    
%% Nick trying to figure out which exams are causing problems.
    disp(ExamNames(i))
   
%% load the volumes:

%% B1
        sub_fldr=ExamNames{i};
        filenameL = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(3),'.nii' );
        
        if ~isfile(filenameL) % File exists.
             missingData{idx} = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(3),'.nii' );
            idx = idx+1; 
            continue;
        end
               
        % Open nifti label files
        % NOTE THE B1 IMAGES NEED TO BE DIVIDED BY 150 FROM GE!!!!!
        temp = niftiread(char(filenameL));
        
            if B1scale == 0
                B1 = ones(size(temp));
            else
                B1 = double(temp(:))* B1scale;
            end
            
        if max(B1(:)) == 0
            missingData{idx} = ExamNames{i};     idx = idx +1;
            continue;
        end
        
        
%% T1w
        filenameL = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(1),'.nii' );
        
        if ~isfile(filenameL) % File exists.
            missingData{idx} = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(1),'.nii' );
            idx = idx+1; 
            continue;
        end
              
        % Open gifti label files
        
        % Also grab header info here :)
        Hdrinfo = niftiinfo(char(filenameL));
        
        
        temp = niftiread(char(filenameL));
        T1W = double(temp(:));
        
        if max(T1W(:)) == 0
            missingData{idx} = ExamNames{i};     idx = idx +1;
            continue;
        end
        
        
%% PDw
        filenameL = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(2),'.nii' );
        
        if ~isfile(filenameL) % File exists.
            missingData{idx} = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(2),'.nii' );
            idx = idx+1; 
            continue;
        end
          
        % Open gifti label files
        temp = niftiread(char(filenameL));
        PD = double(temp(:));

        if max(PD(:)) == 0
            missingData{idx} = ExamNames{i};     idx = idx +1;
            continue;
        end
        
      
         %% Note for Siemens, there is a gain factor of 2.5 between the MPRAGE and PDw image
         % Fix the PDw intensity. 
         PD =  PD*1.75;


%% calculate R1

        T1 = Siemens_2pt_Inversion_T1mapping_1pool(T1wInfo, PDwInfo, T1W,...
                PD, B1, [], LUTsavDir);

        R1 = (1./T1)*1000;
        R1 = limitHandler(R1,0, 3); % remove nan and inf
        
%% Put back into cube
        q = 1:length(R1);
        R1_vol = zeros( size_vol);
        R1_vol(q)  = R1;
       
        % output Name:
        mkdir (strcat(OutFldr, sub_fldr, '/',SPACE(j),'/'))
        outputName = strcat(OutFldr, sub_fldr, '/',SPACE(j),'/R1_map.nii' );
        
        % Clean up
        Hdrinfo.Datatype = 'double'; % change from single
        niftiwrite(R1_vol, char(outputName), Hdrinfo, 'Compressed',false);

end
end

% Breaks if missingData is empty
%disp('Error found related to the following files:')
%disp(missingData')

% 
%figure; imshow3Dfull(R1_vol)






