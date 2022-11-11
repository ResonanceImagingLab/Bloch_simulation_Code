function QuickParamTest_1Prot(R,T2a,T1D, T2b,M0b,R1b,Params, outputSamplingTable, gm_m, fft_gm_m,mat_ss,b1_1)

B1rms = 0:2:20;
Dsig1 = zeros(Params.TurboFactor,length(B1rms));

tic
parfor i = 1:length(B1rms)
     [ Dsig1(:,i),~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
         'R', R, 'T2a', T2a, 'T1D',T1D, 'T2b', T2b, 'M0b', M0b, 'R1b', R1b ); 
end
                                                        
toc


%% Then from the excitation train values, determine the realized GM value.

Dual_sig1_gm = zeros( 1, length(B1rms));
parfor j = 1:length(B1rms)

    Dual_sig1_gm(j) = CR_generate_BSF_scaling_v1(squeeze(Dsig1(:,j)), Params, outputSamplingTable, gm_m, fft_gm_m) ;

end


%% Calculate MTsat on the whole matrix of signal values.
T1obs = ones(size(Dual_sig1_gm)) .* 1.4.*1000;
M0_app_v = ones(size(Dual_sig1_gm)) ;

MTsat_sim_Dual1   = calcMTsatThruLookupTablewithDummyV3( Dual_sig1_gm,   [], T1obs, [], M0_app_v, Params.echoSpacing * 1000,  Params.numExcitation,  Params.TR * 1000,  Params.flipAngle,   Params.DummyEcho);


%% Fit the data
fit_degree = 7;
Dual_c1   = polyfit(B1rms, MTsat_sim_Dual1, fit_degree);

x1_line = linspace(0,18,100);
y1 = polyval( Dual_c1(1,:), x1_line);


str = ['R = ',num2str(R),', T2a = ',num2str(T2a),...
    ', T1D = ',num2str( T1D), ', T2b =',num2str(T2b),...
    ', M0b = ',num2str(M0b ),', R1b = ',num2str(R1b )];


figure;
% subplot(1,2,1)
heatscatter(b1_1', mat_ss ); 
hold on
scatter(B1rms,MTsat_sim_Dual1)
plot(x1_line,y1,'LineWidth',3); 
xlim([0 18]) ; % ylim([0 0.04]) ;
colorbar off
ax = gca; ax.FontSize = 20; 
title(str,'FontSize',14);
hold off
ylim([0 max(mat_ss)+0.1*max(mat_ss)]) ;
set(gcf,'position',[10,400,800,600])    