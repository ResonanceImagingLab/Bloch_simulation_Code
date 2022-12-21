function mapCDATA = CR_CIFTIcdata(inputCdata, inputLength, vertlist)

% this script solves the issue of loaded CDATA not being the same size as
% the surface. Need to dlabel (or cdata) values using the CIFTI matlab code found here
% (https://github.com/Washington-University/cifti-matlab)

% inputCdata = l_L2.cdata;
% inputLength = 32492; % the intended length of the surface
% vertlist = l_L2.diminfo{1,1}.models{1,1}.vertlist; % this cifti load code
% has the mapping required for this.


mapCDATA = zeros(inputLength,1);

for i = 1:length(inputCdata)
    idx = vertlist(i)+1; % their counting starts at 0
    mapCDATA(idx) = inputCdata(i);
end
