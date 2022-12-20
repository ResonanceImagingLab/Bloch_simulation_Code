function B1rms = getPulseB1rms(B1, pulseDur)

% I have only computed for one pulse shape, other can be done by going
% through the code commented out at the bottom.

% using equation 3 from: A strategy to reduce the sensitivity of inhomogeneous
% magnetization transfer ( ihMT ) imaging to radiofrequency transmit field 
% variations at 3T. Soustelle et al., 2021. MRM.

% requires qMRlab for getting values. 
% Pulse dur must be in seconds!

% handle whether B1 is input as microtesla or tesla
if B1 > 1e-4
    B1 = B1./1e6;
end

gam = 42.58e6; % Hz/T


%% Calculations have been done for hann pulses length 0.768, 1.024, 1.28 and 2.048ms.

if pulseDur == 0.768e-3
    Integral_b1Norm = 3.8e-4;
    
elseif pulseDur == 1.024e-3
    Integral_b1Norm = 5.067e-4;

elseif pulseDur == 1.28e-3
    Integral_b1Norm = 6.334e-4;

elseif pulseDur == 2.048e-3
    Integral_b1Norm = 1.0134e-3;

else
    error('this pulse duration has not been calculated. Open function and look to bottom to calculate');
end
sqrtP2 = 0.6085;

MTflipAngle = B1.*42.58e6.*pulseDur.*360;
Amplitude = MTflipAngle./(360.*gam.*Integral_b1Norm); % derived from qMRlab code
B1rms = sqrtP2 .* Amplitude;



% %% For other shapes and durations: solve for P2 and integrals:
% % Use qMRlab to be able to explor different pulse shapes:
% MTflipAngle = 600; % this value doesn't matter for this section
% delta = 8000; % neither does this.
% pulseDur = 2.048e-3;
% SatPulseShape = 'gausshann';
% PulseOpt.bw = 0.3./pulseDur; % override default Hann pulse .
% HsatPulse = GetPulse(MTflipAngle, delta, pulseDur, SatPulseShape, PulseOpt);
% Trf = HsatPulse.Trf;
% t = 0:Trf/1000:Trf;
% y = HsatPulse.('b1')(t);
% %plot(t,y); hold on;
% 
% Integral_b1Norm = trapz(t,y)
% integSq = trapz(t,y.^2);
% p2 =  integSq/pulseDur;
% sqrtP2 = sqrt(p2)


