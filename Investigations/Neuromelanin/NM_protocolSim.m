%% optimize NM imaging for SN and LC contrast
addpath(genpath('E:\Github\qMRLab'));

% First try to recreate Priovolous 2018
clearvars
Params.B0 = 7;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.numExcitation = 1;
Params.echoSpacing = 10/1000;
Params.PerfectSpoiling = 1;
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

%% Imaging Parameters:
Params.numSatPulse = 20;
Params.pulseDur = 10e-3; %duration of 1 MT pulse in seconds
Params.TR = 823/1000; % total repetition time = MT pulse train and readout.
Params.DummyEcho = 2;
Params.numExcitation = 38 + Params.DummyEcho; % number of readout lines/TR
Params.flipAngle = 8; % excitation flip angle water.
Params.delta = 2000;
Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params.pulseGapDur = 5/1000; %ms gap between MT pulses in train
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.ReferenceScan = 0;
Params.SatPulseShape = 'sincgauss'; % gausshann
Params.satFlipAngle = 285;
Params.TE = 2.08/1000;

% % Sort out pulse B1rms:
% tSat = 0:Par.pulseDur/200:Par.pulseDur;
% satPulse = GetPulse(Par.satFlipAngle, 2000, Par.pulseDur, Par.SatPulseShape, []);
% 
% gam = 42.576;
% B1_time = satPulse.omega(tSat)/(2*pi*gam);
% P3 = (1/Par.pulseDur) * trapz(tSat,B1_time.^2);
% B1rms = sqrt(P3);


%% Tissue Parameters:
ParamBrainStem = Params;
ParamSN = Params;
ParamLC = Params;
ParamCSF = Params;

ParamBrainStem.TissueType = 'brainStemWM';
ParamBrainStem = DefaultTissueParams(ParamBrainStem);

ParamSN.TissueType = 'substantiaNigra';
ParamSN = DefaultTissueParams(ParamSN);

ParamLC.TissueType = 'locusCoeruleus';
ParamLC = DefaultTissueParams(ParamLC);

ParamCSF.TissueType = 'CSF';
ParamCSF = DefaultTissueParams(ParamCSF);



[sig_bs, ~, ~] = BlochSimFlashSequence_v2( ParamBrainStem );
[sig_sn, ~, ~] = BlochSimFlashSequence_v2( ParamSN );
[sig_lc, ~, ~] = BlochSimFlashSequence_v2( ParamLC );
[sig_csf, ~, ~] = BlochSimFlashSequence_v2( ParamCSF );

% Apply T2* weighting
sig_bs2 = sig_bs .*exp(-Params.TE/ParamBrainStem.T2star);
sig_sn2 = sig_sn .* exp(-Params.TE/ParamSN.T2star);
sig_lc2 = sig_lc .* exp(-Params.TE/ParamLC.T2star);
sig_csf2 = sig_csf .*exp(-Params.TE/ ParamCSF.T2star);

figure; tiledlayout(2, 2,"TileSpacing","compact"); nexttile;
plot(ParamBrainStem.PD/100*sig_bs, 'LineWidth',3);
hold on;
plot(ParamSN.PD/100*sig_sn, 'LineWidth',3);
plot(ParamLC.PD/100*sig_lc, 'LineWidth',3);
plot(ParamCSF.PD/100*sig_csf, 'LineWidth',3);
legend('BrainStemWM', 'SN', 'LC', 'CSF', 'Location', 'southwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = 0'])
ylim([0, 0.08]); xlabel('Excitation number')


nexttile;
plot(ParamBrainStem.PD/100*sig_bs2, 'LineWidth',3);
hold on;
plot(ParamSN.PD/100*sig_sn2, 'LineWidth',3);
plot(ParamLC.PD/100*sig_lc2, 'LineWidth',3);
plot(ParamCSF.PD/100*sig_csf2, 'LineWidth',3);
legend('BrainStemWM', 'SN', 'LC', 'CSF', 'Location', 'southwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
ylim([0, 0.08]); xlabel('Excitation number')

%% CNR,
noise = 0.001;
cnr_bs_sn = abs(ParamBrainStem.PD/100*sig_bs - ParamSN.PD/100*sig_sn)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sig_bs - ParamLC.PD/100*sig_lc)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*sig_csf - ParamLC.PD/100*sig_lc)./noise;

nexttile;
plot(cnr_bs_sn, 'LineWidth',3);
hold on;
plot(cnr_bs_lc, 'LineWidth',3);
plot(cnr_csf_lc, 'LineWidth',3);
legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = 0'])
ylim([0, 25]); xlabel('Excitation number')

