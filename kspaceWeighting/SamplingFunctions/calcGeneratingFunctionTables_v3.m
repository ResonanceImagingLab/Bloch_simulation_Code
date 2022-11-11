function [FinalMat, m_iNumberOfMeasuredElements, iSegments] = calcGeneratingFunctionTables_v3(AngleOrderFunc, RadiusOrderFunc, iNumElements, iTurboFactor, mask) 
%v3 sort by angle and fill by radius
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
iSegments = ceil(m_iNumberOfMeasuredElements ./  iTurboFactor);


%% Divide up kspace by angle
% map can remain unmasked for now. 
angleSeg = -1*ones(size(AngleOrderFunc));
AngleOrderMask = AngleOrderFunc;
AngleOrderMask(mask == 0) = 1000;

[~, sortIdx] = sort(AngleOrderMask);

id1 = 1;
id2 = iTurboFactor;

for i = 1:iSegments
    % edge case for last segment
    if (id2 > length(AngleOrderFunc))
        id2 = length(AngleOrderFunc);
    end

    angleSeg(sortIdx(id1:id2)) = i;
    id1 = id2;
    id2 = id2+ iTurboFactor;
end


%% Fill by Radius

FinalMat = zeros(size(RadiusOrderFunc));

% for each segment
for i = 1:iSegments

    % Easiest way is to use find on whole matrix. So set values we don't
    % want included very high.
    temp = RadiusOrderFunc;
    temp(angleSeg ~= i) = 1e5;
    [~, sortIdx] = sort(temp);

    % fill them by their order in the sort. 
    for j = 1:iTurboFactor
        FinalMat(sortIdx(j)) = j;
    end
end

% 
% viewResult = reshape(angleSeg,iNumLines,iNumPartitions);
% figure; imagesc(viewResult); axis image; colorbar; colormap('jet'); %ax = gca; ax.CLim = [0 9];
% 
% viewResult = reshape(FinalMat,iNumLines,iNumPartitions);
% figure; imagesc(viewResult); axis image; colorbar; colormap('jet'); %ax = gca; ax.CLim = [0 9];






