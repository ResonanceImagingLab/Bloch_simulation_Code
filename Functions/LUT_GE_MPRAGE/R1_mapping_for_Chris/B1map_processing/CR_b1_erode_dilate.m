function b1_proc2 = CR_b1_erode_dilate(MaskedB1, erodeDepth)

% With some B1 mapping techniques, we get issues around the edge of the cortex
% Here we will first erode the masked B1 map by erodeDepth voxels
% Next we will loop through, and fill voxels with the median of the
% non-zero neighbouring voxels within square with length 2*erodeDepth.
% This should extend just past the original mask.

% Suggested erode depth is 7 for B1 maps upsampled to 1mm isotropic.

% MaskedB1 = double(B1).* mask;
% erodeDepth = 7;

tic 

[x,y,z] = size(MaskedB1);
mask = ones(x,y,z);
mask(MaskedB1 == 0) = 0;

%figure; imshow3Dfullseg(T1w_mask,[0, 4000], mask)

maskEr = imerode( mask, strel("sphere",erodeDepth));

% figure; imshow3Dfullseg(T1w_mask,[0, 4000], maskEr)

b1_erode = MaskedB1 .* maskEr;
b1_proc = b1_erode;

%% we need to make sure that we refill all the eroded voxels
erodeDepth = erodeDepth+2;
for i = 1:x
    for j = 1:y
        for k = 1:z
            if (b1_erode(i,j,k) == 0 && mask(i,j,k) == 1)
                boxLowLimits = [i - erodeDepth, j-erodeDepth, k-erodeDepth]; 
                boxHighLimits = [i + erodeDepth, j+erodeDepth, k+erodeDepth]; 
    
                boxLowLimits(boxLowLimits < 1) = 1; % edge case correction
                boxHighLimits = min(boxHighLimits, [x,y,z]);
                    
                vals = MaskedB1(boxLowLimits(1):boxHighLimits(1),...
                    boxLowLimits(2):boxHighLimits(2), boxLowLimits(3):boxHighLimits(3));

                %vals = vals(vals >0.5 & vals < 2.5);

                if ~isempty(vals)
                    b1_proc(i,j,k) = median( vals(:) );
                end
            end
        end
    end
end

% figure; imshow3Dfullseg(b1_proc,[0, 4000], maskEr)

%% Run through one more time, this should catch the regions of excessive erosion. 
erodeDepth = erodeDepth+3;
b1_proc2 = b1_proc;

for i = 1:x
    for j = 1:y
        for k = 1:z
            if (b1_proc(i,j,k) == 0 && mask(i,j,k) == 1)
                boxLowLimits = [i - erodeDepth, j-erodeDepth, k-erodeDepth]; 
                boxHighLimits = [i + erodeDepth, j+erodeDepth, k+erodeDepth]; 
    
                boxLowLimits(boxLowLimits < 1) = 1; % edge case correction
                boxHighLimits = min(boxHighLimits, [x,y,z]);
                    
                vals = MaskedB1(boxLowLimits(1):boxHighLimits(1),...
                    boxLowLimits(2):boxHighLimits(2), boxLowLimits(3):boxHighLimits(3));

                %vals = vals(vals >0.5 & vals < 2.5);

                if ~isempty(vals)
                    b1_proc2(i,j,k) = median( vals(:) );
                end
            end
        end
    end
end

disp('B1 image erode and dilate finished');
toc



