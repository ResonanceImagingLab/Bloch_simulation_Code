function [outSig, M, time_vect] = BlochSimFlashSequence_1pool(Params, varargin)

% V2 carries the isochromats all the way through

%% Overview of how the code works with applicable function calls:
% 1. IF MTC -> call to Bloch_McConnell_wDipolar( Params, delta, b1) to get
%    RF saturation and spin evolution matrix

% 2. IF MTC -> call to SpinEvolution_Relaxation( Params, M_in, t);  for 
%    spin evolution for time gap

% 3. IF MTC & Last sat pulse done, call to XYmag_Spoil_1pool( Params, M_in, Params.MTSpoilTime, 1 )
%    for gradient spoiling, spin diffusion and spin evolution (option to set perfect spoil). 


% 4. Call to RotationMatrix_withBoundPool(Params.flipAngle*pi/180, RFphase(j)*pi/180, Params)
%    For instanteous excitation with a rotation matrix applied to the water
%    pool, and Bloch-McConnell style saturation of bound (and dipolar) pool.
%    This includes RF spoiling. 

% 5. Call to XYmag_Spoil_1pool( Params,M_in, Params.MTSpoilTime, 1 )
%    for gradient spoiling, spin diffusion and spin evolution (option to set perfect spoil). 

% 6. Call to SpinEvolution_Relaxation( Params, M_in, t);  for 
%    spin evolution for time gap


%% Use name-value pairs to override other variables set. Great for parfor loops!
for i = 1:2:length(varargin)
    if ischar(varargin{i})
        Params.(varargin{i}) = varargin{i+1};
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
M0 = [0 0 Params.M0a]';
I = eye(3); % identity matrix      
B = [0 0 Params.Raobs*Params.M0a]';

if Params.echoSpacing == 0
    Params.echoSpacing = 5e-3; % ensure value not 0
end    


if Params.MTC 
    error('Use BlochSimFlashSequence_v2.m for simulating MTC, 1 pool will not work');
else % with no MTC
    if Params.numExcitation == 1
        TD = 0;
        Params.echoSpacing = Params.TR; % For GRE and/or FLASH style sequence
        Params.DummyEcho = 0;
    else
        TD = Params.TR - Params.numExcitation*( Params.echoSpacing); % time in seconds
    end
end

if TD < 0
    error('Check timing variables, TD < 0');
end



%% Need to determine a sufficient number of isochromats. 
% can use this function to use more if needed.
% Params.N_spin = DetermineNumberIsoChromat(Params, TD)

if Params.PerfectSpoiling % number of spins wont matter in this case
    Params.N_spin = 1;
else
    Params.N_spin = 201;
end


%% Setup Matrices
Params.CalcVector = 1;

M = zeros(3,loops*20);
M(:,1) = M0;

time_vect = zeros( loops*20,1);
M_t = repmat(M0,1, Params.N_spin);

Sig_vec = zeros(num2avgOver, Params.numExcitation-Params.DummyEcho );
rep = 1; % to count over the number to average over

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start of sequence loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx = 2;

for i = 1:loops
    

    %% Excitation Block
    % Keep track of 3 magnetization vectors through excitation through
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
        R = RotationMatrix_1pool(Params.flipAngle*pi/180, RFphase(j)*pi/180);

        % Instanteous RF pulse

        M_t = pagemtimes(R,M_t); % 50 percent faster than loop

        % If you are missing pagemtimes, swap it with the slower code below:
        % for ns = 1:N_spin
        %    M_t(:,ns) = R*squeeze(M_t(:,ns));
        % end
    
        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1);
            idx = idx+1;
        end % For viewing;  

        %% Store the magnetization of each excitation pulse after 5 seconds prep
        if i > loops-num2avgOver && (j > Params.DummyEcho) 

            Sig_vec(rep,j - Params.DummyEcho ) = TransverseMagnetizationMagnitude(M_t);
    
           if (i == loops) && (j == Params.numExcitation) % if simulation is done...             
               outSig = mean(Sig_vec,1); % output 1xTurbofactor vector
               if Params.CalcVector == 1
                   M(:,idx:end) = [];
                   time_vect(idx:end) = [];
               end

               return
           end
            
           % increase repetition index
           if j == Params.numExcitation
               rep = rep+1;
           end
        end % End 'if SS_reached'   

        
        %% Apply Gradient Spoiling
        % Note that Params.echoSpace ~= 0. For Flash sequence, put all spin
        % evolution into here.
        
        M_t = XYmag_Spoil_1pool( Params, M_t, Params.echoSpacing, 0, 1);
               
        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1)+ Params.echoSpacing;
            idx = idx+1;
        end % For viewing;      
        
    end % End '1: Params.numExcitation' 
       
    %% Spin Evolution
      
    % Calculate spin evolution with diffusion
    if TD > 0
        M_t = XYmag_Spoil_1pool(Params, M_t, TD, 0, 0);

        if Params.CalcVector == 1
            M(:,idx) = mean(M_t,2); 
            time_vect(idx) = time_vect(idx-1)+TD;
            idx = idx+1;
        end % For viewing; 
    end


end





% %% Debug and view
% figure;
% plot(time_vect, sqrt(sum(M(1:2,:).^2)))
% % 
% figure;
% plot(time_vect, M(3,:))



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







