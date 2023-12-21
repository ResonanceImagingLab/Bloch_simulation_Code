img = 'C:\Users\chris\Downloads\Re_inhomogeneitycorrection\B1_map.nii.gz';
b1 = niftiread(img);


img = 'C:\Users\chris\Downloads\Re_inhomogeneitycorrection\cf_maps.nii.gz';
cf = niftiread(img);

img = 'C:\Users\chris\Downloads\Re_inhomogeneitycorrection\MTsat_single_echo_B1_corrected.nii.gz';
mtc = niftiread(img);

img = 'C:\Users\chris\Downloads\Re_inhomogeneitycorrection\MTsat_sp.nii.gz';
mt = niftiread(img);

img = 'C:\Users\chris\Downloads\Re_inhomogeneitycorrection\R1obs.nii.gz';
R12 = niftiread(img);



figure; imshow3Dfull(b1, [0.6 1.2],jet)
figure; imshow3Dfull( cf(:,:,:,1), [-0.3, 0.3], turbo  );
figure; imshow3Dfull( cf(:,:,:,2), [-0.3, 0.3], turbo  );
figure; imshow3Dfull( cf(:,:,:,3), [-0.3, 0.3], turbo  );
figure; imshow3Dfull( mtc/100, [0 0.06],jet  )
figure; imshow3Dfull( mt/100, [0 0.06],jet  )
% figure; imshow3Dfull( R12, [1/2, 1/0.95],jet  );


T1 = 1./R12;
T1 = limitHandler(T1, 0, 4);


figure; imshow3Dfull( T1*1000, [800 1600],jet  )

figure; imshow3Dfull( R1*1000, [1/2, 1/0.95],jet  );

figure; imshow3Dfull( R1*1000, [1/2, 1/0.65],jet  );

%% Temp load minc

imgDir='C:\Users\chris\OneDrive - McMaster University\MRI\MRI_data';
file_name = fullfile(imgDir, 'ee20231031_01037_20231031_091646_29d1_mri.mnc' );
% [hdr,vol] = minc_read(file_name);
vol = h5read(file_name,'/minc-2.0/image/0/image');
vol = double(vol); % Convert everything to double to avoid problems, even if that's dirty

figure; imshow3Dfull( vol, [400, 1200], turbo); 

file_name = fullfile(imgDir, 'ee20231031_01037_20231031_091646_30d1_mri.mnc.gz' );

