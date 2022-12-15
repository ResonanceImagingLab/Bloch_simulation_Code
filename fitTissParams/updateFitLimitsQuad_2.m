function  [lowerLimit,highLimit, vertex] = updateFitLimitsQuad_2(vertex, lowerLimit,...
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


hiDif =  highLimit(idx) - vertex;
lowdif = vertex - lowerLimit(idx);

lowerLimit(idx) = lowerLimit(idx) + 0.15*lowdif;
highLimit(idx) = highLimit(idx) - 0.15*hiDif;


% undo log transform
if idx == 4
    lowerLimit(idx) = 10.^(lowerLimit(idx));
    highLimit(idx) = 10.^(highLimit(idx));
    vertex = 10.^(vertex);
end

