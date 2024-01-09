function M_out = SpinEvolution_Relaxation_1pool( Params, M_in, t)

% Calculate spin evolution in the absence of RF and gradients

% Input is:
% Params structure that stores a bunch of variables
% M_in is a 5x Number_spin vector
% t is the time over which this step occurs

% You have the option to insert a wide matrix with lots of spins, or pool
% all the spins, and calculate 1 vector. 


M_out = [ M_in(1,:) *exp(-t/Params.T2a);...
     M_in(2,:) *exp(-t/Params.T2a);...
     Params.M0a - (Params.M0a - M_in(3,:))*exp(-t*Params.Raobs)] ;




% M_in = [0.3; 0.3; 0.8; 0.02; 0.1];

% ns = size(M_in,2);
% B = [0 0 Params.Raobs*Params.M0a]';
% I = eye(3);
% 
% % Evolution Matrix
% E = [-1/Params.T2a, 0,  0,;...
%       0, -1/Params.T2a,  0,;...
%       0, 0, Params.Raobs];


% Not efficient to do it this way as there is a solution, might fix later.
% M_out = zeros(3,ns);
% for i = 1:ns
%     M_out(:,i) = expm(E*t) * M_in(:,i) + (expm(E*t) - I)* (E\B);
% end