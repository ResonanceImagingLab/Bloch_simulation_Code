function img_s = CR_imgaussfilt3_withMask(img, mask, fwhm)

% goal of this function is to do smoothing within a mask, which helps when
% you might have boundary issues in an image. 
% This smoothing takes a weighted average of the voxels as defined by a 
% gaussian with width 2*'fwhm'. Voxels where mask <1 get set to NaN before
% the nanmean command is called. 

% This is a quick and dirty function for now, Can be optimized for speed
% later. 

% Christopher Rowley, 2022. 


%% Start by generating the 3D gaussian:
fwhm  = round(fwhm); % ensure round number
f_w = [2*fwhm-1 2*fwhm-1 2*fwhm-1]; % basic symmetric filter

% need the size to be odd, if even add one.
%f_w( rem(f_w, 2) == 0) = 2*fwhm - 1;

H = fspecial3('gaussian', f_w, fwhm);

%figure; imshow3Dfull( H, [0 1], jet)


%% mask the values in image
img(mask < 1) = NaN;
img(img <0.5) = NaN; % fix issue with siemens double angle data in the CSF.

%% Need to pad the image

img_p = padarray( img, f_w, NaN);

%% Easiest to just do triple nested for loop
[x, y, z] = size(img);
img_s = zeros(x, y, z);


tic 
for i = 1: x
    for j = 1: y
        for k = 1: z
            
            if mask(i,j,k) > 0 
                crp_img = img_p(i+f_w(1):i+2*f_w(1)-1 , j+f_w(3):j+2*f_w(2)-1, k+f_w(3):k+2*f_w(3)-1);


                 % weighted average
                val = sum( crp_img .* H ,'all','omitnan') / ...
                    sum( H.*(~isnan(crp_img)) ,'all');

                if val > 0  %||  ~isnan(val) % second condition shouldn't be needed based on what how nanmean works.
                    img_s(i,j,k) = val;
                end
            end
        end
    end
end
toc



% figure; imshow3Dfullseg( img, [0 600], mask1)
% figure; imshow3Dfullseg( img_s, [0 600], mask1)













