function pulse = hyperbolicSecant_pulse(t, Trf, PulseOpt)

%   hyperbolicSecant_pulse Adiabatic hyperbolic secant RF pulse function.
%   pulse = hyperbolicSecant_pulse(t, Trf, PulseOpt)
%
%   The pulse is defined to be 0 outside the pulse window (before 
%   t = 0 or after t=Trf). (HSn, n = 1-8+) 
%
%   --args--
%   t: Function handle variable, represents the time.
%   Trf: Duration of the RF pulse in seconds.
%
%   --optional args--
%   PulseOpt: Struct. Contains optional parameters for pulse shapes.
%   PulseOpt.Beta: frequency modulation parameter
%   PulseOpt.n: time modulation - Typical 4 for non-selective, 1 for slab
% 
%   Reference: Matt A. Bernstein, Kevin F. Kink and Xiaohong Joe Zhou.
%              Handbook of MRI Pulse Sequences, pp. 110, Eq. 4.10, (2004)
%
%              Tannús, A. and M. Garwood (1997). "Adiabatic pulses." 
%              NMR in Biomedicine 10(8): 423-434.
%
%   See also GETPULSE, VIEWPULSE.
%
% To be used with qMRlab
% Written by Christopher Rowley 2023

if (nargin < 3); PulseOpt = struct; end

if(~isfield(PulseOpt,'beta') || isempty(PulseOpt.beta) || ~isfinite(PulseOpt.beta))
    % Default beta value 
    beta = 0.04;       
end

if(~isfield(PulseOpt,'n') || isempty(PulseOpt.n) || ~isfinite(PulseOpt.n))
    % Default beta value 
    n = 4;       
end

pulse =  sech(PulseOpt.beta* ( (t - Trf/2) *1000).^PulseOpt.n); % this equation works best with Trf in milliseconds. *1000
pulse((t < 0 | t>Trf)) = 0;
return; 

% figure; plot(t, abs(pulse), 'LineWidth', 3);

% Note that this function simply returns the shape. 
% However, the GetPulse command normalizes the amplitude based on the area.
% This isn't the case for adiabatic pulses. So we might need to do
% something else?

















































