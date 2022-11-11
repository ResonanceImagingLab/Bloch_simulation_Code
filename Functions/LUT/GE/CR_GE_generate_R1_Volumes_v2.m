function CR_GE_generate_R1_Volumes_v2(location, B1scale)

addpath(genpath('/home/bockn/matlab/R1_Mapping'))
%% Generate R1 maps for GE with DICOM header info
% Expects image files in DataDir/Location/processed/subject.
% Expects outcome from dicom header in headerDir/Site_header_info.mat

%% Initialize Variables
% Location of the Dicom Header script
headerDir = '/home/bockn/matlab/Longitudinal_ICM_in_BD/';
LUTsavDir = '/home/bockn/matlab/R1_Mapping/BD_SeqSimCode/LUT_files/'; 
% load the excel sheet with sbuject name conversions

%location=1;
%B1scale=1;

% Location of data
DATA_DIR='/home/bockn/Data/Longitudinal_ICM_BD/';
%location=3;
if location == 1
    SITE = 'McMaster';
elseif location == 2
    SITE = 'Dal';
elseif location == 3
    SITE = 'Calgary';
else
    error('Location must be a value between 1 and 3')
% elseif location == 4
%     SITE = 'Queens';
% elseif location == 5
%     SITE = 'UNH';
end

% Use normalized B1+ maps
NORMALIZED=0;

if isempty(B1scale)
    B1scale = 1;
end

%% The rest is code you DO NOT need to touch!

% Load the Dicom Header file
storageMat_table = load(strcat(headerDir, SITE, '_header_info.mat'));
storageMat_table = storageMat_table.storageMat_table;


%% First sort and pull unique subject names from the dicom header file
sub = storageMat_table(:,1);
%sub = table2cell(sub);
sub = table2array(sub);
sub = sub(~cellfun(@isempty, sub(:,1)), :); % remove empty rows for unique to work

% Debugging line: notChar_rowIndex = find(~cellfun(@ischar,sub))
[ExamNames, ~]=unique( sub);

% Simplify for this case, just take the unique subject names:
dcmHdr = table2array(storageMat_table);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now the fun bit! -> Load volumes then calc T1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if NORMALIZED==1
CONTRASTS = ["T1WHC", "PDW", "B1_normalized"];
else
CONTRASTS = ["T1WHC", "PDW", "B1"];
end

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

    %% Load the first volume to get dimensions
    sub_fldr =  SUBJECTS(contains(SUBJECTS,ExamNames{3}));   
    filenameL = strcat(BaseFldr, sub_fldr, '/',SPACE(j),'/', CONTRASTS(3),'.nii' );
    %temp = MRIread(char(filenameL));
    temp = niftiread(char(filenameL));
    size_vol = size(temp);


    %figure; imshow3Dfull(temp , [0 200]) 

    % %% Sample wm_parc ROI:
    % filenameL = strcat(BaseFldr, sub_fldr, '/SPACE(j)/wmparc.nii.gz' );
    % temp2 = niftiread(char(filenameL));
    % size_vol = size(temp2);
    % temp2 = temp2(:);
    % 
    % figure; imshow3Dfull(temp , [0 200]) 
    % figure; imshow3Dfull(temp2 , [0 200]) 

    % Initialize matrices
    idx = 1;

    Params.MTC = 0;
    Params.B0 = 3;
    Params.TissueType = 'GM';
    Params = DefaultCortexTissueParams(Params);
    [T1wInfo, PDwInfo] = defaultGEparamObject(Params);

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
        
        if NORMALIZED ==1
            B1=double(temp(:));
        else
                      
            if B1scale == 0
                B1 = ones(size(temp));
            else
                B1 = double(temp(:))/150 * B1scale;
            end
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
        
      
        %% Pull section of dicom header with the relevant subject data
         temp = dcmHdr (strcmp( dcmHdr(:,1), ExamNames{i} ),:);
         
         % Find index with B1
         %b1_row  =  temp(contains(temp(:,2),'B1'),:); 
         
         % Find index with flash
         pd_row  =  temp(contains(temp(:,2),'FLASH PD'),:); 
        % PD will be same for left and right
         PDwInfo.flipAngle = cell2mat( pd_row(1,6)) ;
         PDwInfo.TR =cell2mat( pd_row(1,3))/1000; % in seconds


         % Find index with Left T1w
         t1_row  =  temp(contains(temp(:,2),'LT'),:); 

         T1wInfo.flipAngle = mean(cell2mat(t1_row(:,6))) ;
         T1wInfo.echospacing =mean(cell2mat(t1_row(:,3)));
         T1wInfo.echoSpacing = mean(cell2mat(t1_row(:,3)))/1000; % in seconds
         T1wInfo.TR  =  T1wInfo.TI  + T1wInfo.TD + T1wInfo.echoSpacing*(T1wInfo.TurboFactor + T1wInfo.DummyEcho) ;


%% calculate R1

        T1 = GE_2pt_Inversion_T1mapping(T1wInfo, PDwInfo, T1W,...
                PD, B1, [], LUTsavDir, [], [] );

        R1 = (1./T1)*1000;
        R1 = limitHandler(R1,0, 3); % remove nan and inf
        
%% Put back into cube
        q = 1:length(R1);
        R1_vol = zeros( size_vol);
        R1_vol(q)  = R1;
        % output Name:
        if NORMALIZED==1
           outputName = strcat(OutFldr, sub_fldr, '/SPACE(j)/R1_map_normalized.nii' );  
        % Clean up
        Hdrinfo.Datatype = 'double'; % change from single
        niftiwrite(R1_vol, char(outputName), Hdrinfo, 'Compressed',false);

        else
        mkdir (strcat(OutFldr, sub_fldr, '/',SPACE(j),'/'))
        outputName = strcat(OutFldr, sub_fldr, '/',SPACE(j),'/R1_map.nii' );
        
        % Clean up
        Hdrinfo.Datatype = 'double'; % change from single
        niftiwrite(R1_vol, char(outputName), Hdrinfo, 'Compressed',false);
        end
    end
end

disp('Error found related to the following files:')
disp(missingData')

% 
%figure; imshow3Dfull(R1_vol)






















