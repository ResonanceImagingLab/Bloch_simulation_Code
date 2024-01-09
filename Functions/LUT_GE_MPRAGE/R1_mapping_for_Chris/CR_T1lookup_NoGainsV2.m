% V3 is PSF based for PDw and T1w

% Goal of this is to calculate the T1 from a
% T1w MPRAGE and a  PD-weighted flash image
% For now, we assume the MPRAGE (BRAVO) is centric encoded
% and thus we incorporate a PSF based correction for image intensities


function [T1] = CR_T1lookup_NoGainsV2( PDw,PDwInfo, T1w, T1wInfo, b1,  mask)
% Output should be in milliseconds.

%% Inputs
% PDw -> PDw signal, or the denominator of the ratio
% PDwInfo -> structure containing flipAngle (degrees) and TR
% T1w -> T1w signal, or the numerator of the ratio
% T1wInfo -> structure containing flipAngle (degrees), TI, TR, echospacing, turbofactor, dummyEchoes
% b1 -> relative B1 field
% PDw_transmitGain ; T1w_analogGain, T1w_receiveGain, T1w_transmitGain 
% B1_transmitGain
% mask is an optional entry.If not used, enter []

% PDw = PD_L;
% T1w = T1W_L; 
% T1wInfo = T1wInfoL;
% b1 =  B1_L;
% gainStruct = gainStructOnes;
% mask = [];

%PD_L, PDwInfo, T1W_L, T1wInfoL, B1_L, gainStructOnes, [] 


% Next report errors if missing data on image structures
if ~isfield(PDwInfo, 'TR');          error('Missing PDw TR');          end
if ~isfield(PDwInfo, 'flipAngle'); error('Missing PDw flipAngle'); end

if ~isfield(T1wInfo, 'TR');                    error('Missing T1wInfo TR'); end
if ~isfield(T1wInfo, 'flipAngle');           error('Missing T1wInfo flipAngle'); end
if ~isfield(T1wInfo, 'TI');                     error('Missing T1wInfo TI'); end
if ~isfield(T1wInfo, 'echospacing');    error('Missing T1wInfo echospacing'); end
if ~isfield(T1wInfo, 'turbofactor');      error('Missing T1wInfo turbofactor'); end
if ~isfield(T1wInfo, 'dummyEchoes'); error('Missing T1wInfo dummyEchoes'); end


%% Temp values:
% T1wInfo.flipAngle   =  12;
% T1wInfo.echospacing   =  7.916;
% T1wInfo.turbofactor   =   98;
% T1wInfo.dummyEchoes   =  2 ;
% T1wInfo.TI   =  1100;
% T1wInfo.TD   =  1000;
% T1wInfo.TR   =     T1wInfo.TI  + T1wInfo.TD + T1wInfo.echospacing*T1wInfo.turbofactor ;
% T1wInfo.Ordering = 'centric';
% PDwInfo.TR   =    7.908  ;
% PDwInfo.flipAngle   =     4 ;


%% Generate a lookup table based on B1, T1 and Transmit gains for each scan

% We need a table where the entries are the T1 values
% for each of the metrics, determine the ratio signal
% Then interpolate from a ratio value vector to get T1s 

B1_vector = 0.4:0.02:1.8; % get B1 contour map style artifact in sat maps with higher increment

% For interpolation:
Ratio_vector = linspace(0.5, 2, 100); % can increase for precision?
T1_vector = [0.4:0.05:1.8] *1000; % Densely sampled near region of interest
T1Matrix = zeros(length(B1_vector), length(Ratio_vector));

MPRAGE = zeros(length(B1_vector), length(T1_vector));
FLASH = zeros(length(B1_vector), length(T1_vector));

tic
% calculate the lookup table
% takes about 0.5 seconds to generate
RatioValue = zeros(length(B1_vector), length(T1_vector));
T1wInfo.M0a = 1;
PDwInfo.M0a = 1;
PDwInfo.numExcitation = 1;

B1_scale = 1; % Munsch et al 2021 mentioned a 95% b1 scaling for GE maps, upscale the lookup table to avoid downscaling values
for i = 1:length(B1_vector)
    
        T1wInfo.b1 = B1_vector(i)*B1_scale;
        PDwInfo.b1 = B1_vector(i)*B1_scale;
        
        for  m = 1:length(T1_vector)

            % Set M0 to 1 because it doesn't matter for ratio

          %% Solve PD-w FLASH signal 
            % set up reference K-space and pad array for nicer PSF
%             FlashVal = CR_FLASH_solver(PDwInfo.flipAngle, PDwInfo.TR, B1_vector(i) , 1, T1_vector(m) );
%             
            PDwInfo.R1obs =  1./T1_vector(m);    
            FLASH(i,m)  = MAMT_model_simPDflash(PDwInfo);
          
            

          %%  Solve MPRAGE signal 
            % Pull the full magnetization

            T1wInfo.R1obs = 1./T1_vector(m);   
            MPRAGE_vector = MAMT_model_simT1wHC_Bock(T1wInfo);
            
            MPRAGE(i,m) = MPRAGE_vector(1);   % integrate to get cumulative signal
          
            RatioValue(i,m) = MPRAGE(i,m) / FLASH(i,m);


        end    

        % Use the ratio value and vector to get T1 values. 
         T1Matrix(i,:) = interp1( RatioValue(i,:) , T1_vector, Ratio_vector );  %, 'pchip' -> gives completely different answer...
                
end
toc

%% Sample view resulting Lookup table results
% temp = T1Matrix;
% % temp(temp <= 0) = NaN;
% % temp(temp > 2000) = NaN;
% [xx, yy] = meshgrid (B1_vector, Ratio_vector); 
% figure; surf( xx, yy, temp');
% xlabel('B1')
% ylabel('ratio')
% zlabel('T1')
% 
% 
% % 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now use the lookup table to fit the input data

%  fit the image using gridded interpolant
[b, n] = ndgrid(B1_vector, Ratio_vector );
F = griddedInterpolant(b , n, T1Matrix);

%% Turn the images into vectors then fit

if isempty(mask)
    mask = ones(size(PDw));
end

q = find( (mask(:)>0));
b1_v = abs(b1(q));
signal_v = abs(T1w(q)./ PDw(q));


t1_v = F(b1_v,  signal_v);

T1 = zeros( size(PDw));
T1(q) = t1_v;


% %% Compare against the long way....
% 
% for i =1:  length (q)
%     t1_2_v = CR_T1mappingLookup_PDw_T1wHC( b1_v(i), signal_v(i), RatioValue);
% end
% 
% T1_2 = zeros( size(PDw));
% T1_2(q) = t1_2_v;










