 
 

% One thing I though might be useful is to make a plot showing how the 
% scaling factor on the input images affects the calculated R1.  

% then contours showing different actual R1s.  
% My guess from Stella’s results are that the slopes of the contours will be 
% fairly linear across the scaling factors we are using, but that different 
% contours have different slopes (Which argues why we can’t just use a global 
% scaling factor and our results are improved if we use region-specific ones. 
% It also argues why using a per-region SITE term in our statistical model 
% fixed things up perfectly well).
 

%It would have calculated R1 on the y-axis, scaling factor on the x-axis, 

Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'WM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultGEparamObject(Params);


checkGEparamObject_MPRAGE(T1wInfo, PDwInfo );

% Extract imaging params.
TI = T1wInfo.TI;
echoSpacing = T1wInfo.echoSpacing;
numExcitation = T1wInfo.numExcitation;
Readout = T1wInfo.Readout;
TR = T1wInfo.TR;
t1TE = T1wInfo.TE;
t1flip = T1wInfo.flipAngle;
pdTR = PDwInfo.TR;
pdflip = PDwInfo.flipAngle;
pdTE = PDwInfo.TE;

lutPrefix = 'MAC_MPR_';
LUT_str = strcat(lutPrefix, Readout, '_TI', num2str(TI), '_TR',num2str(TR), '_flip',num2str(t1flip), ...
        '_echoSp',num2str(echoSpacing), '_turbofact',num2str(numExcitation),'_TE',num2str(t1TE), ...
        '_pdTR',num2str(pdTR), '_pdflip',num2str(pdflip), '_TE',num2str(pdTE) );

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

if T1wInfo.TurboFactor == 98
        T1wInfo.TurboFactor = 96;
end


%% Not sure where this is saved
% LUT = load(fullfile(LUTsavDir, strcat(LUT_str,'.mat')));
% LUT = LUT.LUT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Need to fit something
% we want to show that some scaling applied to the ratio

% For a range of R1, simulate the sequence. Get the ratio values
R1v = linspace(1/3.5, 1/0.6, 30);
ratioV = zeros(size(R1v));

for  m = 1:length(R1v)
    FLASH_vector = BlochSimFlashSequence_1pool(PDwInfo,'Raobs', R1v(m) );

    FLASH = FLASH_vector*exp(-PDwInfo.TE *PDwInfo.R2star);

    MPRAGE_vector = BlochSim_MPRAGESequence_1pool(T1wInfo, 'Raobs', R1v(m) );

    ratioV(m) = FLASH/MPRAGE_vector(10);
end

% From those ratio values corresponding to T1's, plug into LUT.
% Make image of ratio values: 
gainFv = linspace(0.9, 1.1, 40);
[rr, ~] = ndgrid(ratioV, gainFv);
[r1r, gg] = ndgrid(R1v, gainFv);

% apply scaling:
rg = rr.*gg;
mask = ones(size(rg));


q = find( (mask(:)>0));
b1_v = (mask(q)); % just want ones for this, only investigating scale factor
signal_v = rg(:);
r1r = r1r(:);

t1_v = LUT(b1_v,  signal_v);
%t1_v(isnan(t1_v)) = 0;
R1map = zeros( size(rg));
R1map(q) = t1_v;
r1rG = zeros( size(rg));
r1rG(q) = r1r;

figure;
surf( r1rG, gg, R1map/1000, 'EdgeColor','none') %,'FaceColor','interp')
hold on
contour3(r1rG, gg, R1map/1000, 10, '-k', 'LineWidth',1)  
xlabel('Input R1 (1/s)', 'FontSize',18);
ylabel('Gain', 'FontSize',18);
ax = gca;    ax.FontSize = 18;
colorbar('eastoutside')
set(gcf,'Position',[100 100 800 600])
view(0,90)

% Find where R1map == r1rg
match = abs(r1rG - R1map/1000);

mins = min(match,[],1);
R1sMatch = find(abs(r1rG - R1map/1000) == mins); 
temp = zeros(size(r1rG));
temp(R1sMatch) = 1;


%arrayfun(@(s) set(s,'EdgeColor','none'), findobj(gcf,'type','surface'))










B1_vector = 1; % get B1 contour map style artifact in sat maps with higher increment

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

        MPRAGE_v = MPRAGE_vector(1); 
        RatioValue(i,m) = MPRAGE_v / FLASH;

    end   

    % Use the ratio value and vector to get T1 values. 
    T1Matrix(i,:) = interp1( RatioValue(i,:) , T1_vector, Ratio_vector );  %, 'pchip' -> gives completely different answer...
                
end
toc


























