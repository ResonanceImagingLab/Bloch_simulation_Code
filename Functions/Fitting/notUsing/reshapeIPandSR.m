function [iP, SR] = reshapeIPandSR(inputParams, StandardizedResidudals, gridvec)

% Reshapes the inputParams and Standardized Residuals into an N-D
% array to be fit by griddedInterpolant

fitSz = length(gridvec);

% get size of each cell
gsc = cellfun(@size,gridvec,'UniformOutput',false);

gs = zeros(1,fitSz);
for i = 1:fitSz
    gs(i) = max(gsc{1,i});
end


%% Now do the reshaping
for i = 1:fitSz
    iP{1,i} = reshape(inputParams(:,i),gs ); 
end

SR = reshape(StandardizedResidudals,gs );
