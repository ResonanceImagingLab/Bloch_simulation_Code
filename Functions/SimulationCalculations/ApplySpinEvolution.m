function M_final = ApplySpinEvolution( Params, M_in, t, MTC, Gradient )

% Relaxation, gradient spoiling and diffusion effects with bound pool exchange 
% Diffusion limited to sections longer than 10ms due to instability below
% this

% Input is:
% Params structure that stores a bunch of variables
% M_t is a 5xnSpins vector
% t is the time over which this step occurs

% Need values in Params structure for:
% Params.G_t -> gradient time in seconds
% Params.G -> gradient height in mT/m.
% Params.D -> diffusion coefficient in m/s!


% Relevant sources:
% Kiselev, V.G., 2003. Calculation of diffusion effect for arbitrary pulse sequences. J. Magn. Reson. 164, 205–211. https://doi.org/10.1016/S1090-7807(03)00241-6
% Yarnykh, V.L., 2010. Optimal radiofrequency and gradient spoiling for improved accuracy of T1 and B1 measurements using fast steady-state techniques. Magn. Reson. Med. 63, 1610–1626. https://doi.org/10.1002/mrm.22394
% Jochimsen, T.H., Schäfer, A., Bammer, R., Moseley, M.E., 2006. Efficient simulation of magnetic resonance imaging with Bloch-Torrey equations using intra-voxel magnetization gradients. J. Magn. Reson. 180, 29–38. https://doi.org/10.1016/j.jmr.2006.01.001
% Sled, J.G., Pike, G.B., 2000. Quantitative Interpretation of Magnetization Transfer in Spoiled Gradient Echo MRI Sequences. J. Magn. Reson. 145, 24–36. https://doi.org/10.1006/jmre.2000.2059
% Kose, R., Kose, K., 2017. BlochSolver: A GPU-optimized fast 3D MRI simulator for experimentally compatible pulse sequences. J. Magn. Reson. 281, 51–65. https://doi.org/10.1016/j.jmr.2017.05.007
I = eye(5);
N_spin = size(M_in,2);
gam = 2*pi*42.577478518e6; % gyromagnetic ratio in rad*T/s 


%% Toggle between two spoiling, one for MT and one for water:
if Gradient
    
    if MTC % Spoil Sat pulse
        G_t = Params.G_t_MT;
        G = Params.GradientSpoilingStrength_MT/1000;
    
    else % Spoil water excitation
        G_t = Params.G_t;
        G = Params.GradientSpoilingStrength/1000;
    end
    
    %% Do gradient dephasing first:
    
    dis = linspace(0,Params.ReadoutResolution, N_spin); % meters
    theta = gam* G_t* G*dis ; % seconds * rad/T * T/m *m -> radians
    
    % Apply with rotation matrix over the x and y
    M_out = M_in;
    
    % Rotation matrix
    for i = 1: N_spin
        R = [ cos(theta(i)) , -sin(theta(i)); ...
            sin(theta(i)), cos(theta(i))];
        M_out(1:2,i) = R * M_in(1:2,i);
    end
else % if you only want diffusion
    M_out = M_in;
    G_t = 0;
    G = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Diffusion 
% as in Jochimsen et al. 

if Params.ModelSpinDiffusion
    [Beta1, Beta2] = ComputeDiffusionBetas(M_in, Params, gam, G, G_t);
    
    for i = 1:N_spin
    
            v = [exp(-Beta2(i)*t), exp(-Beta2(i)*t),...
                exp(-Beta1(i)*t), exp(-Beta1(i)*t),...
                exp(-Beta1(i)*t)];
    
            M_out(:,i) = diag(v)*M_out(:,i);
    end
end
%% relaxation terms.

E = [-1/Params.T2a, 0,  0,     0,      0;...
      0, -1/Params.T2a,  0,     0,      0;...
      0, 0, -Params.kf-Params.Ra, Params.kr,   0;...
      0, 0, Params.kf, -Params.kr-Params.Rb,   0;...
      0, 0,         0,    0, -1/Params.T1D];

B = [0 0 Params.Ra*Params.M0a, Params.Rb*Params.M0b, 0]';

M_final = zeros(size(M_out));

for i = 1:N_spin
        M_final(:,i) =expm(E*t)*M_out(:,i) + (expm(E*t) - I)* (E\B);
end


% figure
% plot(sqrt(sum(M_in(1:2,:).^2)))
% hold on; 
% plot(sqrt(sum(M_out(1:2,:).^2)))
% legend
% 
% figure
% plot((M_in(2,:)))
% hold on; 
% plot((M_out(2,:)))
% plot((M_in(1,:)))
% hold on; 
% plot((M_out(1,:)))
% legend




% % Try to follow the Kose and Kose 2017 approach
% delX = Params.ReadoutResolution / Params.N_spin;
% Grad2D = zeros(size(M_in));
% for i = 1:N_spin
%     if i == 1
%         Grad2D(:,i) =Params.D * (2*M_out(:,i+1)-2*M_out(:,i)) /delX; % handle edge case
%     elseif i == N_spin
%         Grad2D(:,i) =Params.D * (2*M_out(:,i-1)-2*M_out(:,i)) /delX; % handle edge case
%     else
%         Grad2D(:,i) =Params.D * (M_out(:,i+1)+M_out(:,i-1)-2*M_out(:,i)) /delX; 
%     end
% end

% for i = 1:N_spin
%     E_t = E;
%     E_t(1,1) = E_t(1,1) + Grad2D(1,i);
%     E_t(2,2) = E_t(2,2) + Grad2D(2,i);
% 
%     M_final(:,i) = expm(E_t*t)*M_out(:,i) + (expm(E_t*t) - I)* (E_t\B);
% end




%% Code in case you need to threshold out diffusion
% if t > 10e-2
%     [Beta1, Beta2] = ComputeDiffusionBetas(M_in, Params, gam, G, G_t);
% end
% 
% if t > 10e-2
%     
%     for i = 1:N_spin
%         v = [exp(-Beta2(:,i)), exp(-Beta2(:,i)),...
%             exp(-Beta1(:,i)), exp(-Beta1(:,i)),...
%             exp(-Beta1(:,i))];
%     
%         A_D = E*diag(v);
%         M_final(:,i) =expm(A_D*t)*M_out(:,i) + (expm(A_D*t) - I)* (A_D\B);
%     end
% 
% else
%     for i = 1:N_spin
%    
%         A_D = E;
%         M_final(:,i) =expm(A_D*t)*M_out(:,i) + (expm(A_D*t) - I)* (A_D\B);
%     end
% end





