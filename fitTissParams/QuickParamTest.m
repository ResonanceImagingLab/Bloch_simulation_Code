function QuickParamTest(R,T2a,T1D, T2b,M0b,R1b,Params, Params2, Params3, outputSamplingTable, outputSamplingTable2, outputSamplingTable3, gm_m, fft_gm_m,mat_ss,b1_1,b1_2,b1_3)

B1rms = 0:2:18;
% Ssig1 = zeros(Params.TurboFactor,length(B1rms));
% Ssig2 = zeros(Params2.TurboFactor,length(B1rms));
% Ssig3 = zeros(Params3.TurboFactor,length(B1rms));
Dsig1 = zeros(Params.TurboFactor,length(B1rms));
Dsig2 = zeros(Params2.TurboFactor,length(B1rms));
Dsig3 = zeros(Params3.TurboFactor,length(B1rms));

% parfor i = 1:length(B1rms)
%      [Ssig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'single', 'b1', B1rms(i),...
%          'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );           
% end
% parfor i = 1:length(B1rms)
%      [Ssig2(:,i),~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'single', 'b1', B1rms(i),...
%          'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );
% end
% parfor i = 1:length(B1rms)
%      [Ssig3(:,i),~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'single', 'b1', B1rms(i),...
%          'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );
% end
tic
parfor i = 1:length(B1rms)
     [ Dsig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b ); 
end
parfor i = 1:length(B1rms)
     [ Dsig2(:,i),~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );
end

parfor i = 1:length(B1rms)
     [ Dsig3(:,i),~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b );  
end
                                                        
toc


%% Then from the excitation train values, determine the realized GM value.

% Single_sig1_gm = zeros( 1, length(B1rms));
% Single_sig2_gm = zeros( 1, length(B1rms));
% Single_sig3_gm = zeros( 1, length(B1rms));
Dual_sig1_gm = zeros( 1, length(B1rms));
Dual_sig2_gm = zeros( 1, length(B1rms));
Dual_sig3_gm = zeros( 1, length(B1rms));

tic
parfor j = 1:length(B1rms)
%     Single_sig1_gm(j) = CR_generate_BSF_scaling_v1( squeeze(Ssig1(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;  
%     Single_sig2_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Ssig2(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m) ;
%     Single_sig3_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Ssig3(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;
    Dual_sig1_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig1(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;
    Dual_sig2_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig2(:,j)), Params2, outputSamplingTable2, gm_m, fft_gm_m);
    Dual_sig3_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig3(:,j)), Params3, outputSamplingTable3, gm_m, fft_gm_m) ;  

end
toc


%% Calculate MTsat on the whole matrix of signal values.
T1obs = ones(size(Dual_sig1_gm)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig1_gm)) ;


% MTsat_sim_Single1 = calcMTsatThruLookupTablewithDummyV3( Single_sig1_gm, [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
% MTsat_sim_Single2 = calcMTsatThruLookupTablewithDummyV3( Single_sig2_gm, [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
% MTsat_sim_Single3 = calcMTsatThruLookupTablewithDummyV3( Single_sig3_gm, [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);
MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);
MTsat_sim_Dual2   = calcMTsatThruLookupTablewithDummyV3( Dual_sig2_gm,   [], T1obs, [], M0_app_v, Params2.echoSpacing * 1000, Params2.numExcitation, Params2.TR * 1000, Params2.flipAngle, Params2.DummyEcho);
MTsat_sim_Dual3   = calcMTsatThruLookupTablewithDummyV3( Dual_sig3_gm,   [], T1obs, [], M0_app_v, Params3.echoSpacing * 1000, Params3.numExcitation, Params3.TR * 1000, Params3.flipAngle, Params3.DummyEcho);


%% Fit the data
fit_degree = 7;
                   
     % With B1's simulated ->Fit polynomial: 
%  Single_c1 = polyfit(B1rms, MTsat_sim_Single1, fit_degree);
%  Single_c2 = polyfit(B1rms, MTsat_sim_Single2, fit_degree);
%  Single_c3 = polyfit(B1rms, MTsat_sim_Single3, fit_degree);
 Dual_c1   = polyfit(B1rms, MTsat_sim_Dual1, fit_degree);
 Dual_c2   = polyfit(B1rms, MTsat_sim_Dual2, fit_degree);
 Dual_c3   = polyfit(B1rms, MTsat_sim_Dual3, fit_degree);
     
     % Try again using this: polyfitweighted, with the B1 as the weight!
% % 
% % 
% % %% Calculate Standardized Residuals
% % % this can take a few minutes of run time.
% % std_resid_d1 = CR_calc_std_residuals( b1_1, mat_ss(1,:) , Dual_c1);
% % std_resid_d2 = CR_calc_std_residuals( b1_2, mat_ss(2,:) , Dual_c2);
% % std_resid_d3 = CR_calc_std_residuals( b1_3, mat_ss(3,:) , Dual_c3);
% % 
% % % std_resid_s1 = CR_calc_std_residuals( b1_1, mat_ss(4,:) , Single_c1);
% % % std_resid_s2 = CR_calc_std_residuals( b1_2, mat_ss(5,:) , Single_c2);
% % % std_resid_s3 = CR_calc_std_residuals( b1_3, mat_ss(6,:) , Single_c3);
% % 
% % %standardized_residuals = [std_resid_d1, std_resid_d2, std_resid_d3, std_resid_s1, std_resid_s2, std_resid_s3];
% % standardized_residuals = [std_resid_d1, std_resid_d2, std_resid_d3];
% % 
% % 
% % %%  add the columns
% %  errorScore = sum( abs(standardized_residuals) , 2 ); % can have negatives, so combine abs of each
% %  
% %  % Dual Only
% %   %errorScore = sum( abs(standardized_residuals(:,1:3)) , 2 ); % can have negatives, so combine abs of each
% %  %errorScore = sum( abs(standardized_residuals(:,2)) , 2 ); % can have negatives, so combine abs of each
% %  
% %  
% %  % Sort based on this, then store in table :) 
% %  
% % % for best protocol, take top 10 most efficient protocols. Then sort by
% % % absolute ihMT
% % 
% % [~, sortidx] = sort(errorScore, 'ascend');
% % % Top50sorted = parametersSet ( sortidx(1:end),:);
% % % Top50Errors = errorScore ( sortidx(1:end),:);
% % % Top50sortedTable = array2table(Top50sorted, 'VariableNames',{'R', 'T2a', 'T1D', 'T2b', 'M0b','R1b'});

SortIndex = 1;% sortidx(1); % select the sorted line you want
x1_line = linspace(0,18,100);
y1 = polyval( Dual_c1(SortIndex,:), x1_line);
y2 = polyval( Dual_c2(SortIndex,:), x1_line);
y3 = polyval( Dual_c3(SortIndex,:), x1_line);



str = ['R = ',num2str(R),', T2a = ',num2str(T2a),...
    ', T1D = ',num2str( T1D), ', T2b =',num2str(T2b),...
    ', M0b = ',num2str(M0b ),', R1b = ',num2str(R1b )];


figure;
% subplot(1,2,1)
heatscatter(b1_1', mat_ss(4,:)' ); 
hold on
heatscatter(b1_2', mat_ss(5,:)' ); 
heatscatter(b1_3', mat_ss(6,:)' ); 
hold on
plot(x1_line,y1,'LineWidth',3); plot(x1_line,y2,'LineWidth',3); plot(x1_line,y3,'LineWidth',3)
xlim([0 18]) ; % ylim([0 0.04]) ;
colorbar off
ax = gca; ax.FontSize = 20; 
title(str,'FontSize',14);
hold off
ylim([0 0.3]) ;
set(gcf,'position',[10,400,800,600])    