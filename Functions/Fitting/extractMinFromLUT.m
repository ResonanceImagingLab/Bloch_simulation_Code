function [fitVal] = extractMinFromLUT(outVec,vq)

% This function takes in the gridded interpolant and parameter mesh
% and finds the parameters that give the minimum value. 

% Find the location of the minimum of vq.
% take abs, but we want closest to 0. Would only have negative values if
% fit was poor.
[~, idx] = min(abs(vq(:)));

% note the the paramMesh is built as a 1xN cell matrix.
% loop through and find the value for each cell structure.

fitVal = outVec(idx,:);


