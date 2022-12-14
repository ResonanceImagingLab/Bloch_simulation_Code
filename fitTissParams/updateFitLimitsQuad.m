function  [lowerLimit,highLimit, vertex] = updateFitLimitsQuad(vertex, lowerLimit,...
                     highLimit, currX, idx)

% currently not using the fit curve/ The curvature could be used to let us
% know how aggressively to move the end points. I am avoiding that for now
% to try and limit the chance of falling into a local minimum based on a
% single variable.

% get an issue with some of these parameters changing non-linearly in
% realistic since. So log scale T1D for this.
if idx == 4
    vertex = log10(vertex);
    currX = log10(currX);
    lowerLimit(idx) = log10(lowerLimit(idx));
    highLimit(idx) = log10(highLimit(idx));
end

% if vertex is outside limits, reset to the middle:
if (vertex <= lowerLimit(idx)) | (vertex >= highLimit(idx))
    vertex = (highLimit(idx)+lowerLimit(idx)) /2;
end

%% we have three cases, vertex is to left, centered or to right currX
% if guess is to left, then move high limit 
if currX > vertex
    highLimit(idx) = vertex+ 0.75*(highLimit(idx)-vertex);

%     L1 = vertex- abs(0.9*(vertex-lowerLimit(idx)));
%     L2 = lowerLimit(idx) + abs(0.05* lowerLimit(idx));
%     lowerLimit(idx) = min([L1,L2]);

% if guess is centered, move both (unlikely)
elseif currX == vertex
    L1 = vertex- abs(0.85*(vertex-lowerLimit(idx)));
    L2 = lowerLimit(idx) + abs(0.05* lowerLimit(idx));
    lowerLimit(idx) = min([L1,L2]);
    
    H1 = vertex+ abs(0.85*(highLimit(idx)-vertex));
    H2 = highLimit(idx) - abs(0.05* highLimit(idx));
    highLimit(idx) = max([H1,H2]);

% if guess is right, move low limit. 
else 

    lowerLimit(idx) = vertex- abs(0.75*(vertex-lowerLimit(idx)));

%     H1 = vertex+ abs(0.9*(highLimit(idx)-vertex));
%     H2 = highLimit(idx) - abs(0.05* highLimit(idx));
%     highLimit(idx) = max([H1,H2]);

end

% undo log transform
if idx == 4
    lowerLimit(idx) = 10.^(lowerLimit(idx));
    highLimit(idx) = 10.^(highLimit(idx));
    vertex = 10.^(vertex);
end




