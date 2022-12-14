function fitMetric = fitPolyCompute4StdResid(sigL, sigM, sigH, sigMH,...
                                        fitData, b1Field)

% sigL, sigM and sigH hold sat values, need to fit each with a 3th degree
% polynomial. Then evaluate that polynomial using the fitData points.
% b1Field is the B1 values corresponding to sigL...


% sigL -> each row is a separate B1 relative value,
% with six columns for the 6 different sequences

% Compute the standardized residual between fit points and the data.

fit_degree = 3;


fitMetric = zeros(4,6); % ultimately, we will want to sum across sequences, but can do later

% loop over each sequence, with a row for low, middle and high estimates.

for i = 1:6     
     % With B1's simulated ->Fit polynomial: 
     fitCoeffMat = polyfit(b1Field, sigL(:,i), fit_degree);
     fitMetric(1,i) = CR_calc_std_residualsWeighted( fitData(10,:), fitData(i,:) , fitCoeffMat);

     fitCoeffMat = polyfit(b1Field, sigM(:,i), fit_degree);
     fitMetric(2,i) = CR_calc_std_residualsWeighted( fitData(10,:), fitData(i,:) , fitCoeffMat);

     fitCoeffMat = polyfit(b1Field, sigH(:,i), fit_degree);
     fitMetric(3,i) = CR_calc_std_residualsWeighted( fitData(10,:), fitData(i,:) , fitCoeffMat);

     fitCoeffMat = polyfit(b1Field, sigMH(:,i), fit_degree);
     fitMetric(4,i) = CR_calc_std_residualsWeighted( fitData(10,:), fitData(i,:) , fitCoeffMat);
end

% From this, we want to sum across the sequences to combine the
% scores. highest wins

fitMetric = sum(fitMetric,2);


