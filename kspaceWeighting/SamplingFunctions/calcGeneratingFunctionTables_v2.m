function [FinalMat, m_iNumberOfMeasuredElements, iSegments] = calcGeneratingFunctionTables_v2( raiOrderGeneratingFunction, iNumElements, iTurboFactor, mask) 
%v2 just sorts by radius

%% Check the number of lines left after using the IPAT mask
maskedElements = 0;
for i = 1:iNumElements
    if mask(i) == 0
        maskedElements = maskedElements+1;
    end
end
    
m_iNumberOfMeasuredElements = iNumElements - maskedElements;

% Sort out the segmentation based on remaining lines
iSegments = floor(m_iNumberOfMeasuredElements ./  iTurboFactor);

% Sort Radius
temp = raiOrderGeneratingFunction;
temp(mask<1) = 100000;
[~,sortRadius] = sort(temp);


FinalMat = zeros(size(raiOrderGeneratingFunction));

idxStart = 1;
for i = 1:iTurboFactor
    idxEnd = idxStart+iSegments; % everything in segement gets same value

    if idxEnd > m_iNumberOfMeasuredElements % == iTurboFactor
        idxEnd = m_iNumberOfMeasuredElements; % might not be full division
    end
    
    FinalMat(sortRadius(idxStart:idxEnd)) = i;
    
    idxStart = idxEnd +1;
end


FinalMat(mask == 0 ) = 0;


% viewResult = reshape(FinalMat,iNumLines,iNumPartitions);
% figure; imagesc(viewResult); axis image; colorbar; colormap('jet'); %ax = gca; ax.CLim = [0 9];
% 
% 
% 
% viewResult = reshape(sortRadius,iNumLines,iNumPartitions);
% figure; imagesc(viewResult); axis image; colorbar; colormap('jet');% ax = gca; ax.CLim = [0 80];








