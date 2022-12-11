function fitMetric = fitPolyComputeInnerProd(sigL, sigM, sigH, fitData, b1Field)

% sigL, sigM and sigH hold sat values, need to fit each with a 3th degree
% polynomial. Then evaluate that polynomial using the fitData points.
% b1Field is the B1 values corresponding to sigL...


% sigL -> each row is a separate B1 relative value,
% with six columns for the 6 different sequences

% Need to add 1 to the MTsat values so that they are above 1. Otherwise the
% logic wont work, and the values get smaller.

fit_degree = 3;


fitMetric = zeros(3,6); % ultimately, we will want to sum across sequences, but can do later

% loop over each sequence, with a row for low, middle and high estimates.

for i = 1:6     
     % With B1's simulated ->Fit polynomial: 
     fitCoeffMat = polyfit(b1Field, sigL(:,i), fit_degree);
     y_fit = polyval(fitCoeffMat ,fitData(10,:)); % calculate fit curve
     fitMetric(1,i) = dot(1+y_fit, 1+fitData(i,:));

     fitCoeffMat = polyfit(b1Field, sigM(:,i), fit_degree);
     y_fit = polyval(fitCoeffMat ,fitData(10,:)); % calculate fit curve
     fitMetric(2,i) = dot(1+y_fit, fitData(i,:));

     fitCoeffMat = polyfit(b1Field, sigH(:,i), fit_degree);
     y_fit = polyval(fitCoeffMat ,fitData(10,:)); % calculate fit curve
     fitMetric(3,i) = dot(1+y_fit, 1+fitData(i,:));
end











