%% Magnetization Transfer

addpath( genpath('E:\GitHub\qMRLab')); % need qMRlab and this code

clear all


% Lets simulate a basic sequence.
Params.PerfectSpoiling = true;
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'WM';
Params.echoSpacing = 5/1000;
Params.numExcitation = 1;
Params.M0b = 0.4; % exagerate for viewing

Params = DefaultCortexTissueParams(Params);
Params.R1b = 1;
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);
Params.CalcVector = 1;

% ref val 25ms
Params.TR = 35/1000;  % long to ignore T1 relaxation effects
Params.flipAngle = 0;
Params.pulseGapDur = 5/1000;
Params.freqPattern = 'single';
Params.SatPulseShape = 'hard';
Params.satFlipAngle = 5000;
Params.pulseDur = 10e-3;
Params.delta = 2000;
Params.numSatPulse = 1;
Params.ReadoutResolution = 1.3e-3;

[sig, M, time_vect] = BlochSimFlashSequence_v2(Params);




%% Plot z 

z1 = M(3,:);
z2 = M(4,:); 
z2 = z2/max(z2);

figure; plot(time_vect*1000,z1, 'Color','b', 'LineWidth', 3)
hold on;
plot(time_vect*1000,z2, 'Color','r', 'LineWidth', 3)
xlabel('Time (ms)', FontSize= 20); 
ylabel('Relative M_z', FontSize= 20); 
ax = gca;    ax.FontSize = 20;
xlim([0 15])
legend('Water', 'Macromolecular','Location','best')







