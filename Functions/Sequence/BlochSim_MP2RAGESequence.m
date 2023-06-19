function [outSig1, outSig2, M, time_vect] = BlochSim_MP2RAGESequence(Params, varargin)

%% Overview of how the code works with applicable function calls:

% Sequence timing:
% TI1 = time between 180 inversion pulse, and middle of first excitation train(TF/2)
% ET1 = evolution time, between 180 inversion and first excitation
% EBT = excitation block timing (Turbofactor * echospacing) 
% TI2 = time between 180 inversion pulse, and middle of second excitation train(TF/2)
% ET2 = evolution time, between first and second excitation blocks
% TD = time delay after last excitation pulse (and echospacing) until next
%   inversion
% TR = ET + EBT + TD

% if centric, dummy echoes == 2, else ==0. 

%% Need to define defaults for:
% Params.InvPulseDur
% Params.InversionEfficiency
% Params.flipAngle, Params.flipAngle

Params.CalcVector = 1;

%% Use name-value pairs to override other variables set. Great for parfor loops!
for i = 1:2:length(varargin)
    if ischar(varargin{i})
        Params.(varargin{i}) = varargin{i+1};
    end
end

if length(Params.flipAngle) < 2
    Params.flipAngle = [Params.flipAngle, Params.flipAngle];
    disp('Only one flip angle entered, assuming it is used for both readouts');
end

if ~isfield(Params,'IncludeDipolar')
    Params.IncludeDipolar = 1; 
end

if ~isfield(Params,'InversionEfficiency')
    Params.InversionEfficiency = 0.96; 
end

Params.kf = (Params.R*Params.M0b); 
Params.kr = (Params.R*Params.M0a);

if isempty(Params.Ra) % allow you to specify either Ra or Raobs
    Params.Ra = Params.Raobs - ((Params.R * Params.M0b * (Params.R1b - Params.Raobs)) / (Params.R1b - Params.Raobs + Params.R));
    if isnan(Params.Ra)
        Params.Ra = 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Build sequence, then convert to loop structure.
% play sequence for 5 seconds, then fill sampling table.
stepSize = 50e-6; % 50 microseconds
RFphase = 0; % starting excitation phase
last_increment = 0;
num2avgOver = 20; % you get some variation in signal, so keep the last few and average

% Equivalent of 5 seconds of imaging to steady state, then record data. 
loops = ceil(6/Params.TR) + num2avgOver;

%% Standard Stuff
M0 = [0 0 Params.M0a, Params.M0b, 0]';

if Params.echoSpacing == 0 && Params.numExcitation > 1
    error( 'Please define Params.echoSpacing');
end   


% if centric, dummy echoes == 2, else ==0. 
if strcmp(Params.Readout, 'centric')
    error('Currently only supporting linear readouts.')
end

% With the above, we are assuming the signal value is in the middle of the
% readout:
readNum = ceil(Params.numExcitation/2);

%% Timing Variables
% INV ... ET1... EBT... ET2... EBT...TD... REPEAT

% excitation block timing (Turbofactor * echospacing) 
EBT = (Params.numExcitation+Params.DummyEcho)*( Params.echoSpacing);

% Inversion time needs to be specified by user
TI1 = Params.TI(1); 
TI2 = Params.TI(2); 

% evolution time, between 180 inversion and first excitation
ET1 = TI1 - EBT/2; 
ET2 = (TI2 - EBT/2) - (TI1 + EBT/2); 

if ET2 < 0 || ET1 < 0
    error('not enough time to permit acquisition blocks.')
end

% time delay after last excitation pulse (and echospacing) until next inversion
TD = Params.TR - (TI2 + EBT/2);

if Params.TR ~= (ET1 + EBT + ET2 + EBT+ TD)
    error('sequence timing does not add up to TR value')
end


% Impact of Excitation Pulse of Bound pool
Params = CalcBoundSatFrom2ExcitationPulse(Params, Params.flipAngle(1), Params.flipAngle(2));
Params = CalcBoundSatFromInversionPulse(Params); % Rrfb_exc and Rrfd_exc for inversion pulses

%% Need to determine a sufficient number of isochromats. 
% can use this function to use more if needed.
% Params.N_spin = DetermineNumberIsoChromat(Params, TD)

if Params.PerfectSpoiling % number of spins wont matter in this case
    Params.N_spin = 1;
else
    Params.N_spin = 201;
end


%% Setup Matrices
M = zeros(5,loops*20);
M(:,1) = M0;

time_vect = zeros( loops*20,1);
M_t = repmat(M0,1, Params.N_spin);

Sig_vec1 = zeros(num2avgOver, 1 );
Sig_vec2 = zeros(num2avgOver, 1 );
rep = 1; % to count over the number to average over

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start of sequence loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx = 2;

