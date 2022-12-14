function cVal = createGaussFit(xData, yData, maxDot)

% Generated using CFtool, then modified.

%[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [maxDot xData(1) 0];
opts.StartPoint = [maxDot xData(2) 30];
opts.Upper = [maxDot xData(3) Inf];

% Fit model to data.
[fitresult, ~] = fit( xData, yData, ft, opts );
cVal = coeffvalues(fitresult);

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% xlabel( 'x', 'Interpreter', 'none' );
% ylabel( 'y', 'Interpreter', 'none' );
% grid on


