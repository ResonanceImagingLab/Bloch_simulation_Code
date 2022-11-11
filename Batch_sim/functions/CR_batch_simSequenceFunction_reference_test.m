function [inputMag, B1_val] = CR_batch_simSequenceFunction_reference_test(Params, varargin)

% 
% Params.delta = ParameterSet(qi,1);
% Params.flipAngle= ParameterSet(qi,2);
% Params.TR= ParameterSet(qi,3);
% Params.numSatPulse= ParameterSet(qi,4);
% Params.pulseDur= ParameterSet(qi,5);
% Params.numExcitation= ParameterSet(qi,6);
% Params.satTrainPerBoost= ParameterSet(qi,7);
% Params.TR_MT= ParameterSet(qi,8);
% Params.freqPattern='single';


%% Use name-value pairs to override other variables set. Great for parfor loops!
for i = 1:2:length(varargin)
    if ischar(varargin{i})
        Params.(varargin{i}) = varargin{i+1};
    end
end


%% Dummy echoes the way the TFL sequence adds them
if Params.numExcitation == 1
    Params.DummyEcho = 0;
elseif Params.numExcitation < 4
    Params.DummyEcho = 1;
else 
    Params.DummyEcho = 2;
end

Params.numExcitation = Params.numExcitation + Params.DummyEcho;


necessTime = Params.numExcitation*(Params.echoSpacing); 
B1_val = 0; % no MT pulse

if necessTime > Params.TR
    inputMag = 0;           
    return;
else
  Params.boosted = 0;
  Params.b1 = 0;
  Params.MTC = 0;
  [inputMag, M, time_vect] = BlochSimFlashSequence_v2(Params,'b1',0,'MTC',0); % reference signal simulation
end

                        
% figure;
% plot(time_vect, sqrt(sum(M(1:2,:).^2)))
% 
figure;
plot(time_vect, M(3,:))

figure;
plot(time_vect, M(4,:))                        
                        
                        
