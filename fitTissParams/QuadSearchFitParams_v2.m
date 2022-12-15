%% Quad search fit params

% start with an initial guess of fit parameters. 
% For each iteration, we compute signal curves (over B1+) for 3 tissue
% paramter options. The fit is evaluated as using standardized residuals, and then a
% quadratic is fit to this. 

% v2 uses the raw data points instead of the fit curve to the data
% (preprocess curve)

addpath(genpath( 'E:\GitHub\qMRLab-master'))
addpath(genpath('E:\GitHub\Bloch_simulation_Code'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



savDir = 'E:\GitHub\Bloch_simulation_Code\fitTissParams\outputs\quadFit\';
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_image.mat'))
load( strcat('E:\GitHub\Bloch_simulation_Code\kspaceWeighting\Atlas_reference\','GM_seg_MNI_152_kspace.mat'))


% We will evaluate at 4 B1 values, fit a curve to that and then evaluate
% the polynomial at the data B1 values to be able to take innerproduct.


%% load data to fit to, and cleanup
[fitData, rawProc] = CR_loadAndCleanData('E:\GitHub\Bloch_simulation_Code\fitTissParams\MTsat_vals2fit.mat','E:\GitHub\Bloch_simulation_Code\fitTissParams\MTsat_vals2fit_Mar16.mat' );

% viewIdx = 2;
% figure; heatscatter(rawProc(10,:)', rawProc(viewIdx,:)'); %ylim([0 0.04]); xlim([0 15])
% hold on
% plot(fitData(10,:)', fitData(viewIdx,:)', "Color",'b',"LineWidth",3); 

% -> if we look at this in curve fitting toolbox, it looks like polynomial
% degree 4 is needed to fit this curve nearly perfect, but 3 should be
% sufficient. This means we need to evaluate at 4 B1 values:

b1L = min(rawProc(10,:))*0.95; % go just past for better fitting in area of interest
b1H = max(rawProc(10,:))*1.05;

b1Field = round( linspace(b1L, b1H, 4), 2);

%% Get simulation parameters for sequences
[Params, Params2, Params3] = getParamsForFitting();

[SamplingTable, ~, Params.Segments] = Step1_calculateKspaceSampling_v3 (Params);
[SamplingTable2, ~, Params2.Segments] = Step1_calculateKspaceSampling_v3 (Params2);
[SamplingTable3, ~, Params3.Segments] = Step1_calculateKspaceSampling_v3 (Params3);


% viewResult = reshape(SamplingTable,Params.NumLines/Params.AccelerationFactor +Params.ReferenceLines,Params.NumPartitions);
% figure;
% imagesc(viewResult)
% axis image

%% Algorithm:

% later could just write over currList, but for now, lets save each step to
% be able to go back and see how it is working:

maxIterations = 30;


% Variable vectors are in order: 
%            M0B,     R,   T2B,  T1D,   T2A,  R1B
currList   = [0.071, 50, 11.5e-6, 7.5e-4,  60e-3,  0.25]; % current estimate/start
SetLowerLimit = [0.03,  15,  8e-6, 1e-4,  15e-3,  0.01]; % set lower limits for fit
SetHighLimit  = [0.10,  80, 14e-6, 25e-3, 110e-3,  1.5]; % set lower limits for fit


iteration = 1;
num2fit = length(currList);

trackingMat = zeros(maxIterations*6+1,8); % store each variable, and the calculate FWHM
trackingMat(1,1:6) = currList;
HL = zeros(maxIterations*6+1,6); HL(1,:) = SetHighLimit;
LL = zeros(maxIterations*6+1,6); LL(1,:) = SetLowerLimit;

% keep track of current best:
BestVals = [currList, 1e6, 0, 0];

id = 2;

%% We will run the iteration 4 times, then reset lower limit
% we keep track of the best (lowest) and then refit.
% this allows more aggressive narrowing of limits
tic
while iteration <= maxIterations
    lowerLimit = SetLowerLimit;
    highLimit = SetHighLimit;

    for loopidx = 1:3
    
        for i = 1:num2fit % for each variable:
        
            % skip if limits are within a range
            limitPerDif = (highLimit(i) - lowerLimit(i))/ (highLimit(i) + lowerLimit(i));
            if limitPerDif > 0.05
    
                
                % if we fit to the limit on a previous run, move the needle
                % in between limits to be able to have 3 distinct values
                if currList(i) == lowerLimit(i) || currList(i) == highLimit(i)
                    currList(i) = (highLimit(i) + lowerLimit(i)) /2;
                end
    
                % find flex point:
                if i == 4
                    currList(i) = log10(currList(i));
                    lowerLimit(i) = log10(lowerLimit(i));
                    highLimit(i) = log10(highLimit(i));
                end
    
                if (currList(i)-lowerLimit(i)) > (highLimit(i) -currList(i))
                    fp = (currList(i)+lowerLimit(i))/2;
                else 
                    fp = (currList(i)+highLimit(i))/2;
                end
    
                if i == 4
                    currList(i) = 10.^(currList(i));
                    lowerLimit(i) = 10.^(lowerLimit(i));
                    highLimit(i) = 10.^(highLimit(i));
                    fp = 10.^(fp);
                end
        
                % the middle will always need to be calculated
                sigM = simSequenceForFit(Params, Params2, Params3,...
                    currList(1), currList(2),  currList(3),...
                    currList(4), currList(5),  currList(6), b1Field,...
                    gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                
                switch i
                    case 1
                        sigL = simSequenceForFit(Params, Params2, Params3,...
                            lowerLimit(1), currList(2),  currList(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                        sigH = simSequenceForFit(Params, Params2, Params3,...
                            highLimit(1), currList(2),  currList(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
    
                        sigMH = simSequenceForFit(Params, Params2, Params3,...
                            fp, currList(2),  currList(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                    case 2
                        sigL = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), lowerLimit(2),  currList(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                        sigH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), highLimit(2),  currList(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
    
                        sigMH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), fp,  currList(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                    case 3
                        sigL = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  lowerLimit(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                        sigH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  highLimit(3),...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
    
                        sigMH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  fp,...
                            currList(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                    case 4
                        sigL = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            lowerLimit(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                        sigH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            highLimit(4), currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
    
                        sigMH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            fp, currList(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                    case 5
                        sigL = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            currList(4), lowerLimit(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                        sigH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            currList(4), highLimit(5),  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
    
                        sigMH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            currList(4), fp,  currList(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                    case 6
                        sigL = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            currList(4), currList(5),  lowerLimit(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                        sigH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            currList(4), currList(5),  highLimit(6), b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
    
                        sigMH = simSequenceForFit(Params, Params2, Params3,...
                            currList(1), currList(2),  currList(3),...
                            currList(4), currList(5),  fp, b1Field,...
                            gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 );
        
                end
        
                % With sat values solves, fit polynomials, evaluate over B1points,
                % and compute inner product to evaluate fits.
        
                fitMetricY = fitPolyCompute4StdResid2raw(sigL, sigM, sigH, sigMH,...
                    rawProc, b1Field);
    
                % update best vals if lower resid:
                if any(fitMetricY < BestVals(7))
                    [M,I] = min(fitMetricY);
                    BestVals = currList;
                    switch I
                        case 1
                            BestVals(i) = lowerLimit(i);
                        case 2
                            BestVals(i) = currList(i);
                        case 3
                            BestVals(i) = highLimit(i);
                        case 4
                            BestVals(i) = fp;
                    end
                    BestVals(7:9) = [M, iteration, i];
                end
        
                % Use these 4 data points to fit a quadratic to the fit results to
                % try and estimate where the peak will be (fit parameter!).
        
                [~, vertex] = createInvertedQuadFit([lowerLimit(i);currList(i);highLimit(i); fp],...
                    fitMetricY, i);
    
                % Update limits:
                [lowerLimit,highLimit, vertex] = updateFitLimitsQuad_2(vertex, lowerLimit,...
                    highLimit, currList(i), i);
                
                currList(i) = vertex; % new guess
        
                str = ['M0b = ',num2str(currList(1)),' R = ',num2str(currList(2)),...
                    ' T2B = ',num2str(currList(3)),' T1D = ',num2str(currList(4)),...
                    ' T2A = ',num2str(currList(5)),' R1B = ',num2str(currList(6))];
        
                disp(['Current estimated: ', str]);
                toc
                
        
                %% Can remove later, current guess. 7th column is minimum of fit
                trackingMat(id,1:6) = currList; trackingMat(id,7) = fitMetricY(2); 
                HL(id,:) = highLimit; LL(id,:) = lowerLimit;
                trackingMat(id,8) = i; id = id+1;
            
            end
        end
    
        iteration = iteration + 1;
    end

end
%% Save output:

vers = 2;

save([savDir,'trackingMat',num2str(vers),'.mat'], "trackingMat");
save([savDir,'currList',num2str(vers),'.mat'], "currList");
save([savDir,'lowerLimit',num2str(vers),'.mat'], "LL");
save([savDir,'highLimit',num2str(vers),'.mat'], "HL");


%% Check fit:
Savefn = [savDir,'convergeFit',num2str(vers),'.png'];
generateFitFigure2(Params, Params2, Params3,rawProc,fitData,...
                    currList(1), currList(2),  currList(3),...
                    currList(4), currList(5),  currList(6),Savefn,...
                    gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 )

Savefn = [savDir,'bestFit',num2str(vers),'.png'];
generateFitFigure2(Params, Params2, Params3,rawProc,fitData,...
                    BestVals(1), BestVals(2),  BestVals(3),...
                    BestVals(4), BestVals(5),  BestVals(6),Savefn,...
                    gm_m, fft_gm_m, SamplingTable, SamplingTable2, SamplingTable3 )



spline(x,y)






















