function [T1W, PD, B1, size_vol, Hdrinfo] = loadVols_MPRAGE_R1mapping(BaseFldr, SPACE,CONTRASTS, B1scale,useEPI_B1map)
%% B1
filenameB1 = fullfile(BaseFldr, SPACE, strcat(CONTRASTS(3),'.nii') );
 
% NOTE THE B1 IMAGES NEED TO BE DIVIDED BY 150 FROM GE!!!!!
temp = niftiread(char(filenameB1));
size_vol = size(temp);

if useEPI_B1map
    B1 = double(temp(:)) * B1scale;
else
    B1 = double(temp(:))/150 * B1scale;
end
%% T1w
filenameT1w = fullfile(BaseFldr, SPACE, strcat(CONTRASTS(1),'.nii') );
       
temp = niftiread(char(filenameT1w));
T1W = double(temp(:));
Hdrinfo = niftiinfo(char(filenameT1w));

%% PDw
filenamePD = fullfile(BaseFldr, SPACE, strcat(CONTRASTS(2),'.nii') );

temp = niftiread(char(filenamePD));
PD = double(temp(:));