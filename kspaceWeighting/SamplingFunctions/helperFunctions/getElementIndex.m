% helper function for converting to and from 1D to 2D arrays
function idx = getElementIndex(line,part, iNumLines)
% looped through lines (inner), then partition (outer)
    idx = (part-1)*iNumLines + line;