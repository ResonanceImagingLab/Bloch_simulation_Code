function LUT = compute_2pt_inversion_LUT_1pool(T1wInfo, PDwInfo, LUT_str, LUTsavDir, T1w_b, T1w_fftb)
% function LUT = compute_2pt_inversion_LUT_1pool(T1wInfo, PDwInfo, T1w_b, T1w_fftb, PDw_b, PDw_fftb, LUT_str, LUTsavDir)

% function builds a lookup table for T1map calculation using a T1w and PDw image.
% Assumption here is that T1w image is an MPRAGE, and the PDw image is FLASH/GRE.


% LUT = compute_2pt_inversion_LUT(T1wInfo, PDwInfo, T1w_b.brain_m, T1w_fftb.fft_brain_m,...
%         PDw_b.brain_m, PDw_fftb.fft_brain_m, LUT_str, LUTsavDir);


if ~exist(LUTsavDir, 'dir')
    disp('save directory does not exist...')
    disp(['making directory:', LUTsavDir])
    mkdir(LUTsavDir) 
end

if ~exist(strcat(LUTsavDir,'Figures/'), 'dir')
    mkdir(strcat(LUTsavDir,'Figures/'))
end


% For varying echotimes:
if ~isfield(T1wInfo,'TE') 
    T1wInfo.TE = 0;
end
if ~isfield(PDwInfo,'TE') 
    PDwInfo.TE = 0;
end

if ~isfield(T1wInfo,'R2star') 
    T1wInfo.R2star = 1/60e-3;
end
if ~isfield(PDwInfo,'R2star') 
    PDwInfo.R2star = 1/60e-3;
end

%% Generate a sampling table for T1w and PDw images.

%PDwSamplingTable = Step1_calculateKspaceSampling_v3 (PDwInfo);

%% There are 2 dummy echoes at the end, so lets crop it. We need
% them in the simulation above though, but simulation code references
% T1wInfo.numExcitation
if T1wInfo.TurboFactor == 98
        T1wInfo.TurboFactor = 96;
end

T1wSamplingTable = []; 
if (LUT_str(1:3) == "GE2")
    T1wSamplingTable = Step1_calculateKspaceSampling_v3 (T1wInfo);
end


%% The output LUT is the gridded interpolant of simulation values.
B1_vector = 0.6:0.025:2; % get B1 contour map style artifact in sat maps with higher increment

% For interpolation:
Ratio_vector = linspace(0.01, 3.5, 70); % can increase for precision?
T1_vector = (0.4:0.05:2.5) *1000; % Densely sampled near region of interest
T1Matrix = zeros(length(B1_vector), length(Ratio_vector));

tic
% calculate the lookup table
RatioValue = zeros(length(B1_vector), length(T1_vector));

for i = 1:length(B1_vector)           
    parfor  m = 1:length(T1_vector)

        % Simulate PDw for set B1 and T1

        FLASH_vector = BlochSimFlashSequence_1pool(PDwInfo, 'flipAngle',...
                B1_vector(i)*PDwInfo.flipAngle,...
                'Raobs', 1./T1_vector(m)*1000 );

        FLASH = FLASH_vector*exp(-PDwInfo.TE *PDwInfo.R2star);

         % only one value for flash, so return that
        %FLASH = CR_generate_BSF_scaling_v1( FLASH_vector, PDwInfo, PDwSamplingTable, PDw_b, PDw_fftb);  
        
        % Solve MPRAGE signal for set B1 and T1
        MPRAGE_vector = BlochSim_MPRAGESequence_1pool(T1wInfo, 'flipAngle',...
                B1_vector(i)*T1wInfo.flipAngle,...
                'Raobs', 1./T1_vector(m)*1000 );

        % There are 2 dummy echoes at the end, so lets crop it. We need
        % them in the simulation above though!
        if (T1wInfo.numExcitation - T1wInfo.TurboFactor) == 2
            MPRAGE_vector = MPRAGE_vector(1:end-2);
        end

        MPRAGE_vector = MPRAGE_vector*exp(-T1wInfo.TE *T1wInfo.R2star);

        % Weird scaling at McMaster, like the image recon is rescaling the
        % image
        if strcmp(T1wInfo.Readout, 'centric')
            if (LUT_str(1:3) == "GE1")
                MPRAGE_v = MPRAGE_vector(1); 
            else % dal and calgary
                MPRAGE_v = CR_generate_BSF_scaling_v1( MPRAGE_vector, T1wInfo, T1wSamplingTable, T1w_b.brain_m, T1w_fftb.fft_brain_m); 
            end

        else % assume linear encoding
            MPRAGE_v = MPRAGE_vector(round(length(MPRAGE_vector)/2)); 
        end   
        
        RatioValue(i,m) = MPRAGE_v / FLASH;

    end   

    % Use the ratio value and vector to get T1 values. 
    T1Matrix(i,:) = interp1( RatioValue(i,:) , T1_vector, Ratio_vector );  %, 'pchip' -> gives completely different answer...
                
end
toc


%% Now use the lookup table to fit the input data

%  fit the image using gridded interpolant
[b, n] = ndgrid(B1_vector, Ratio_vector );
LUT = griddedInterpolant(b , n, T1Matrix);

save(strcat(LUTsavDir,LUT_str,'.mat'),'LUT') % save this just incase I change it at some point...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sample view resulting Lookup table results
[xx, yy] = ndgrid (B1_vector, Ratio_vector); 
temp = LUT(xx,  yy);

figure; s = surf( xx, yy, temp);
xlabel('B_1^+')
ylabel('Ratio')
zlabel('T_{1,obs} (ms)')
ax = gca; ax.FontSize = 20; 
set(gcf,'Position',[100 100 1000 800])
view(-120,20)
%[az,el] = view

saveas(gcf,strcat(LUTsavDir,'Figures/',LUT_str,'.png'))


%% USE THIS FOR VISUALIZING THE OUTPUT/INTERPOLATION
% temp = T1Matrix;
% % temp(temp <= 0) = NaN;
% % temp(temp > 2000) = NaN;
% [xx, yy] = meshgrid (B1_vector, Ratio_vector); 
% figure; surf( xx, yy, temp');
% xlabel('B1')
% ylabel('ratio')
% zlabel('T1')


% [xx, yy] = meshgrid (B1_vector, T1_vector); 
% figure; surf( xx, yy, MPRAGE'./FLASH');
% xlabel('B1')
% ylabel('T1')
% zlabel('ratio')
% 
% figure; surf( xx, yy, MPRAGE');
% xlabel('B1')
% ylabel('T1')
% zlabel('ratio')
% 
% figure; surf( xx, yy, FLASH');
% xlabel('B1')
% ylabel('T1')
% zlabel('ratio')



    














