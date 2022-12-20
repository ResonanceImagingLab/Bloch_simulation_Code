function B1rms = getExcPulseB1rms( flipAngle)

% I have only computed for one pulse shape, other can be done by going
% through the code commented out at the bottom.
% Currently assumes square (hard) pulse with 0.1ms duration

% using equation 3 from: A strategy to reduce the sensitivity of inhomogeneous magnetization transfer ( ihMT ) imaging to radiofrequency transmit field variations at 3 T
% requires qMRlab for getting values. 

% Pulse dur must be in seconds!

gam = 42.58e6; % Hz/T

Integral_b1Norm = 1e-4;
sqrtP2 = 0.3608;
Amplitude = flipAngle/(360*gam*Integral_b1Norm); % derived from qMRlab code
B1rms = sqrtP2 * Amplitude;


%% For other shapes and durations: solve for P2 and integrals:
% Use qMRlab to be able to explor different pulse shapes:
%Pulsedur = 1e-4;
% excPulse = GetPulse(5, 0, Pulsedur, 'hard');
% Trf = excPulse.Trf;
% t = 0:Trf/1000:Trf;
% y = excPulse.('b1')(t);
% plot(t,y); hold on;
% 
% Integral_b1Norm = trapz(t,y);
% integSq = trapz(t,y.^2);
% p2 =  integSq/Params.pulseDur;
% sqrtP2 = sqrt(p2);
