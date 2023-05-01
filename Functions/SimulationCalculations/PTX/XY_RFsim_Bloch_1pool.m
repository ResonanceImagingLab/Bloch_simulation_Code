function M_out = XY_RFsim_Bloch_1pool( M_in, T1, T2, Bx, By, Bz, t )

function M_out = XY_RFsim_Bloch_1pool( M_in, T1, T2, Bx, By, Bz, t )

% For reading purposes, you can check out: https://en.wikipedia.org/wiki/Bloch_equations

% % Requirements: 
% M_in - input magnetization Mx3 size. (x,y,z are columns)
% T1 - longitudinal relaxation rate
% T2 - transverse relaxation rate
% Bx - real component of the B1 field. 
% By - imaginary component of the B1 field
% Bz - main magnetic field = B0 + inhomogeneity field
% t  - time step for evaluation

% Input units are assumes to be in seconds, Hz and Telsa.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build the matrix:
R1 = 1/T1;   % 1/s
R2a = 1/T2;   % 1/s
gam = 42.58e6; % Hz/T  % convert to rad with 2*pi
[sx, ~] = size(M_in);
transposeFlag = 0;

if sx == 3
    M_in = M_in';
    transposeFlag = 1;
    [sx, ~] = size(M_in);
end

% Preset B relaxation matrix (size 3x1)
I = eye(3);      % identity matrix      
B_mat = [0, 0, R1]'; % assume M0a = 1.


%% Build A_matrix so it is in the form:
% % Precalculated A matrix containing RF and relaxation info (size nxnx)
% A_mat =[ -R2a,       gam*Bz,  -gam*By; ...  % Water X
%         -gam*Bz,      -R2a,    gam*Bx; ...  % Water Y
%          gam*By,   -gam*Bx,       -R1 ];    % Water Z

% For this, we work down columns, then over
% If we want to go with rotating frame, convert Bz to the offresonant
% frequency. (delta = gamma *B0 - omega)

A_mat = zeros(9,sx);
A_mat([1,5],:) = -R2a;
A_mat(2,:) = -gam*Bz;
A_mat(3,:) = gam*By;
A_mat(4,:) = gam*Bz;
A_mat(6,:) = -gam*Bx;
A_mat(7,:) = -gam*By;
A_mat(8,:) = gam*Bx;
A_mat(9,:) = -R1;

A_mat = reshape(A_mat,[3,3,sx]); 

% % If you are running an older Matlab and do not have pagemtimes, you can use:
M_out = zeros(sx,3);
for i = 1:sx
    M_out(i,:) = expm(A_mat(:,:,i)*t) * M_in(i,:)' + (expm(A_mat(:,:,i)*t) - I)* (A_mat(:,:,i)\B_mat);
end

if transposeFlag
    M_out = M_out';
end


% Now apply:
% AExp = expm(A_mat*t);
% AEnd = (AExp - I)* (A_mat\B_mat);
% M_out = pagemtimes(AExp, M_in) + AEnd;



% % If you are running an older Matlab and do not have pagemtimes, you can use:
% ns = length(M_in);
% M_out = zeros(5,ns);
% for i = 1:ns
%     M_out(:,i) = expm(A_mat*t) * M_in(:,i) + (expm(A_mat*t) - I)* (A_mat\B);
% end
% % Not that this is slower



