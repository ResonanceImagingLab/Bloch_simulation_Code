function B1_processingCode(imgDir)

T1w_mask = niftiread( char([imgDir, 'T1W_masked.nii'] ) );
B1_1 = niftiread( char([imgDir, 'B1.nii'] ) );

%% I am not sure what masked this, but we just need a reasonable skull strip
% I over erode and then dilate, so it should work within a reasonable
% margin of input quality

mask = zeros(size(T1w_mask));
thres = 0;
mask(T1w_mask > thres) = 1;

%figure; imshow3Dfullseg(double(T1w_mask), [0 3500], mask)

%% Erode then dilate the input B1 map
b1_proc = CR_b1_erode_dilate(double(B1_1).* mask, 7);

mask = ones(size(b1_proc));
mask(b1_proc == 0) = 0;

b1_s = CR_imgaussfilt3_withMask(double(b1_proc), mask, 5);


% % Viewing code for debugging:
% figure; imshow3Dfull(limitHandler(double(B1_1)./150, 0, 5), [0,2],jet)
% figure; imshow3Dfull(limitHandler(double(b1_proc)./150, 0, 5), [0,2],jet)
% figure; imshow3Dfull(limitHandler(double(b1_s)./150, 0, 5), [0,2],jet)


%% Taking some naming conventions from CR_GE_generate_R1_Volumes_v2.m
outputName = strcat(imgDir,'B1_map_proc.nii' );
niftiwrite(b1_s, char(outputName), Hdrinfo, 'Compressed',false);