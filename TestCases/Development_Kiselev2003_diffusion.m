
%


N_spin = size(M_in,2);
gam = 2*pi*42.577478518e6; % gyromagnetic ratio in rad*T/s 
r  = linspace(0,Params.ReadoutResolution, N_spin); % meters


t = 3e-3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

D_coeff = 1/((4*pi*Params.D*t)^(3/2));

Iz = [0, 1i, 0; -1i, 0, 0; 0, 0, 0];
Iz2 = Iz^2;

r  = linspace(0,Params.ReadoutResolution, 8); % meters

r = 5e-5;
G = Params.GradientSpoilingStrength/1000;
gam = 2*pi*42.577478518e6; % gyromagnetic ratio in rad*T/s 
g = gam* G;


exp1 = -1*r.^2/(4*Params.D*t);
exp2 = 1i*g*t*(r/2)*Iz;
exp3 = -1*Params.D .*g^2*t^3.12*Iz2;

phi = D_coeff*expm(exp1+exp2+exp3);


M0 =[0,0,0;0,0,0;1,1,1];
PHI = M0 + phi;


gam* t* G*r








%um^2/ms to m/s

1e-6 *1e-6 *1000



