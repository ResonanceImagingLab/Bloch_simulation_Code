% Two pool model exchange gif
addpath(genpath('E:\GitHub\Bloch_simulation_Code'))
addpath(genpath('E:\GitHub\qMRLab-master'))
adppath('E:\GitHub\NeuroImagingMatlab\Display') % gif code

exportName1 = 'E:\GitHub\Bloch_simulation_Code\Figures\OtherFigures\MTR_t1_effect_matched_t1.png';
exportName2 = 'E:\GitHub\Bloch_simulation_Code\Figures\OtherFigures\MTR_t1_effect_unmatched_t1.png';


%% Set up parameters
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);

Params.b1 = 3.6; % microTesla
Params.numSatPulse = 1;
Params.pulseDur = 12/1000; %duration of 1 MT pulse in seconds
Params.TR = 25e-3; % total repetition time = MT pulse train and readout.
Params.numExcitation = 1; % number of readout lines/TR
Params.flipAngle = 6; % excitation flip angle water.
Params.delta = 2000;
Params.pulseGapDur = 0/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echoSpacing = 7.66/1000;
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.
Params.IncludeDipolar = 1; 
Params.freqPattern='single';
Params.R1b = 1;
Params = CalcVariableImagingParams(Params);
Params.M0b = 0.05;
Params.PerfectSpoiling = 1;

% Now make a separate one for WM
ParamsWM = Params;
ParamsWM.Raobs = 1/0.75;
ParamsWM.M0b = 0.15;

[Sig_GM, M_GM, t_GM] = BlochSimFlashSequence_v2(Params);
[Sig_WM, M_WM, t_WM] = BlochSimFlashSequence_v2(ParamsWM);


%% For plotting select a mid section

st = 1;
ed = 50000;

figure;
plot(t_GM(st:ed), M_GM(3,st:ed),'LineWidth',3)
hold on
plot(t_WM(st:ed), M_WM(3,st:ed),'LineWidth',3)
ylim([0 1])
legend("GM: T_1 = 1.4s; M_{0B}=0.05","WM: T_1 = 0.75s; M_{0B}=0.15",'FontSize', 20)
xlabel('Time','FontSize', 20)
ylabel('M_z','FontSize', 20)
ax = gca; ax.FontSize = 20; 
set(gcf,'Position',[100 100 600 600])
saveas(gcf,exportName2)

%% Now if we kept the T1 the same:

ParamsWM.Raobs = Params.Raobs;

[Sig_WM, M_WM, t_WM] = BlochSimFlashSequence_v2(ParamsWM);

figure;
plot(t_GM(st:ed), M_GM(3,st:ed),'LineWidth',3)
hold on
plot(t_WM(st:ed), M_WM(3,st:ed),'LineWidth',3)
ylim([0 1])
legend("GM: T_1 = 1.4s; M_{0B}=0.05","WM: T_1 = 1.4s; M_{0B}=0.15",'FontSize', 20)
xlabel('Time','FontSize', 20)
ylabel('M_z','FontSize', 20)
ax = gca; ax.FontSize = 20; 
set(gcf,'Position',[100 100 600 600])

saveas(gcf,exportName1)






