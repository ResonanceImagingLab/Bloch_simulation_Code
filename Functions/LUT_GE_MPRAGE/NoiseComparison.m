%% Compare gain factor:

% from this, it looks like the scaling from the combined MPRAGE to PDw (2*MPRAGE/PDw ) is
% 2.14 or ~2

DataDir = 'C:\Users\chris\Downloads\TravelBrains\Mac\MPRAGE';

imgName = {'T1w_masked.nii', 'T1WLC.nii', 'T1WHC.nii', 'B1.nii',...
    'B1_EPI.nii', 'ratio.nii'};

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

mask = ones(size(mpr));
mask(mpr> 400) = 0;
mask(pdw> 400) = 0;


nbins = 200;

figure;
histogram(mpr(mask >0),nbins,'FaceAlpha',0.3)
hold on
histogram(pdw(mask >0),nbins,'FaceAlpha',0.3)
xlim([-50 450])

ylim([0 0.2e6])
legend

%T1w center = 850
%Pwd center = 1050;



%% Do a better job with a fit:
mask = zeros(size(mpr));
mask(mpr<100) = 1;
mask(pdw>100) = 0;
mask(mpr<=0) = 0;
mask(pdw<=0) = 0;

nbins = 25;

[N1,edges1] = histcounts(mpr(mask >0),nbins);
[N2,edges2] = histcounts(pdw(mask >0),nbins);

c1 = (edges1(2:end)+edges1(1:end-1))/2; 
c2 = (edges2(2:end)+edges2(1:end-1))/2; 


figure;histogram(mpr(mask >0),nbins,'FaceAlpha',0.3)
figure; histogram(pdw(mask >0),nbins,'FaceAlpha',0.3)

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




