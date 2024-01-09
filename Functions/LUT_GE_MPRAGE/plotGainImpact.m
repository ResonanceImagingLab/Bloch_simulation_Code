 
 

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
Params.TissueType = 'GM';
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

% lutPrefix = 'MAC_MPR_';
% LUT_str = strcat(lutPrefix, Readout, '_TI', num2str(TI), '_TR',num2str(TR), '_flip',num2str(t1flip), ...
%         '_echoSp',num2str(echoSpacing), '_turbofact',num2str(numExcitation),'_TE',num2str(t1TE), ...
%         '_pdTR',num2str(pdTR), '_pdflip',num2str(pdflip), '_TE',num2str(pdTE) );

% Located in: 'E:\Github\Bloch_simulation_Code\Functions\LUT_GE_MPRAGE\R1_mapping_for_Chris\LUT_files_t2_80ms'
load('centric_TI1.1_TR2.8754_flip12_echoSp0.007912_turbofact98_pdTR0.007908_pdflip4.mat')

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

    ratioV(m) = MPRAGE_vector(1)/FLASH;
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
title('Fit R_1')

% Find where R1map == r1rg
match = abs(r1rG - R1map/1000);

mins = min(match,[],1);
R1sMatch = find(abs(r1rG - R1map/1000) == mins); 
temp = zeros(size(r1rG));
temp(R1sMatch) = 1;


%arrayfun(@(s) set(s,'EdgeColor','none'), findobj(gcf,'type','surface'))


































