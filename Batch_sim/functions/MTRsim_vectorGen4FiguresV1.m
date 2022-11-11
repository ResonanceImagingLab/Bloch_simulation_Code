function [xVect1, yVect1, zEff1, zEff2, zEff3, zEff4, zEff5, ...
    xVect2, yVect2, zAbs1, zAbs2, zAbs3, zAbs4, zAbs5] = ...
    MTRsim_vectorGen4FiguresV4( x , xidx, y, yidx, zidx, simResults )


% this function takes your inputs and extracts the max values for plotting
% a grid

% Inputs
% x = first sorting vector (such as TR)
% xidx = the column number that x is in the simResults table
% y = second sorting vector (such as number of excitations)
% yidx = the column number that y is in the simResults table
% zidx = 4 number vector that contains the column numbers/index for ...
%             [MTR proxy, MTR proxy efficiency, MTRsat, MTRsat
%             efficiency]  (example [10,16,14,17])


% Outputs
% xVect is the output vector sorted for x dim
% yVect is the output vector sorted for y dim
% zEff1 is the contrast efficiency sorted to match xVect and yVect
% zAbs1 is the contrast efficiency sorted to match xVect and yVect 
% zEff2 is the MTRsat efficiency sorted to match xVect and yVect
% zAbs2 is the MTRsat efficiency sorted to match xVect and yVect
% And so on... check variable names below for rest of values




% find the max value (column 1), matrix idx (column 2)
MTR_maxAbs = zeros( length(x), length(y) );
MTR_maxEff = zeros( length(x), length(y));
MTR_maxAbsSat = zeros( length(x), length(y) );
MTR_maxEffSat = zeros( length(x), length(y));
MTR_maxAbs = zeros( length(x), length(y) );
MTR_maxEff = zeros( length(x), length(y));
MTRsnr_maxAbs = zeros( length(x), length(y) );
MTRsnr_maxEff = zeros( length(x), length(y));
MTRsatsnr_maxAbs = zeros( length(x), length(y) );
MTRsatsnr_maxEff = zeros( length(x), length(y));

for i = 1:length(x) % stack x in the 3rd dimension
   
    temp1 = simResults(simResults(:,xidx)== x(i),: );
    
    for j = 1:length(y) % for each simulated number of excitations per offset Resonance
        
        temp2 = temp1(temp1(:,yidx)== y(j),: );
        
        if ~isempty(temp2) % incorparating time restrictions makes this necessary
            MTR_maxAbs( i, j ) = max(temp2( :, zidx(1) )); % max MTR for selected excitation number       
            MTR_maxEff( i, j )  = max(temp2( :, zidx(2) )); % max MTR for selected excitation number  
            MTR_maxAbsSat( i, j ) = max(temp2( :, zidx(3) )); % max MTR for selected excitation number       
            MTR_maxEffSat( i, j )  = max(temp2( :, zidx(4) )); % max MTR for selected excitation number 
            MTR_maxAbs( i, j ) = max(temp2( :, zidx(5) )); % max MTR for selected excitation number       
            MTR_maxEff( i, j )  = max(temp2( :, zidx(6) )); % max MTR for selected excitation number  
            MTRsnr_maxAbs( i, j ) = max(temp2( :, zidx(7) )); % max MTR for selected excitation number       
            MTRsnr_maxEff( i, j )  = max(temp2( :, zidx(8) )); % max MTR for selected excitation number  
            MTRsatsnr_maxAbs( i, j ) = max(temp2( :, zidx(9) )); % max MTR for selected excitation number       
            MTRsatsnr_maxEff( i, j )  = max(temp2( :, zidx(10) )); % max MTR for selected excitation number  
        end
    end    
end


%% build vectors for First set (MTR proxy)

xVect1 = repmat(x', 1, length(y) );
yVect1 = repmat(y, length(x), 1);

xVect1 = xVect1(:);
yVect1 = yVect1(:);
zEff1 = MTR_maxEff(:);
zEff2 = MTR_maxEffSat(:);
zEff3 = MTR_maxEff(:);
zEff4 = MTRsnr_maxEff(:);
zEff5 = MTRsatsnr_maxEff(:);

% remove zeros 
xVect1( zEff1 == 0) = [];
yVect1( zEff1 == 0) = [];
zEff2( zEff1 == 0) = [];
zEff3( zEff1 == 0) = [];
zEff4( zEff1 == 0) = [];
zEff5( zEff1 == 0) = [];
zEff1( zEff1 == 0) = [];


%% For the second set (MTR sat)
xVect2 = repmat(x', 1, length(y) );
yVect2 = repmat(y, length(x), 1);

xVect2 = xVect2(:);
yVect2 = yVect2(:);
zAbs1 = MTR_maxAbs(:);
zAbs2 = MTR_maxAbsSat(:);
zAbs3 = MTR_maxAbs(:);
zAbs4 = MTRsnr_maxAbs(:);
zAbs5 = MTRsatsnr_maxAbs(:);

% remove zeros 
xVect2( zAbs1 == 0) = [];
yVect2( zAbs1 == 0) = [];
zAbs2( zAbs1 == 0) = [];
zAbs3( zAbs1 == 0) = [];
zAbs4( zAbs1 == 0) = [];
zAbs5( zAbs1 == 0) = [];
zAbs1( zAbs1 == 0) = [];












