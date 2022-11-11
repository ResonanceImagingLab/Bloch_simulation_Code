%% This code is meant to solve the signal equations 
% This requires knowledge of:
% - flip angle (in degrees)
% - repetition time TR

% Also need estimates of:
% B1field - in relative units, where 1 == nominal flip angle
% M0 - apparent signal
% T1- longitudinal relaxation rate

% Equations from:
% https://onlinelibrary.wiley.com/doi/epdf/10.1002/mrm.1910260109 Gowland
% and Leach 1992



function Sig= CR_MPRAGE_solver(flipAngle, TI, TR, B1field, T1, echoSpacing, turboFactor)

% Precalculate some variables
flip_a = (flipAngle*B1field) * pi / 180; % correct for B1 and convert to radians
alpha = cos(flip_a);
beta = exp(-echoSpacing/T1); % Tb = echoSpacing
mu = beta*alpha;
gamma = exp(-TI/T1); % Ta = TI
m = turboFactor;

Tw = TR - TI - (m - 1)*echoSpacing; % Tw = TD;
delta = exp(-Tw/T1);
rho = exp(-TR/T1);

M0 = 1;


% Mag equilibrium
eq1 = (alpha*delta*(1-beta)*  ( 1-mu^(m-1)))/(1-mu);
eq2 = alpha*delta*mu^(m-1);
eq3 = rho* alpha^m;
eq4 = 1+( rho* alpha^m);
Meq = -1* (1-delta + eq1 + eq2 - eq3)/eq4;


Sig = zeros(1,m);
for i = 1:m
    % Solve for magnetization
    M1 = ( (1-beta)*(1-mu^(i-1)))/ (1-mu);
    M2 = mu^(i-1)*(1-gamma);
    M3 = gamma*mu^(i-1)*Meq/M0;
    
    % We read out the value M with sin(flip)
    Sig(i) = sin(flip_a) * (M1+M2+M3);
end




% Equations from: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0096899
% Seem wrong/incorrectly explained?
% 
% flip_a = (flipAngle*B1field) * pi / 180; % correct for B1 and convert to radians
% 
% gamma = exp(-TI/T1);
% delta = exp(-echoSpacing/T1);
% phi = exp(-TD/T1);
% x = cos(flip_a);
% mu = delta*cos(flip_a);
% i = excPulseReadNum;
% M0 = 1;
% rho = 1;
% N = turboFactor;
% 
% % Mag equilibrium
% 
% eq1 = (phi*x*(1-delta)*(1-mu^(N-1)))/(1-mu);
% 
% eq2 = phi*x*mu^(N-1);
% 
% eq3 = rho* cos(alpha)*x^N;
% 
% eq4 = 1-( rho* cos(alpha)*x^N);
% 
% Meq = (1-phi + eq1 + eq2 + eq3)/eq4;
% 
% 
% % Solve for magnetization
% M1 = ( (1-delta)*(1-mu^(i-1)))/ (1-mu);
% M2 = mu^(i-1)*(1-gamma);
% M3 = gamma*mu^(i-1)*Meq/M0;
% 
% % We read out the value M with sin(flip)
% Sig = sin(flip_a) * (M1+M2-M3);

