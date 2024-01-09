%% This script is meant to extract information about
%% Transmit and Receive gain from the dicom headers

% The easiest way to handle this will likely be to use SPM's framework
% Download SPM12 here https://www.fil.ion.ucl.ac.uk/spm/software/download/

% Once downloaded, update the following line with the save location:
%addpath('/home/chris/MATLAB Add-Ons/spm12')
addpath('/home/bockn/matlab/Longitudinal_ICM_in_BD/spm12/')

% Structure
%    /home/bockn/Data/Longitudinal_ICM_BD/Calgary/raw/SUBJECT/CONTRAST/*.dcm
%    /home/bockn/Data/Longitudinal_ICM_BD/Dal/raw/SUBJECT/CONTRAST/*.dcm
%    /home/bockn/Data/Longitudinal_ICM_BD/McMaster/raw/SUBJECT/CONTRAST/*.dcm

% NOTE the naming structure isn't consistent enough across the scans, so I
% won't get smart with pulling the exact scans here. Just get all the info
% and sort after. 

%% Setup the file structure

% Data folder location

DATADIR = '/home/bockn/Data/Longitudinal_ICM_BD/'; % Main folder for images
OUTDIR = '/home/bockn/matlab/R1_Mapping_Longitudinal_ICM_in_BD/'; % Where to save ouput tables

%DATADIR ='/home/chris/Downloads/'; % Main folder for images
%OUTDIR = '/home/chris/Downloads/'; % Where to save ouput tables

location=2

if location == 1
    SITE = 'McMaster';
    %Contrast = { 'B1', 'PDw', 'T1wHC_L1', 'T1wHC_L2', 'T1wHC_R1', 'T1wHC_R2'};
    
elseif location == 2
    SITE = 'Dal';
    %Contrast = { 'MR B1 map', 'MR SAG FLASH PD', 'MR LT SAG BRAVO', 'MR LT SAG BRAVO-2', 'MR RT SAG BRAVO', 'MR RT SAG BRAVO-2'};
    
elseif location == 3
    SITE = 'Calgary';
    %Contrast = { 'B1 map - 4', 'SAG FLASH PD - 3', 'LT SAG BRAVO - 5', 'LT SAG BRAVO - 7', 'RT SAG BRAVO - 6', 'RT SAG BRAVO - 8'};
    
elseif location == 4
    SITE = 'McMaster_Travelling';
    
elseif location == 5
    SITE = 'Dal_Travelling';
    
elseif location == 6
    SITE = 'Calgary_Travelling';
end

% Pull the subject names to build the images headers to extract
SUBJECTS = dir (strcat(DATADIR,SITE,'/raw/') );
SUBJECTS = struct2cell(SUBJECTS);
SUBJECTS = SUBJECTS(1,:)'; % convert for use with functions

% I get two empty entries with period names, so remove them
% TF = contains(SUBJECTS,"."); % Old way  
TF = strcmp(SUBJECTS, ".") | strcmp(SUBJECTS, "..") ;% make more specific
SUBJECTS(TF == 1) = []; % remove folder names that don't fit template.



% Setup empty storage matrix
storageMat = cell(length(SUBJECTS) *9, 9); % arbitrarily long for now.
missingData = [];

missingIdx = 1;
idx = 1;

%% Generate a list of all the DICOM header info
for i = 1:length(SUBJECTS) % for each image (B1, PDw, T1wHC_L1, T1wHC_L2, T1wHC_R1, T1wHC_R2)
    % Nick testing
    SUBJECTS{i}
    % get scan list
    fileLocation1 = char(strcat(DATADIR,SITE,'/raw/', SUBJECTS{i}) );
    Scans = dir (  fileLocation1 );
    dirFlags = ~[Scans.isdir]';
    Scans = struct2cell(Scans);
    Scans = Scans(1,:)'; % convert for use with functions
    newScan  = Scans; % just for the next loop...
    
    %%%%%%%%%%%% NEW
    % if max dirFlags is 0, then folder is nested...
    while max(dirFlags) == 0
        % get list, remove blanks
        temp = newScan;
        TF = strcmp(temp, ".") | strcmp(temp, "..") | contains( temp,"nii")  ;% make more specific
        temp(TF == 1) = []; % remove folder names that don't fit template.
        fileLocation2 = char( strcat( fileLocation1,'/', temp(1) )); % include 1 index just in case there is still some other folder...
        newScan = dir(  fileLocation2  );
        dirFlags = ~[newScan.isdir]';
        % if you reach the end of the nested folders, then exit :) 
        if max(dirFlags) == 0
            fileLocation1 = fileLocation2;
        else
            Scans = temp;
            continue;
        end
        newScan = struct2cell(newScan);
        newScan = newScan(1,:)'; % convert for use with functions
        
    end
    %%%%%%%%%%%%%% END NEW
    
    %TF = contains(Scans,".");    % Old
    % remove hidden folders and nifti folders.
    TF = startsWith(Scans,".") | contains(Scans,"nii");  % new, more specific - less error prone
    Scans(TF> 0) = []; % remove folder names that don't fit template.
    
    for j = 1:length(Scans)

        Path = strcat(fileLocation1,'/', Scans{j});
        %Path = strcat(DATADIR,SITE,'/raw/', SUBJECTS{i},'/', Scans{j});

        % list of all dicom files
        files = spm_select('FPlist', fullfile(Path), '^*.dcm'); 
        
        % if no dicom files, skip. There are some extra folders saved in here...
        if isempty(files)
            break;
        end
        
        % for speed, just take one of them
        file = files(3,:);

       %% Start New: For some reason the files are sometimes loaded with preceding "._" so remove
        [filepath,name,ext] = fileparts(file);
            
        if startsWith(name,"._") 
             name = name(3:end);
        end
            
        % Put it back together
        file = strcat(filepath,'/',name,ext);
        %% End NEW
        
   
        
        % We get the header information from the Dicom files
        hdr = spm_dicom_headers(file); % generates 1 cell for each image in files. Each cell contains the header info.
        hdr = hdr{1,1}; % pull out the first one

        % Take Values of interest
        if isfield(hdr,'SeriesDescription')
            ImageName = hdr.SeriesDescription;
        else
            ImageName = -1; % place holder to know value is missing
        end
        
        
        if isfield(hdr,'RepetitionTime')
            TR = hdr.RepetitionTime;
        else
            TR = -1; % place holder to know value is missing, or something is wrong
            %Nick commented this out
            %missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->RepetitionTime');
            %missingIdx = missingIdx+1;
        end

        if isfield(hdr,'EchoTime')
            TE = hdr.EchoTime;
        else
            TE = -1; % place holder to know value is missing
%             missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->EchoTime');
%             missingIdx = missingIdx+1;
        end

        if isfield(hdr,'InversionTime')
            TI = hdr.InversionTime;
        else
            TI = -1; % place holder to know value is missing
%             missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->InversionTime');
%             missingIdx = missingIdx+1;
        end

        if isfield(hdr,'FlipAngle')
            FlipAngle = hdr.FlipAngle;
        else
            FlipAngle = -1; % place holder to know value is missing
%             missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->FlipAngle');
%             missingIdx = missingIdx+1;
        end

        % The following names were uncovered in MIPAV

        if isfield(hdr,'Private_0019_108a') %  Actual Receive Gain analog 
            RecGainAnalog = hdr.Private_0019_108a;
        else
            RecGainAnalog = -1; % place holder to know value is missing
%             missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->Private_0019_108a');
%             missingIdx = missingIdx+1;
        end

        if isfield(hdr,'Private_0019_108b') %  Actual Receive Gain digital
            RecGainDigital = hdr.Private_0019_108b;
        else
            RecGainDigital = -1; % place holder to know value is missing
%             missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->Private_0019_108b');
%             missingIdx = missingIdx+1;
        end

        if isfield(hdr,'Private_0019_10f9') % Transmit Gain
            TransmitGain = hdr.Private_0019_10f9;
        else
            TransmitGain = -1; % place holder to know value is missing
%             missingData(missingIdx) = strcat(SUBJECTS{i}, ImageName,'->Private_0019_10f9');
%             missingIdx = missingIdx+1;
        end

        % Store values in a matrix
        storageMat(idx,:) = [ SUBJECTS{i},cellstr(ImageName), TR, TE,...
            TI, FlipAngle, RecGainAnalog ,  RecGainDigital, TransmitGain];
        idx = idx +1;

    end
    
end


%% Save Output table
storageMat_table = array2table(storageMat, 'VariableNames',{'Subject', ...
    'SeriesName', 'TR', 'TE', 'TI', 'FlipAngle', 'RecGainAnalog', 'RecGainDigital', 'TransmitGain'});


save(strcat(OUTDIR,SITE, '_header_info.mat'), 'storageMat_table') 

