cnr_bs_sn = abs(ParamBrainStem.PD/100*sig_bs2 - ParamSN.PD/100*sig_sn2)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sig_bs2 - ParamLC.PD/100*sig_lc2)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*sig_csf2 - ParamLC.PD/100*sig_lc2)./noise;

nexttile;
plot(cnr_bs_sn, 'LineWidth',3);
hold on;
plot(cnr_bs_lc, 'LineWidth',3);
plot(cnr_csf_lc, 'LineWidth',3);
legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
ylim([0, 25]); xlabel('Excitation number')

set(gcf,'Position',[100 100 1200 1000])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lets just try a FLASH protocol to see what we get with different flip angles
clearvars % -except Params 
flipAngle = 4:30;

Params.B0 = 7;
Params.MTC = 0; % Magnetization Transfer Contrast
Params.numExcitation = 1;
Params.echoSpacing = 10/1000;
Params.PerfectSpoiling = 1;
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

%% Imaging Parameters:
Params.numSatPulse = 0;
Params.pulseDur = 10e-3; %duration of 1 MT pulse in seconds
Params.TR = 35/1000; % total repetition time = MT pulse train and readout.
Params.DummyEcho = 0;
Params.numExcitation = 1 + Params.DummyEcho; % number of readout lines/TR
Params.flipAngle = []; % excitation flip angle water.
Params.delta = 2000;
Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params.pulseGapDur = 0.1/1000; %ms gap between MT pulses in train
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.ReferenceScan = 0;
Params.SatPulseShape = 'sincgauss'; % gausshann
Params.satFlipAngle = 0;
Params.TE = 2.08/1000;


%% Tissue Parameters:
ParamBrainStem = Params;
ParamSN = Params;
ParamLC = Params;
ParamCSF = Params;

ParamBrainStem.TissueType = 'brainStemWM';
ParamBrainStem = DefaultTissueParams(ParamBrainStem);

ParamSN.TissueType = 'substantiaNigra';
ParamSN = DefaultTissueParams(ParamSN);

ParamLC.TissueType = 'locusCoeruleus';
ParamLC = DefaultTissueParams(ParamLC);

ParamCSF.TissueType = 'CSF';
ParamCSF = DefaultTissueParams(ParamCSF);

%% set up and sim
sig_bs = zeros(size(flipAngle));
sig_sn = zeros(size(flipAngle));
sig_lc = zeros(size(flipAngle));
sig_csf = zeros(size(flipAngle));

for i = 1:length(flipAngle)
    [sig_bs(i), ~, ~] = BlochSimFlashSequence_v2( ParamBrainStem, 'flipAngle', flipAngle(i) );
    [sig_sn(i), ~, ~] = BlochSimFlashSequence_v2( ParamSN, 'flipAngle', flipAngle(i) );
    [sig_lc(i), ~, ~] = BlochSimFlashSequence_v2( ParamLC, 'flipAngle', flipAngle(i) );
    [sig_csf(i), ~, ~] = BlochSimFlashSequence_v2( ParamCSF, 'flipAngle', flipAngle(i) );
end

% Apply T2* weighting
sig_bs2 = sig_bs *exp(-Params.TE/ParamBrainStem.T2star);
sig_sn2 = sig_sn * exp(-Params.TE/ParamSN.T2star);
sig_lc2 = sig_lc * exp(-Params.TE/ParamLC.T2star);
sig_csf2 = sig_csf *exp(-Params.TE/ ParamCSF.T2star);

figure; tiledlayout(2, 2,"TileSpacing","compact"); nexttile;
plot(ParamBrainStem.PD/100*sig_bs, 'LineWidth',3);
hold on;
plot(ParamSN.PD/100*sig_sn, 'LineWidth',3);
plot(ParamLC.PD/100*sig_lc, 'LineWidth',3);
plot(ParamCSF.PD/100*sig_csf, 'LineWidth',3);
legend('BrainStemWM', 'SN', 'LC', 'CSF', 'Location', 'southwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = 0'])
ylim([0, 0.13]); xlabel('Flip Angle (degrees)')


