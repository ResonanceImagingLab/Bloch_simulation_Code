%% Compare gain factor:

% from this, it looks like the scaling from the combined MPRAGE to PDw (2*MPRAGE/PDw ) is
% 0.8947, split into 2. So PDw image has gain fact *2.23 compared to
% MPRAGE.

DataDir = 'C:\Users\chris\Downloads\TravelBrains\Mac\MPRAGE';

imgName = {'T1w.nii', 'T1WLC.nii', 'MPRAGE.nii', 'B1_1.nii'};

for i = 1:length(imgName)
    img(:,:,:,i) = niftiread(fullfile(DataDir,imgName{i}));
end

img = double(img);

%% Load each image and display

t1w = img(:,:,:,1);
pdw = img(:,:,:,2);
mpr = img(:,:,:,3);
b1 = img(:,:,:,4)/150;

figure; imagesc(t1w(:,:,100));colormap('gray')
figure; imagesc(pdw(:,:,100));colormap('gray')
figure; imagesc(mpr(:,:,100));colormap('gray')
figure; imagesc(b1(:,:,160));colormap('turbo')

mask = zeros(size(t1w));


nbins = 200;

figure;
histogram(t1w(mask >0),nbins,'FaceAlpha',0.3)
hold on
histogram(pdw(mask >0),nbins,'FaceAlpha',0.3)
xlim([0 150])

ylim([0 0.2e6])
legend

%T1w center = 850
%Pwd center = 1050;



%% Do a better job with a fit:
mask = zeros(size(t1w));
mask(t1w<75) = 1;
mask(pdw>75) = 0;
mask(t1w<=0) = 0;
mask(pdw<=0) = 0;

nbins = 25;

[N1,edges1] = histcounts(t1w(mask >0),nbins);
[N2,edges2] = histcounts(pdw(mask >0),nbins);

c1 = (edges1(2:end)+edges1(1:end-1))/2; 
c2 = (edges2(2:end)+edges2(1:end-1))/2; 


histogram(t1w(mask >0),nbins,'FaceAlpha',0.3)

cftool

%spline fit, and find max:
xfit = linspace(0,50, 200);
SplineFit = fit(c1', N1', 'smoothingspline');
y1= feval(SplineFit,xfit);
xmax = xfit(y1 ==max(y1));


SplineFit2 = fit(c2', N2', 'smoothingspline');
y2= feval(SplineFit2,xfit);
xmax2 = xfit(y2 ==max(y2));

scalingFactor = xmax/xmax2




