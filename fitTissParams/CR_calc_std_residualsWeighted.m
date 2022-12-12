function  std_resid = CR_calc_std_residualsWeighted( Xval2fit, Yval2fit, fitCoeffMat)

% Since the curves are fixed to start towards 0, the higher x points give
% us more information. So we will weight our fit based on x^3.

N_vals = length( Yval2fit ); % for normaliztion

Val_mean = mean( Yval2fit ,'omitnan');
Val_devsq = sum( (Yval2fit - Val_mean).^2); % sum of the squared difference from mean.
Val_lev = (1/N_vals) + ( (Yval2fit - Val_mean).^2 )./  Val_devsq; % should get a vector length (val2fit) for leverage

std_resid = zeros( length(fitCoeffMat),  1);

[x, y] = size(fitCoeffMat);

if min([x,y]) == 1
    y_fit = polyval(fitCoeffMat ,Xval2fit); % calculate fit curve
    resid = (y_fit-Yval2fit); % residuals between fit curve and data points
    s_Error = sqrt( (1/(N_vals-1)) * sum(resid.^2) ); % standard error
    std_resid = sum( Xval2fit.^3 .* sqrt( (resid.^2) ./ (s_Error .* (1- Val_lev)) ) ); % standardized residuals
else
    for i = 1:length(fitCoeffMat) 
        
        y_fit = polyval(fitCoeffMat(i,:) ,Xval2fit); % calculate fit curve
        resid = (y_fit-Yval2fit); % residuals between fit curve and data points
        s_Error = sqrt( (1/(N_vals-1)) * sum(resid.^2) ); % standard error
        std_resid(i) = sum(Xval2fit.^3 .* sqrt( (resid.^2) ./ (s_Error .* (1- Val_lev)) ) ); % standardized residuals
    end
end



%Yval2fit = fitData(i,:);
% Xval2fit = fitData(10,:);