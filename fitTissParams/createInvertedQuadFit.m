function [cVal, vertex] = createInvertedQuadFit(xData, yData, idx)

% Generated using CFtool, then modified.
% set X guess as starting guess for FWHM. gets around the different orders
% of magnitude we face with parameters.

% for T1D, we need to fit using the logarithm
if idx == 4
    xData = log10(xData);
elseif idx == 3
    xData = xData *10^6; % needed for fitting, matlab doesnt like small numbers.
elseif idx == 1 || idx ==5
    xData = xData *100; % needed for fitting, matlab doesnt like small numbers.
end


% Set up fittype and options.
ft = fittype( 'a*(x-h)^2 +k', 'independent', 'x', 'dependent', 'y' ); % vertex form of quadratic equation to constrain it
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 xData(1) 0];
opts.Robust = 'LAR';
opts.StartPoint = [1 xData(2) 2];
opts.Upper = [Inf max(xData) Inf];


% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );
cVal = coeffvalues(fitresult);

% vertex is our new x-guess
vertex = cVal(2);

% undo the log transform is used:
if idx == 4
    vertex = 10.^(vertex);
elseif idx == 3
    vertex = vertex /10^6; % needed for fitting, matlab doesnt like small numbers.
elseif idx == 1 || idx ==5
    vertex = vertex /100; % needed for fitting, matlab doesnt like small numbers.
end



% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'fitMetricY vs. x2', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% xlabel( 'x2', 'Interpreter', 'none' );
% ylabel( 'fitMetricY', 'Interpreter', 'none' );
% grid on