nexttile;
plot(ParamBrainStem.PD/100*sig_bs2, 'LineWidth',3);
hold on;
plot(ParamSN.PD/100*sig_sn2, 'LineWidth',3);
plot(ParamLC.PD/100*sig_lc2, 'LineWidth',3);
plot(ParamCSF.PD/100*sig_csf2, 'LineWidth',3);
legend('BrainStemWM', 'SN', 'LC', 'CSF', 'Location', 'southwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
ylim([0, 0.13]); xlabel('Flip Angle (degrees)')

%% CNR,
noise = 0.001;
cnr_bs_sn = abs(ParamBrainStem.PD/100*sig_bs - ParamSN.PD/100*sig_sn)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sig_bs - ParamLC.PD/100*sig_lc)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*sig_csf - ParamLC.PD/100*sig_lc)./noise;

nexttile;
plot(cnr_bs_sn, 'LineWidth',3);
hold on;
plot(cnr_bs_lc, 'LineWidth',3);
plot(cnr_csf_lc, 'LineWidth',3);
legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = 0'])
ylim([0, 20]); xlabel('Flip Angle (degrees)')

cnr_bs_sn = abs(ParamBrainStem.PD/100*sig_bs2 - ParamSN.PD/100*sig_sn2)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sig_bs2 - ParamLC.PD/100*sig_lc2)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*sig_csf2 - ParamLC.PD/100*sig_lc2)./noise;

nexttile;
plot(cnr_bs_sn, 'LineWidth',3);
hold on;
plot(cnr_bs_lc, 'LineWidth',3);
plot(cnr_csf_lc, 'LineWidth',3);
legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
ylim([0, 20]); xlabel('Flip Angle (degrees)')

set(gcf,'Position',[100 100 1200 1000])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Expand to an MT FLASH protocol - vary excitation and MT pulse - ignore SAR
clearvars -except noise 
flipAngle = 4:30;
satFlipAngle = linspace(30,180,15);

Params.B0 = 7;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.numExcitation = 1;
Params.echoSpacing = 10/1000;
Params.PerfectSpoiling = 1;
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

%% Imaging Parameters:
Params.numSatPulse = 1;
Params.pulseDur = 5e-3; %duration of 1 MT pulse in seconds
Params.TR = 35/1000; % total repetition time = MT pulse train and readout.
Params.DummyEcho = 0;
Params.numExcitation = 1 + Params.DummyEcho; % number of readout lines/TR
Params.flipAngle = []; % excitation flip angle water.
Params.delta = 3000;
Params.freqPattern = 'single'; % options: 'single', 'dualAlternate', 'dualContinuous'
Params.pulseGapDur = 0.1/1000; %ms gap between MT pulses in train
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gausshann'; % gausshann
Params.satFlipAngle = 1;
Params.TE = 2.08/1000;


%% Tissue Parameters:
ParamBrainStem = Params;
ParamSN = Params;
ParamLC = Params;
ParamCSF = Params;

ParamBrainStem.TissueType = 'brainStemWM';
ParamBrainStem = DefaultTissueParams(ParamBrainStem);

ParamSN.TissueType = 'substantiaNigra';
ParamSN = DefaultTissueParams(ParamSN);

ParamLC.TissueType = 'locusCoeruleus';
ParamLC = DefaultTissueParams(ParamLC);

ParamCSF.TissueType = 'CSF';
ParamCSF = DefaultTissueParams(ParamCSF);

%% set up and sim
sig_bs = zeros(length(flipAngle), length(satFlipAngle));
sig_sn = zeros(length(flipAngle), length(satFlipAngle));
sig_lc = zeros(length(flipAngle), length(satFlipAngle));
sig_csf = zeros(length(flipAngle), length(satFlipAngle));

for i = 1:length(flipAngle)
    for j = 1:length(satFlipAngle)
        [sig_bs(i,j), ~, ~] = BlochSimFlashSequence_v2( ParamBrainStem, 'flipAngle', flipAngle(i), 'satFlipAngle', satFlipAngle(j) );
        [sig_sn(i,j), ~, ~] = BlochSimFlashSequence_v2( ParamSN, 'flipAngle', flipAngle(i), 'satFlipAngle', satFlipAngle(j) );
        [sig_lc(i,j), ~, ~] = BlochSimFlashSequence_v2( ParamLC, 'flipAngle', flipAngle(i), 'satFlipAngle', satFlipAngle(j) );
        [sig_csf(i,j), ~, ~] = BlochSimFlashSequence_v2( ParamCSF, 'flipAngle', flipAngle(i), 'satFlipAngle', satFlipAngle(j) );
    end
end

% Apply T2* weighting
sig_bs2 = sig_bs *exp(-Params.TE/ParamBrainStem.T2star);
sig_sn2 = sig_sn * exp(-Params.TE/ParamSN.T2star);
sig_lc2 = sig_lc * exp(-Params.TE/ParamLC.T2star);
sig_csf2 = sig_csf *exp(-Params.TE/ ParamCSF.T2star);

