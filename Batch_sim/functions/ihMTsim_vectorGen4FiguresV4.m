function [xVect1, yVect1, zEff1, zEff2, zEff3, zEff4, zEff5, ...
    xVect2, yVect2, zAbs1, zAbs2, zAbs3, zAbs4, zAbs5] = ...
    ihMTsim_vectorGen4FiguresV4( x , xidx, y, yidx, zidx, simResults )

% v4 add support for ihMTsat SNR and ihMTsat SNR eff
% v3 add support for ihMTR, and ihMTR_SNR exports 4x vector
% zidx should be 1x8 vector. 

% this function takes your inputs and extracts the max values for plotting
% a grid

% Inputs
% x = first sorting vector (such as TR)
% xidx = the column number that x is in the simResults table
% y = second sorting vector (such as number of excitations)
% yidx = the column number that y is in the simResults table
% zidx = 4 number vector that contains the column numbers/index for ...
%             [ihMT proxy, ihMT proxy efficiency, ihMTsat, ihMTsat
%             efficiency]  (example [10,16,14,17])


% Outputs
% xVect is the output vector sorted for x dim
% yVect is the output vector sorted for y dim
% zEff1 is the contrast efficiency sorted to match xVect and yVect
% zAbs1 is the contrast efficiency sorted to match xVect and yVect 
% zEff2 is the ihMTsat efficiency sorted to match xVect and yVect
% zAbs2 is the ihMTsat efficiency sorted to match xVect and yVect
% And so on... check variable names below for rest of values




% find the max value (column 1), matrix idx (column 2)
ihMT_maxAbs = zeros( length(x), length(y) );
ihMT_maxEff = zeros( length(x), length(y));
ihMT_maxAbsSat = zeros( length(x), length(y) );
ihMT_maxEffSat = zeros( length(x), length(y));
ihMTR_maxAbs = zeros( length(x), length(y) );
ihMTR_maxEff = zeros( length(x), length(y));
ihMTRsnr_maxAbs = zeros( length(x), length(y) );
ihMTRsnr_maxEff = zeros( length(x), length(y));
ihMTsatsnr_maxAbs = zeros( length(x), length(y) );
ihMTsatsnr_maxEff = zeros( length(x), length(y));

for i = 1:length(x) % stack x in the 3rd dimension
   
    temp1 = simResults(simResults(:,xidx)== x(i),: );
    
    for j = 1:length(y) % for each simulated number of excitations per offset Resonance
        
        temp2 = temp1(temp1(:,yidx)== y(j),: );
        
        if ~isempty(temp2) % incorparating time restrictions makes this necessary
            ihMT_maxAbs( i, j ) = max(temp2( :, zidx(1) )); % max ihMT for selected excitation number       
            ihMT_maxEff( i, j )  = max(temp2( :, zidx(2) )); % max ihMT for selected excitation number  
            ihMT_maxAbsSat( i, j ) = max(temp2( :, zidx(3) )); % max ihMT for selected excitation number       
            ihMT_maxEffSat( i, j )  = max(temp2( :, zidx(4) )); % max ihMT for selected excitation number 
            ihMTR_maxAbs( i, j ) = max(temp2( :, zidx(5) )); % max ihMT for selected excitation number       
            ihMTR_maxEff( i, j )  = max(temp2( :, zidx(6) )); % max ihMT for selected excitation number  
            ihMTRsnr_maxAbs( i, j ) = max(temp2( :, zidx(7) )); % max ihMT for selected excitation number       
            ihMTRsnr_maxEff( i, j )  = max(temp2( :, zidx(8) )); % max ihMT for selected excitation number  
            ihMTsatsnr_maxAbs( i, j ) = max(temp2( :, zidx(9) )); % max ihMT for selected excitation number       
            ihMTsatsnr_maxEff( i, j )  = max(temp2( :, zidx(10) )); % max ihMT for selected excitation number  
        end
    end    
end


%% build vectors for First set (ihMT proxy)

xVect1 = repmat(x', 1, length(y) );
yVect1 = repmat(y, length(x), 1);

xVect1 = xVect1(:);
yVect1 = yVect1(:);
zEff1 = ihMT_maxEff(:);
zEff2 = ihMT_maxEffSat(:);
zEff3 = ihMTR_maxEff(:);
zEff4 = ihMTRsnr_maxEff(:);
zEff5 = ihMTsatsnr_maxEff(:);

% remove zeros 
xVect1( zEff1 == 0) = [];
yVect1( zEff1 == 0) = [];
zEff2( zEff1 == 0) = [];
zEff3( zEff1 == 0) = [];
zEff4( zEff1 == 0) = [];
zEff5( zEff1 == 0) = [];
zEff1( zEff1 == 0) = [];


%% For the second set (ihMT sat)
xVect2 = repmat(x', 1, length(y) );
yVect2 = repmat(y, length(x), 1);

xVect2 = xVect2(:);
yVect2 = yVect2(:);
zAbs1 = ihMT_maxAbs(:);
zAbs2 = ihMT_maxAbsSat(:);
zAbs3 = ihMTR_maxAbs(:);
zAbs4 = ihMTRsnr_maxAbs(:);
zAbs5 = ihMTsatsnr_maxAbs(:);

% remove zeros 
xVect2( zAbs1 == 0) = [];
yVect2( zAbs1 == 0) = [];
zAbs2( zAbs1 == 0) = [];
zAbs3( zAbs1 == 0) = [];
zAbs4( zAbs1 == 0) = [];
zAbs5( zAbs1 == 0) = [];
zAbs1( zAbs1 == 0) = [];