for i = 1:loops
    
    %% Start by applying an inversion pulse

    R = RotationMatrix_withBoundPool_Inversion( pi*Params.InversionEfficiency, 0, Params);

    % Instanteous RF pulse
    M_t = pagemtimes(R,M_t); % 50 percent faster than loop

    % for ns = 1:N_spin
    %    M_t(:,ns) = R*squeeze(M_t(:,ns));
    % end

    if Params.CalcVector == 1
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1);
        idx = idx+1;
    end % For viewing; 

    %% Spin evolution over time ET1
    M_t = XYmag_Spoil(Params, M_t, ET1, 0, 0);

    if Params.CalcVector == 1
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1) + ET1;
        idx = idx+1;
    end % For viewing; 


    %% Excitation Block
    % Keep track of 5 magnetization vectors through excitation through
    % instanteous rotation of water pool, plus 'instanteous' saturation of bound pool
    % Keep track of XY mag for RF spoiling, gradient spoiling and spin diffusion. 
    % Signal == XY magnetization immediately following application of Rotation. 
    
    % Compute the RF phase for spoiling for entire excitation train
    if Params.RFspoiling
        [RFphase, last_increment] = IncrementRFspoilPhase( RFphase(end), Params, last_increment);
    else
        RFphase = zeros(1,Params.numExcitation);
    end
    
    for j = 1: Params.numExcitation
        
        % Calculate rotation matrix for excitation-specific phase
        R = RotationMatrix_withBoundPool_MP2RAGE(Params.flipAngle(1)*pi/180, RFphase(j)*pi/180, Params, 1);

        % Instanteous RF pulse
        M_t = pagemtimes(R,M_t); % 50 percent faster than loop

        % for ns = 1:N_spin
        %    M_t(:,ns) = R*squeeze(M_t(:,ns));
        % end
    
        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1);
            idx = idx+1;
        end % For viewing;  

        %% Store the magnetization of each excitation pulse after 5 seconds prep
        if i > loops-num2avgOver && (j == readNum) 

            Sig_vec1(rep) = TransverseMagnetizationMagnitude(M_t);
    
           if (i == loops) && (j == readNum) % if simulation is done...             
               outSig1 = mean(Sig_vec1); 
           end
            
        end % End 'if SS_reached'   

        
        %% Apply Gradient Spoiling
        % Note that Params.echoSpace ~= 0.
        M_t = XYmag_Spoil( Params, M_t, Params.echoSpacing, 0, 1);
            
        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1)+ Params.echoSpacing;
            idx = idx+1;
        end % For viewing;      
        
    end % End '1: Params.numExcitation' 

    %% Spin evolution between two excitation trains, over time ET2
    M_t = XYmag_Spoil(Params, M_t, ET2, 0, 0);

    if Params.CalcVector == 1
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1) + ET2;
        idx = idx+1;
    end % For viewing; 


    %% Excitation Block - 2nd image
    
    % Compute the RF phase for spoiling for entire excitation train
    if Params.RFspoiling
        [RFphase, last_increment] = IncrementRFspoilPhase( RFphase(end), Params, last_increment);
    else
        RFphase = zeros(1,Params.numExcitation);
    end
    
    for j = 1: Params.numExcitation
        
        % Calculate rotation matrix for excitation-specific phase
        R = RotationMatrix_withBoundPool_MP2RAGE(Params.flipAngle(2)*pi/180, RFphase(j)*pi/180, Params, 2);

        % Instanteous RF pulse
        M_t = pagemtimes(R,M_t); % 50 percent faster than loop

        % for ns = 1:N_spin
        %    M_t(:,ns) = R*squeeze(M_t(:,ns));
        % end
    
        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1);
            idx = idx+1;
        end % For viewing;  

        %% Store the magnetization of each excitation pulse after 5 seconds prep
        if i > loops-num2avgOver && (j == readNum) 

            Sig_vec2( rep ) = TransverseMagnetizationMagnitude(M_t);
    
           if (i == loops) && (j == readNum) % if simulation is done...             
               outSig2 = mean(Sig_vec2); % output 1xTurbofactor vector
               
               if Params.CalcVector == 1
                   M(:,idx:end) = [];
                   time_vect(idx:end) = [];
               end
               
               return;
           end
            
           % increase repetition index
           if j == readNum
               rep = rep+1;
           end
        end % End 'if SS_reached'   

        
        %% Apply Gradient Spoiling
        % Note that Params.echoSpace ~= 0.
        M_t = XYmag_Spoil( Params, M_t, Params.echoSpacing, 0, 1);
            
        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1)+ Params.echoSpacing;
            idx = idx+1;
        end % For viewing;      
        
    end % End '1: Params.numExcitation' 


    %% Spin evolution over time TD
    M_t = XYmag_Spoil(Params, M_t, TD, 0, 0);

    if Params.CalcVector == 1
        M(:,idx) = mean(M_t,2); 
        time_vect(idx) = time_vect(idx-1)+TD;
        idx = idx+1;
    end % For viewing; 

end





% %% Debug and view
% figure;
% plot(time_vect, sqrt(sum(M(1:2,:).^2)))
% % 
figure;
plot(time_vect, M(3,:))
% 
% figure;
% plot(time_vect, M(4,:))

% warning('') % Clear last warning message
% [warnMsg, warnId] = lastwarn;
% if ~isempty(warnMsg)
% return
% end

% 
% figure;
% plot(M_t(1,:),'-r','LineWidth',1)
% hold on
% plot(M_t(2,:),'--b')

