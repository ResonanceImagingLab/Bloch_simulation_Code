% Generate_GM_WM_kspaceMatrices

DATADIR = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';

%DATADIR = '/data_/tardiflab/chris/development/scripts/Deichman2000_backup/cortical_ihMT_sim/kspaceWeighting/mni_icbm152_nlin_sym_09a_minc2/';

%image names:
% in the order of dual, hfa, neg, lfa, pos
mtw_fn = {'mni_icbm152_csf_tal_nlin_sym_09a.mnc';'mni_icbm152_gm_tal_nlin_sym_09a.mnc'; 'mni_icbm152_wm_tal_nlin_sym_09a.mnc'};
                                         
% load images
%comb_mtw = zeros(224, 256, 176, 18);

for i = 1:length(mtw_fn)
    fn = strcat(DATADIR,mtw_fn{i});
    %[hdr, img] = niak_read_vol(fn);
    [hdr, img] = minc_read(fn);
    comb_mtw(:,:,:,i) = img; %.img;
end

%figure; imshow3Dfull(comb_mtw(:,:,:,1)  )

[x,y,z] = size(comb_mtw(:,:,:,1));


%% Pre-emptively change the matrix size to match what I collected (176x216x192)

comb_mtw2 = zeros( 176,216,192,length(mtw_fn) );
comb_mtw2(:,:,2:190,:) = comb_mtw( 11:186 , 9:224,:, :);

[x,y,z] = size(comb_mtw2(:,:,:,1));

comb_mtw = comb_mtw2;
clearvars comb_mtw2;

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

[x,y,z] = size(comb_mtw2(:,:,:,1));

comb_mtw = comb_mtw2;
clearvars comb_mtw2;

% %% Pull tissue classes
% csf_m = zeros(x,y,z);
% csf_m(comb_mtw(:,:,:,1) >=0.3) = 1;
% figure; imshow3Dfull( csf_m )
% 
% 
% 
% figure; imshow3Dfull(comb_mtw(:,:,:,3)  )
% wm_m = zeros(x,y,z);
% wm_m(comb_mtw(:,:,:,3) >=0.5) = 1;
% figure; imshow3Dfull( wm_m )
% 
% 
% gm_m = zeros(x,y,z);
% gm_m(comb_mtw(:,:,:,2) >=0.3) = 1; % add extra, then remove
% gm_m(csf_m >0) = 0; % remove CSF
% gm_m(wm_m >0) = 0; % remove CSF
% figure; imshow3Dfull( gm_m )
% 
% %% Save results.
% save( strcat(DATADIR,'CSF_seg_MNI_152_image.mat'), 'csf_m')
% save( strcat(DATADIR,'WM_seg_MNI_152_image.mat'), 'wm_m')
% save( strcat(DATADIR,'GM_seg_MNI_152_image.mat'), 'gm_m')
% 
% save( strcat(DATADIR,'CSF_seg_MNI_152_kspace.mat'), 'fft_csf_m')
% save( strcat(DATADIR,'WM_seg_MNI_152_kspace.mat'), 'fft_wm_m')
% save( strcat(DATADIR,'GM_seg_MNI_152_kspace.mat'), 'fft_gm_m')



%% Get the fourier daata
% csf_fft_m = fftshift(fftn(csf_m));
% wm_fft_m = fftshift(fftn(wm_m));
% gm_fft_m = fftshift(fftn(gm_m));

%% Brain tissue:
brain_m = zeros(x,y,z);
brain_m(comb_mtw(:,:,:,2) >=0.05) = 1; % add extra, then remove
brain_m(comb_mtw(:,:,:,3) >=0.05) = 1;

figure; imshow3Dfull( brain_m )


fft_brain_m = fftshift(fftn(brain_m));
gm_m = brain_m;
fft_gm_m = fft_brain_m;

%% Save results.

save( strcat(DATADIR,'GM_seg_MNI_152_image.mat'), 'gm_m')

save( strcat(DATADIR,'GM_seg_MNI_152_kspace.mat'), 'fft_gm_m')








