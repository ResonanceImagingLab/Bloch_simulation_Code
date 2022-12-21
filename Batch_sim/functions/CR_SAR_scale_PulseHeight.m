function Params = CR_SAR_scale_PulseHeight(Params)
% Uses SAR restrictions to give an estimate of the maximum pulse height 
% that can be used for the saturation pulses
% necessary parameters:
% numSat = number of sat pulses
% satRMS = root mean square of sat pulses (in Tesla)
% tp_sat = time of sat pulse (in seconds)
% numExc = number of excitation pulses
% flip = flip angle of excitation pulses (in degrees) 
% TR = time (in seconds)

if ~isfield(Params,'B0') % if not defined, assume 3T
    Params.B0 = 3; % main field strength (in Tesla)
end

if ~isfield(Params, 'boosted')
    error ('Please specify if boosted sat scheme is used (enter Params.boosted = 0 or 1)')
end

if Params.B0 == 7
    if strcmp(Params.TransmitCoil, 'STX')
        SAR_limit = 2.35; % Empirical value to match what I get at scanner
    end
else
    SAR_limit = 3; %(W/kg)
end
    

kg = 60; % reference weight
w0 = 42.58e6 *Params.B0;
epsilon = -1.35e-5*Params.TR + 2.21e-3;


%% Power = J/s. Multiply by pulse time to find J of work done
% For Excitation pulse
% (empiricalFactor*B1field^2) * numberPulses * time pulse
excB1 = (Params.flipAngle) / (360* 42.58e6 * Params.WExcDur);
J_exc = (epsilon * excB1^2 * w0^2)* (Params.numExcitation * Params.WExcDur); % Power (J/s) * time (s) = J

Jsat = SAR_limit*Params.TR*kg - J_exc; % J/(s*kg) *s*kg = J - J = J

if Jsat < 0
    Params.satRMS = 0;

else

    if Params.boosted % modify for different definition of numSatPulse
        SatPulseNumberTotal = Params.numSatPulse * Params.satTrainPerBoost;
    else
        SatPulseNumberTotal = Params.numSatPulse;
    end
    
    % Power sat = Joules / time of sat
    tSat = SatPulseNumberTotal*Params.pulseDur;
    Psat = Jsat / tSat;
    
    % Reorganize the Power equation to solve for B1 
    % B1 = sqrt(Psat/(epsilon*w0^2))
    Params.satRMS = sqrt(Psat/(epsilon*w0^2));

end
