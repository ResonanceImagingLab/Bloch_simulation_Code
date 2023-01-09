function [outputSamplingTable, measuredElem, iSegments] = Step1_calculateKspaceSampling_v3 (Params)

%% Note that some terminology is inconsistent here. 
% For 3D imaging, you might/would encode slice and partition diection, and read
% along line direction. Generally the read direction would be one of the
% longer dimension. For this code, assume the 'slice' dimension is the
% readout direction. In an accelerated sequence like MPRAGE, the
% turbofactor should == partitions (or 1), and then set lines to the last
% free dimension that is accelerated over (such as for grappa)

if min( [Params.NumLines, Params.NumPartitions]) > Params.Slices
    disp('Open this function for notes on how to properly define image dimensions. Generally set Partitions to be smallest dimension here')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Params.Grappa
    iNumLines        = Params.NumLines/Params.AccelerationFactor +Params.ReferenceLines; 
else
    iNumLines        = Params.NumLines;
end

%% Added for consistency with previous code
if ~isfield(Params, 'ellipMask')
    Params.ellipMask = 1;
end

if ~isfield(Params, 'Readout')
    Params.Readout = 'centric';
end

if ~isfield(Params, 'TurboFactor')
    Params.TurboFactor = Params.numExcitation;
end

%%
iNumPartitions   = Params.NumPartitions; 
iCenterLine      = floor(iNumLines/2 );
iCenterPartition = floor(iNumPartitions/2);
iTurboFactor     = Params.TurboFactor; 
iNumElements     = double(iNumLines*iNumPartitions);

if strcmp(Params.Readout, 'centric')


    %% first generate the segmentation and order generating functions
    [AngleOrderFunc, RadiusOrderFunc] = GeneratePieSegFunOrdFun(iNumLines, iNumPartitions, iCenterLine, iCenterPartition, iNumElements);
    
    %% second, use the above functoins to generate the order table:
    
    if Params.ellipMask
        A = ellipMask([iCenterLine*1.02 iCenterPartition*1.02], [iNumLines iNumPartitions], [iCenterLine iCenterPartition]) ;
        mask = A(:);
    else
        mask = ones(size(RadiusOrderFunc));   
    end
    
    [outputSamplingTable, measuredElem, iSegments] = calcGeneratingFunctionTables_v3(AngleOrderFunc, RadiusOrderFunc,iNumElements,iTurboFactor,mask);
    outputSamplingTable(mask == 0) = 0;

elseif strcmp(Params.Readout, 'linear')

    if Params.ellipMask
        disp('No elliptical masking with linear encoding. Assuming no elliptical mask')
    end

    if (iNumPartitions ~= iTurboFactor) && (iTurboFactor ~= 1)
        error('No segmentation for linear encoding. Might need to swap lines and partitions or check other parameters.')
    end

    if iTurboFactor == 1
        outputSamplingTable = ones(1,iNumElements);
        
    elseif iTurboFactor == iNumPartitions % other option leading to error already sorted above
        outputSamplingTable = repmat(1:iTurboFactor,[iNumLines,1]);
    end

    outputSamplingTable = outputSamplingTable(:);

    measuredElem = iNumElements ; % Equivalent with no elliptical mask
    iSegments = iNumPartitions; % Assuming no segmentation in linear ordering.

else
    error( 'Readout must be either linear or centric')
end




%% Can check results using

% viewResult = reshape(outputSamplingTable, Params.NumLines/Params.AccelerationFactor +Params.ReferenceLines, Params.NumPartitions );
% figure; imagesc( viewResult);
% axis image; colorbar;

% viewResult = reshape(outputSamplingTable,iNumLines,iNumPartitions);
% figure;
% imagesc(viewResult)
% axis image
% %caxis([0 15])
% colormap(jet)


% viewResult = reshape( AngleOrderFunc,iNumLines,iNumPartitions);
% figure;
% imagesc(viewResult)
% axis image
% 
% viewResult = reshape(outputSamplingTable,iNumLines,iNumPartitions);
% figure;
% imagesc(viewResult)
% axis image

