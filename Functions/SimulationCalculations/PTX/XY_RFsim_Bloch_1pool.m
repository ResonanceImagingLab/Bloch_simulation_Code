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
gam = 42.58e6 % Hz/T  % convert to rad with 2*pi

% Precalculated A matrix containing RF and relaxation info (size nxn)
A_mat =[ -R2a,       gam*Bz,  -gam*By; ...  % Water X
        -gam*Bz,      -R2a,    gam*Bx; ...  % Water Y
         gam*By,   -gam*Bx,       -R1 ];    % Water Z

% Preset B relaxation matrix (size nx1)
I = eye(3);      % identity matrix      
B_mat = [0, 0, R1]'; % assume M0a = 1.

% Now apply:
AExp = expm(A_mat*t);
AEnd = (AExp - I)* (A_mat\B_mat);
M_out = pagemtimes(AExp, M_in) + AEnd;



% % If you are running an older Matlab and do not have pagemtimes, you can use:
% ns = length(M_in);
% M_out = zeros(5,ns);
% for i = 1:ns
%     M_out(:,i) = expm(A_mat*t) * M_in(:,i) + (expm(A_mat*t) - I)* (A_mat\B);
% end
% % Not that this is slower



