function [modelTerms, iPr] = buildTissueParamFitEqn(rVec, iP)

% rVec will be a 1x6 vector that contains the number of datapoints that
% exist per tissue parameter

% generate a polynomial equation to be fit to the simulation data. I
% acknowledge that this should overfit the data. We just want good
% alignment with the fitted results and the datapoints.
coefLim = 2;
terms = rVec;
terms(terms>coefLim) = coefLim;
terms(terms==1) = 0;

modelTerms = zeros( prod(terms+1,'all'), 6);

idx = 1;
for i = 0:terms(1)
    for j = 0:terms(2)
        for k = 0:terms(3)
            for l = 0:terms(4)
                for m = 0:terms(5)
                    for n = 0:terms(6)
                        modelTerms(idx,1) = i;
                        modelTerms(idx,2) = j;
                        modelTerms(idx,3) = k;
                        modelTerms(idx,4) = l;
                        modelTerms(idx,5) = m;
                        modelTerms(idx,6) = n;
                        idx = idx+1;
                    end
                end
            end
        end
    end
end

% try removing columns with no variation in parameters
iPr = iP;
iPr(:,rVec== 1) = []; % remove columns
modelTerms(:,rVec== 1) = []; % remove columns


