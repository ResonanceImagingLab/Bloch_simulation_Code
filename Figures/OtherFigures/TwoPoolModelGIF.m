% Two pool model exchange gif
addpath(genpath('E:\GitHub\Bloch_simulation_Code'))
addpath(genpath('E:\GitHub\qMRLab-master'))
adppath('E:\GitHub\NeuroImagingMatlab\Display') % gif code

exportName = 'E:\GitHub\Bloch_simulation_Code\Figures\OtherFigures\TwoPoolModelGIF.gif';


%% Set up parameters
Params.B0 = 3;
Params.MTC = 1; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);

Params.b1 = 15; % microTesla
Params.numSatPulse = 1;
Params.pulseDur = 12/1000; %duration of 1 MT pulse in seconds
Params.TR = 5; % total repetition time = MT pulse train and readout.
Params.numExcitation = 1; % number of readout lines/TR
Params.flipAngle = 6; % excitation flip angle water.
Params.delta = 5000;
Params.pulseGapDur = 0.3/1000; %ms gap between MT pulses in train % C.R. new, shift from 1ms to 0.5
Params.WExcDur = 0.1/1000; % duration of water pulse
Params.echoSpacing = 7.66/1000;
Params.ReferenceScan = 0;
Params.SatPulseShape = 'gausshann';
Params.PulseOpt.bw = 0.3./Params.pulseDur; % override default Hann pulse shape.
Params.IncludeDipolar = 1; 
Params.freqPattern='single';
Params.R1b = 1;

%% Just for this, make M0b = 0.2
Params.M0b = 0.2;

Params = CalcVariableImagingParams(Params);

%% Pull some code from BlochSimFlashSequence_v2
% just want to apply the RF pulse, and then show relaxation

Params.kf = (Params.R*Params.M0b); 
Params.kr = (Params.R*Params.M0a);

if isempty(Params.Ra) % allow you to specify either Ra or Raobs
    Params.Ra = Params.Raobs - ((Params.R * Params.M0b * (Params.R1b - Params.Raobs)) / (Params.R1b - Params.Raobs + Params.R));
    if isnan(Params.Ra)
        Params.Ra = 1;
    end
end

stepSize = 50e-6; % 50 microseconds
RFphase = 0; % starting excitation phase
last_increment = 0;
num2avgOver = 20; % you get some variation in signal, so keep the last few and average

% Equivalent of 5 seconds of imaging to steady state, then record data. 
loops = ceil(6/Params.TR) + num2avgOver;

%% Standard Stuff
M0 = [0 0 Params.M0a, Params.M0b, 0]';
I = eye(5); % identity matrix      
B = [0 0 Params.Ra*Params.M0a, Params.R1b*Params.M0b, 0]';

%% Precompute MTC Pulses:
tSat = 0 : stepSize : Params.pulseDur;

PulseDur = ceil(Params.pulseDur/stepSize); % Break down pulse into rectangles
alpha = Params.b1*(360*42.6*Params.pulseDur);

if ~isfield(Params,'PulseOpt')
    Params.PulseOpt = [];
end

satPulse = GetPulse(alpha, Params.delta, Params.pulseDur, Params.SatPulseShape, Params.PulseOpt);

E_rf = zeros(5,5,PulseDur);

% Precompute the RF matrix that is time variant in the 3rd dimension
for k = 1:PulseDur
    E_rf(:,:,k) = Bloch_McConnell_wDipolar(Params, Params.delta, satPulse.omega(tSat(k))); 
end

% Impact of Excitation Pulse of Bound pool
Params = CalcBoundSatFromExcitationPulse(Params, Params.flipAngle); % Rrfb_exc and Rrfd_exc for excitation pulses

Params.CalcVector = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start of sequence loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = zeros(5,loops*20);
M(:,1) = M0;

time_vect = zeros( loops*20,1);
M_t = repmat(M0,1, Params.N_spin);
idx = 2;


% For Saturation Pulse
for k = 1:PulseDur
  
    [M_t, time_vect(idx)] = calcPoolChange( E_rf(:,:,k), B, I, stepSize, M_t, time_vect(idx-1) );

    if Params.CalcVector == 1 
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1) +  stepSize;
        idx = idx +1;
    end % For viewing; 
    
end    
%M_t = XYmag_Spoil(Params, M_t, Params.pulseGapDur, 0, 0);

%% For relaxation, do time steps of 10ms
stepSize2 = 1e-3; % initial exchange needs slow spacing to see

      
for i = 1:50
    M_t = XYmag_Spoil(Params, M_t, stepSize2, 0, 0);

    if Params.CalcVector == 1
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1)+stepSize2;
        idx = idx+1;
    end % For viewing; 
end

stepSize2 = 20e-3; % relaxation bigger timestep

      
for i = 1:250
    M_t = XYmag_Spoil(Params, M_t, stepSize2, 0, 0);

    if Params.CalcVector == 1
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1)+stepSize2;
        idx = idx+1;
    end % For viewing; 
end

M(:,idx:end) = [];
time_vect(idx:end) = [];

figure;
plot(time_vect, M(3,:))
hold on
plot(time_vect, M(4,:))


figure;
plot( M(3,:))
hold on
plot( M(4,:))

%% come up with a vector for choosing how to make bar plots:
s1 = 5;
s2 = 5;
t = [1:s1:292, 300:s2:540];


figure;
plot( M(3,t))
hold on
plot( M(4,t))


%% Set up GIF plots
fw_min = 0;
fw_max = max(M(3,:));
bp_min = 0;
bp_max = max(M(4,:));

t1 = 49;
t2 = 60;

figure;
gif(exportName,'DelayTime',0.15);


for i = 1:length(t)
    
    subplot(1,2,1);
    bar(M(3,t(i)))
    title('Free Water','FontSize',20, "FontWeight","bold")
    set(gca,'XTick',[], 'YTick', [])
    ylim([fw_min,fw_max])
    
    subplot(1,2,2);
    bar(M(4,t(i)),'r')
    title('Bound Pool','FontSize',20, "FontWeight","bold")
    set(gca,'XTick',[], 'YTick', [])
    ylim([bp_min,bp_max])
    %pause(0.5)

    if i < t1
        sgtitle('Apply RF Off-res','FontSize',20, "FontWeight","bold")
    elseif i < t2
        sgtitle('Pools restore equilibrium','FontSize',20, "FontWeight","bold")
    else
        sgtitle('T_1 relaxation','FontSize',20, "FontWeight","bold")
    end
    
    gif
end


% view result
web(exportName)














