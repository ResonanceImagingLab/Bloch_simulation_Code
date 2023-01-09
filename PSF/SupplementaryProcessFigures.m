%% Generate process figure for supplementary

% Generate figures to show the processing steps from simulations to values

addpath(genpath( 'E:\GitHub\qMRLab-master'))
addpath(genpath('E:\GitHub\Bloch_simulation_Code'))

savDir = 'C:\Users\crowle1\OneDrive - McGill University\papers\Cortical_ihMT\Figures\SupplementaryFigures\processFig\';
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_image.mat'))
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_kspace.mat'))

mkdir(savDir)

% Get parameters
Params10 = CR_getSeqParams(10);
Params160 = CR_getSeqParams(160);

[SamplingTable10, ~, ~] = Step1_calculateKspaceSampling_v3 (Params10);
[SamplingTable160, ~, ~] = Step1_calculateKspaceSampling_v3 (Params160);

% Simulate sequence
sig10 = BlochSimFlashSequence_v2(Params10,'freqPattern', 'dualAlternate' ); 
sig160 = BlochSimFlashSequence_v2(Params160,'freqPattern', 'dualAlternate' ); 

% Calculate Value
sig10_v = CR_generate_BSF_scaling_v1( sig10, Params10,  SamplingTable10,  gm_m, fft_gm_m) ;  
sig160_v = CR_generate_BSF_scaling_v1( sig160, Params160, SamplingTable160, gm_m, fft_gm_m) ;

% Calculate MTsat
T1obs = 1.4.*1000;
M0_app = 1;
sat10 = calcMTsatThruLookupTablewithDummyV3( sig10_v, [], T1obs, [], M0_app,...
    Params10.echoSpacing * 1000,  Params10.numExcitation,  Params10.TR * 1000,...
    Params10.flipAngle,   Params10.DummyEcho);
sat160 = calcMTsatThruLookupTablewithDummyV3( sig160_v, [], T1obs, [], M0_app,...
    Params160.echoSpacing * 1000, Params160.numExcitation, Params160.TR * 1000,...
    Params160.flipAngle, Params160.DummyEcho);

% additional steps to get filled kspace for viewing
outKspace_s10 = CR_fillKspaceSamplingTable_v2( sig10, SamplingTable10, Params10);
outKspace_s160 = CR_fillKspaceSamplingTable_v2( sig160, SamplingTable160, Params160);

outKspace_s10 = CR_interpolateMissingGrappaLines( outKspace_s10);
outKspace_s160 = CR_interpolateMissingGrappaLines( outKspace_s160);

sim3d_m10 = repmat(outKspace_s10, [1,1,Params10.Slices]);
sim3d_m160 = repmat(outKspace_s160, [1,1,Params160.Slices]);

bsf_10 = sim3d_m10 .* fft_gm_m;
bsf_160 = sim3d_m160 .* fft_gm_m;

b_10 = abs(ifftn(ifftshift(bsf_10)));
b_160 = abs(ifftn(ifftshift(bsf_160)));

%% All values made, generate plots

% Plot signal over readout:
figure; scatter(1:10,sig10,70);
hold on; plot(1:10, sig10,'LineWidth',3,'Color','b');
xlim([0 11]);  ylim([0.041, 0.043]); 
xlabel('Excitation Number', "FontSize",18)
ylabel('M_{xy}', "FontSize",18)
ax = gca; ax.FontSize = 18; 
saveas(gcf,fullfile(savDir,'readoutSignal_TF10.png'))  

figure; scatter(1:160,sig160,70);
hold on; plot(1:160, sig160,'LineWidth',3,'Color','b');
xlim([0 161]);  ylim([0.015, 0.11]); 
xlabel('Excitation Number', "FontSize",18)
ylabel('M_{xy}', "FontSize",18)
ax = gca; ax.FontSize = 18; 
saveas(gcf,fullfile(savDir,'readoutSignal_TF160.png')) 


% Sampling tables:
viewResult = reshape(SamplingTable10, Params10.NumLines/Params10.AccelerationFactor +Params10.ReferenceLines, Params10.NumPartitions );
figure; imagesc( (viewResult));
axis image; colorbar; colormap(flipud(turbo))
set(gca,'XTick',[]); set(gca,'YTick',[]);
saveas(gcf,fullfile(savDir,'sampleTable_TF10.png'))  

viewResult = reshape(SamplingTable160, Params160.NumLines/Params160.AccelerationFactor +Params160.ReferenceLines, Params160.NumPartitions );
figure; imagesc( rot90(viewResult,2));
axis image; colorbar; colormap(flipud(turbo))
set(gca,'XTick',[]); set(gca,'YTick',[]);
saveas(gcf,fullfile(savDir,'sampleTable_TF160.png'))  
close all


% Filled K-space
figure; imagesc( (outKspace_s10));
axis image; colorbar; colormap(parula)
set(gca,'XTick',[]); set(gca,'YTick',[]);
caxis([0.041, 0.043])
saveas(gcf,fullfile(savDir,'filledKspace_TF10.png'))  

figure; imagesc( rot90(outKspace_s160,2));
axis image; colorbar; colormap(parula)
set(gca,'XTick',[]); set(gca,'YTick',[]);
caxis([0.015, 0.11])
saveas(gcf,fullfile(savDir,'filledKspace_TF160.png'))  


% Show the segmentation images used
slice = 90;
figure; imagesc( rot90( squeeze(gm_m(:,slice,:)),2));
axis image; colormap(gray);set(gca,'XTick',[]); set(gca,'YTick',[]);
saveas(gcf,fullfile(savDir,'mni_seg_mid.png'))  

slice = 96;
figure; imagesc( abs(rot90( squeeze(log10(fft_gm_m(:,:,slice))),2)));
axis image; colormap(gray);set(gca,'XTick',[]); set(gca,'YTick',[]);
saveas(gcf,fullfile(savDir,'mni_fft_seg_mid.png'))  



% Filled kspace images now filtered by segmentation
temp = abs(rot90( squeeze(log10(bsf_10(:,:,slice))),2));
temp(isinf(temp)) = 0;
figure; imagesc( temp);
axis image; colorbar; colormap(parula);caxis([0, 3.5])
set(gca,'XTick',[]); set(gca,'YTick',[]);
saveas(gcf,fullfile(savDir,'filledKspace_filter_TF10.png'))  

temp = abs(rot90( squeeze(log10(bsf_160(:,:,slice))),2));
temp(isinf(temp)) = 0;
figure; imagesc( temp);
axis image; colorbar; colormap(parula);caxis([0, 3.5])
set(gca,'XTick',[]); set(gca,'YTick',[]);
saveas(gcf,fullfile(savDir,'filledKspace_filter_TF160.png'))  


% View resulting image:
slice = 90;
figure; imagesc( rot90( squeeze(b_10(:,slice,:)),2));
axis image; colormap(gray);set(gca,'XTick',[]); set(gca,'YTick',[]);
caxis([0, 0.045]); colorbar; colormap("hot")
saveas(gcf,fullfile(savDir,'sim_img_TF10.png'))  

figure; imagesc( rot90( squeeze(b_160(:,slice,:)),2));
axis image; colormap(gray);set(gca,'XTick',[]); set(gca,'YTick',[]);
caxis([0, 0.11]); colorbar; colormap("hot")
saveas(gcf,fullfile(savDir,'sim_img_TF160.png')) 





