%% Plot
[fa, sfa] = ndgrid( flipAngle, satFlipAngle);

figure; tiledlayout(2, 2,"TileSpacing","compact"); nexttile;
colors= jet(4);
hold on
surf(fa, sfa, ParamBrainStem.PD/100*sig_bs, 'FaceAlpha',0.2, 'FaceColor',colors(1,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, ParamSN.PD/100*sig_sn, 'FaceAlpha',0.2, 'FaceColor',colors(2,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, ParamLC.PD/100*sig_lc, 'FaceAlpha',0.2, 'FaceColor',colors(3,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, ParamCSF.PD/100*sig_csf, 'FaceAlpha',0.2, 'FaceColor',colors(4,:), 'EdgeAlpha',0.2 )
legend('BrainStemWM', 'SN', 'LC', 'CSF', 'Location', 'southwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = 0'])
zlim([0, 0.13]); 
xlabel('Excitation Flip Angle'); ylabel('Sat Flip Angle')


nexttile; hold on;
surf(fa, sfa, ParamBrainStem.PD/100*sig_bs2, 'FaceAlpha',0.2, 'FaceColor',colors(1,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, ParamSN.PD/100*sig_sn2, 'FaceAlpha',0.2, 'FaceColor',colors(2,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, ParamLC.PD/100*sig_lc2, 'FaceAlpha',0.2, 'FaceColor',colors(3,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, ParamCSF.PD/100*sig_csf2, 'FaceAlpha',0.2, 'FaceColor',colors(4,:), 'EdgeAlpha',0.2 )
legend('BrainStemWM', 'SN', 'LC', 'CSF', 'Location', 'southwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
zlim([0, 0.13]); 
xlabel('Excitation Flip Angle'); ylabel('Sat Flip Angle')



%% CNR,
cnr_bs_sn = abs(ParamBrainStem.PD/100*sig_bs - ParamSN.PD/100*sig_sn)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sig_bs - ParamLC.PD/100*sig_lc)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*sig_csf - ParamLC.PD/100*sig_lc)./noise;

nexttile; hold on;
surf(fa, sfa, cnr_bs_sn, 'FaceAlpha',0.2, 'FaceColor',colors(1,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, cnr_bs_lc, 'FaceAlpha',0.2, 'FaceColor',colors(2,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, cnr_csf_lc, 'FaceAlpha',0.2, 'FaceColor',colors(3,:), 'EdgeAlpha',0.2 )

legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = 0'])
zlim([0, 20]); xlabel('Flip Angle (degrees)')

cnr_bs_sn = abs(ParamBrainStem.PD/100*sig_bs2 - ParamSN.PD/100*sig_sn2)./noise;
cnr_bs_lc = abs(ParamBrainStem.PD/100*sig_bs2 - ParamLC.PD/100*sig_lc2)./noise;
cnr_csf_lc = abs(ParamCSF.PD/100*sig_csf2 - ParamLC.PD/100*sig_lc2)./noise;

nexttile; hold on;
surf(fa, sfa, cnr_bs_sn, 'FaceAlpha',0.2, 'FaceColor',colors(1,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, cnr_bs_lc, 'FaceAlpha',0.2, 'FaceColor',colors(2,:), 'EdgeAlpha',0.2 )
surf(fa, sfa, cnr_csf_lc, 'FaceAlpha',0.2, 'FaceColor',colors(3,:), 'EdgeAlpha',0.2 )
legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
zlim([0, 20]); xlabel('Flip Angle (degrees)')

set(gcf,'Position',[100 100 1200 1000])

% Just look at the 15 degree one:
figure; plot(satFlipAngle, cnr_bs_sn(12, :), 'LineWidth',3);
hold on;
plot(satFlipAngle, cnr_bs_lc(12, :), 'LineWidth',3);
plot(satFlipAngle, cnr_csf_lc(12, :), 'LineWidth',3);
legend('CNR WMxSN', 'CNR WMxLC', 'CNR WMxCSF', 'Location', 'northwest'); ax = gca;    ax.FontSize = 14;
title(['Exitation = 15deg; TR = ', num2str(Params.TR*1000),' ms', '; TE = ', num2str(Params.TE*1000),' ms'])
ylim([0, 20]); xlabel('sat Flip Angle (degrees)')

set(gcf,'Position',[100 100 1200 1000])









