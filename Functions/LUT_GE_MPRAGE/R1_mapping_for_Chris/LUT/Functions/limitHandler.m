function output = limitHandler(input, varargin)
% option to add in an upper and lower bound for thresholding. 

input(isinf(input)) = 0;
input(isnan(input)) = 0;
input = abs(input); % take care of complex

if nargin == 3 
    lowerLimit = varargin{1};
    upperLimit = varargin{2};
    
    input( input < lowerLimit) = lowerLimit;
    input( input > upperLimit) = upperLimit;
    
elseif nargin == 2
    lowerLimit = varargin{1};
    input( input < lowerLimit) = lowerLimit;
end

output = input;
