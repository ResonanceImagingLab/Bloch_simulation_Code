function    [lowerLimit,highLimit] = updateFitLimits(cVal, lowerLimit, highLimit, idx)

% use the fit values to update the fit.

% Taken from here( https://www.mathworks.com/matlabcentral/answers/499451-gaussian-fit-to-xy-data-and-extracting-fwhm) 
% we can get the FWHM as:

FWHM = 2*sqrt(log(2))*cVal(3);

newLow = cVal(2) - 0.5*FWHM;
newHigh = cVal(2) + 0.5*FWHM;

% Want to converge, so do not allow the limits to move further outwards
if newLow < lowerLimit(idx)
    newLow = lowerLimit(idx);
elseif newHigh > highLimit(idx)
    newHigh = highLimit(idx);
end

lowerLimit(idx) = newLow;
highLimit(idx) = newHigh;