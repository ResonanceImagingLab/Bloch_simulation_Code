function str = GenFlexible_MNI_KspaceMatrix( Params, MNISavDir, MNIdir )

% Here we modify the size of the MNI atlas to use for a specific imaging
% case for rescaling signal.

% requires 'minc_read'

% Inputs:
% SavDir -> location to save the segmentation and k-space files
% MNIdir -> the location of the MNI atlas files

% Then the different part of the Params Stucture that are needed:
% Params.Orientation -> Either 'Axial', 'Sagittal', 'Coronal'
% Params.NumLines -> 216;
% Params.NumPartitions -> 192; 
% Params.Slices -> 176; 

% Optional
% Params.SplitBrain = 1 or 0; odd ball situation if you image left and right separately


% MNIdir = 'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';
% SavDir = 'C:\Users\crowle1\OneDrive - McGill University\BipolarStudy\BlochSimSpoil\';
% Params.Orientation = 'Sagittal';
% Params.NumLines = 216;
% Params.NumPartitions = 192; 
% Params.Slices = 96; 
% Params.SplitBrain = 1;

%% Note that some terminology is inconsistent here. 
% For 3D imaging, you might/would encode slice and partition diection, and read
% along line direction. Generally the read direction would be one of the
% longer dimension. For this code, assume the 'slice' dimension is the
% readout direction. In an accelerated sequence like MPRAGE, the
% turbofactor should == partitions (or 1), and then set lines to the last
% free dimension that is accelerated over (such as for grappa)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


str = strcat('/NL',num2str(Params.NumLines), ...
    '_NP',num2str(Params.NumPartitions), ...
    '_NS',num2str(Params.Slices), ...
    '_BS',num2str(Params.SplitBrain) );


%% First check if the matrices have already been computed. Compute if they do not exist.
if ~isfile(strcat(MNISavDir,str,'/','brain_m.mat')) && ~isfile(strcat(MNISavDir,str,'/','fft_brain_m.mat'))

    %% Load the images
    mtw_fn = {'mni_icbm152_csf_tal_nlin_sym_09a.mnc';'mni_icbm152_gm_tal_nlin_sym_09a.mnc'; 'mni_icbm152_wm_tal_nlin_sym_09a.mnc';'DeepStructureMask.mnc'};
                                             
    for i = 1:length(mtw_fn)
        fn = strcat(MNIdir,mtw_fn{i});
        %[hdr, img] = niak_read_vol(fn);
        [~, img] = minc_read(fn);
        comb_mtw(:,:,:,i) = img; %.img;
    end
    
    %% reorient image:

    switch Params.Orientation
    case  'Axial'
        comb_mtw2 = permute(comb_mtw, [2,3,1,4]);
    case 'Sagittal'
        comb_mtw2 = permute(comb_mtw, [3,1,2,4]);
    case 'Coronal'
        comb_mtw2 = comb_mtw;
    otherwise 
        disp( 'Set Params.Orientation to either Axial, Sagittal, or Coronal')
    end
    
    
% You can check with this, again, we want 2nd dim to be the 'slices'. 3rd dim smallest(without reaason to not) 
%figure; imagesc(squeeze(comb_mtw2(:,120,:,1)  ))


    %% Change the matrix size to match acquired data
    [x,y,z,~] = size(comb_mtw2);
    
    % if one of the MNI dimensions is too small, zeropad that dimension
    padDim = ceil( [(Params.NumLines - x )/2, (Params.NumPartitions - y)/2, ...
            (Params.Slices - z)/2] );
    
    padDim( padDim<0) = 0;
    comb_mtw2 = padarray(comb_mtw2, padDim, 0, 'both');
    
    % Then crop the dimensions that exceed the acquired data
    [x,y,z,t] = size(comb_mtw2); % update size after padding
    comb_mtw3 = zeros( Params.NumLines,Params.NumPartitions,Params.Slices, t );
    ExDim = [ (x - Params.NumLines), (y - Params.NumPartitions), (z-Params.Slices) ];
    
    % Conditional loop for split brain as in Bock et al 2013, and cropping
    if ~isfield(Params, 'SplitBrain')
        Params.SplitBrain = 0;
    end
    
    
    if Params.SplitBrain && strcmp(Params.Orientation, 'Sagittal')
        % only do Split for Sagittal, with sagittal slices being the 2nd
        % dimension
    
        % We will need to weight the Z cropping to one side only, with some
        % overlap. 
    
        % Handle odd divisions
        overD = floor(ExDim/2);
        underD = ceil(ExDim/2);
    
        % Go 10 voxels overlap
        overD(2) = floor(y/2)+10;
        underD(2) = ceil(y/2)- Params.NumPartitions+10; 
    
        if underD(2) < 0
            Ex = -1*underD(2);
            underD(2) = 1;
            overD(2) = overD(2) + Ex;
        end
    
    
        comb_mtw3(:,:,:,:) = comb_mtw2( underD(1)+1:end-overD(1), ...
                        underD(2):overD(2),...
                        underD(3)+1:end-overD(3),...
                        :);
        
    
    elseif Params.SplitBrain
        error( 'Split Brain option only works for Sagittal Orientation')
    else
         
        % Handle odd divisions
        overD = floor(ExDim/2);
        underD = ceil(ExDim/2);
        
        comb_mtw3(:,:,:,:) = comb_mtw2( underD(1)+1:end-overD(1), ...
                        underD(2)+1:end-overD(2),underD(3)+1:end-overD(3), :);
    
    end
    
    
    % figure; imshow3Dfull(comb_mtw(:,:,:,3)  )
    comb_mtw = comb_mtw3;
    clearvars comb_mtw2 comb_mtw3;
    
    % Debugging:
    % figure; imshow3Dfull(comb_mtw(:,:,:,3)  )
    % figure; imagesc((comb_mtw(:,:,90,3)  ))

    
    %% Brain tissue:
    brain_m = zeros(size(comb_mtw(:,:,:,1)));
    brain_m(comb_mtw(:,:,:,2) >=0.05) = 1; % add extra, then remove
    brain_m(comb_mtw(:,:,:,3) >=0.05) = 1;
    fft_brain_m = fftshift(fftn(brain_m));
    
    %figure; imshow3Dfull( brain_m )
    
    % figure;
    % imagesc((brain_m(:,:,90)  ))
    % axis image
    % figure;
    % imagesc( squeeze(brain_m(:,90,:)  ))
    % axis image
    
    %% Generate save string based on image parameters:
        
    % Save brain_m and fft_brain_m
    mkdir([MNISavDir,str,'/'])
    
    save(strcat(MNISavDir,str,'/','brain_m.mat'),'brain_m')
    save(strcat(MNISavDir,str,'/','fft_brain_m.mat'),'fft_brain_m')

end









