%% Adjust matrix

Params.Orientation = 'Sagittal';
% Part one, fix the GM k-space weighting so that you get results that
% match... Use sim values to see what I am expecting to get, and then
% modify until I get that...

% Location of MNI atlas tissue probability map
DATADIR = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';

% Load the maps
mtw_fn = {'mni_icbm152_csf_tal_nlin_sym_09a.mnc';'mni_icbm152_gm_tal_nlin_sym_09a.mnc'; 'mni_icbm152_wm_tal_nlin_sym_09a.mnc';'DeepStructureMask.mnc'};
                                         
% load images
clear comb_mtw;

for i = 1:length(mtw_fn)
    fn = strcat(DATADIR,mtw_fn{i});
    %[hdr, img] = niak_read_vol(fn);
    [hdr, img] = minc_read(fn);
    comb_mtw(:,:,:,i) = img; %.img;
end

%% Change the matrix size to match what I collected (176x216x192)
comb_mtw2 = zeros( 176,216,192,length(mtw_fn) );
comb_mtw2(:,:,2:190,:) = comb_mtw( 11:186 , 9:224,:, :);

%figure; imshow3Dfull(comb_mtw2(:,:,:,3)  )
comb_mtw = comb_mtw2;
clearvars comb_mtw2;


% reorient image:
switch Params.Orientation

    case  'Axial'
        comb_mtw2 = comb_mtw; % already in this 
    case 'Sagittal'
        comb_mtw2 = permute(comb_mtw, [2,3,1,4]);
    case 'Coronal'
        comb_mtw2 = permute(comb_mtw, [3,1,2,4]);
    otherwise 
        disp( 'Set Params.Orientation to either Axial, Sagittal, or Coronal')
end


figure; imshow3Dfull(comb_mtw2(:,:,:,1)  )

[x,y,z] = size(comb_mtw2(:,:,:,1));

comb_mtw = comb_mtw2;
clearvars comb_mtw2;

%% Pull tissue classes
csf_m = zeros(x,y,z);
csf_m(comb_mtw(:,:,:,1) >=0.3) = 1;
%figure; imshow3Dfull( csf_m )

%figure; imshow3Dfull(comb_mtw(:,:,:,3)  )
wm_m = zeros(x,y,z);
wm_m(comb_mtw(:,:,:,3) >=0.1) = 1;
% figure; imshow3Dfull( wm_m )

dilSz = 5;
[xx,yy,zz] = ndgrid(-dilSz:dilSz);
nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= dilSz;
wm_m = imdilate(wm_m,nhood);


gm_m = zeros(x,y,z);
gm_m(comb_mtw(:,:,:,2) >=0.3) = 1; % add extra, then remove
gm_m(csf_m >0) = 0; % remove CSF
gm_m(wm_m >0) = 0; % remove CSF
gm_m(comb_mtw(:,:,:,4) > 0) = 0;


gm_m = zeros(x,y,z);
% try one that is just the brain:
gm_m(comb_mtw(:,:,:,2) >=0.1) = 1;
gm_m(wm_m >0) = 1; 
gm_m(comb_mtw(:,:,:,4) > 0) = 0;

dilSz = 5;
[xx,yy,zz] = ndgrid(-dilSz:dilSz);
nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= dilSz;
gm_m = imdilate(gm_m,nhood);

figure; imshow3Dfull( gm_m )

% fft_csf_m = fftshift(fftn(csf_m));
% fft_wm_m = fftshift(fftn(wm_m));
fft_gm_m = fftshift(fftn(gm_m));

%figure; imshow3Dfull( abs(log(fft_gm_m)) )

%% Brain tissue:
brain_m = zeros(x,y,z);
brain_m(comb_mtw(:,:,:,2) >=0.1) = 1; % add extra, then remove
brain_m(comb_mtw(:,:,:,3) >=0.1) = 1;
fft_brain_m = fftshift(fftn(brain_m));
figure; imshow3Dfull( brain_m )

gm_m = brain_m;
fft_gm_m = fft_brain_m;

%% Test how it transfers to signal
Dual_sig1_gm = zeros( 1, length(B1rms));
Dual_sig2_gm = zeros( 1, length(B1rms));
Dual_sig3_gm = zeros( 1, length(B1rms));

parfor j = 1:length(B1rms)
    Dual_sig1_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig1(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;
    Dual_sig2_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig2(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m);
    Dual_sig3_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig3(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;  
end

%% Calculate MTsat on the whole matrix of signal values.
T1obs = ones(size(Dual_sig1_gm)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig1_gm))*1 ;

MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( Dual_sig2_gm,   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( Dual_sig3_gm,   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);

%% Fit the data
fit_degree = 7;
 Dual_c1   = polyfit(B1rms, MTsat_sim_Dual1, fit_degree);
 Dual_c2   = polyfit(B1rms, MTsat_sim_Dual2, fit_degree);
 Dual_c3   = polyfit(B1rms, MTsat_sim_Dual3, fit_degree);

%% Plot data
SortIndex = 1;% sortidx(1); % select the sorted line you want
x1_line = linspace(0,18,100);
y1 = polyval( Dual_c1(SortIndex,:), x1_line);
y2 = polyval( Dual_c2(SortIndex,:), x1_line);
y3 = polyval( Dual_c3(SortIndex,:), x1_line);

str = ['R = ',num2str(R),', T2a = ',num2str(T2a),...
    ', T1D = ',num2str( T1D), ', T2b =',num2str(T2b),...
    ', M0b = ',num2str(M0b ),', R1b = ',num2str(R1b )];

figure;
% subplot(1,2,1)
heatscatter(b1_1', mat_ss(4,:)' ); 
hold on
heatscatter(b1_2', mat_ss(5,:)' ); 
heatscatter(b1_3', mat_ss(6,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
colorbar off
ax = gca; ax.FontSize = 20; 
title(str,'FontSize',14);
hold off
ylim([0 0.3]) ;
set(gcf,'position',[10,400,800,600])   











































%% Part two, need to adjust this to pad/crop to a given image size.


Params.NumLines = 216;
Params.NumPartitions = 192; 
Params.Slices = 176;
Params.Grappa = 1;
Params.ReferenceLines = 32;
Params.AccelerationFactor = 2;
Params.Segments = []; 
Params.TurboFactor = Params.numExcitation- Params.DummyEcho;
Params.ellipMask = 1;
[outputSamplingTable, ~, Params.Segments] = Step1_calculateKspaceSampling_v3 (Params);

%% Will need to know if transverse, saggital or coronal to permute
% Pre-emptively change the matrix size to match what I collected (176x216x192)
comb_mtw2 = zeros( 176,216,192,length(mtw_fn) );
comb_mtw2(:,:,2:190,:) = comb_mtw( 11:186 , 9:224,:, :);

[x,y,z] = size(comb_mtw2(:,:,:,1));

comb_mtw = comb_mtw2;
clearvars comb_mtw2;





















