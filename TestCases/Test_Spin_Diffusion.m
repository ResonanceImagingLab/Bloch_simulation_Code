% Test Diffusion Scripts

load("M_in.mat")

Params.B0 = 3;
Params.MTC = 0; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params.echoSpacing = 7.7/1000;

Params.TR = 15/1000;
Params.flipAngle = 5;
Params.numExcitation = 1;
Params.MTC = 0; % Magnetization Transfer Contrast

Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

Params.kf = (Params.R*Params.M0b); 
Params.kr = (Params.R*Params.M0a);

%% Other Matrices:
E = [-1/Params.T2a, 0,  0,     0,      0;...
      0, -1/Params.T2a,  0,     0,      0;...
      0, 0, -Params.kf-Params.Ra, Params.kr,   0;...
      0, 0, Params.kf, -Params.kr-Params.Rb,   0;...
      0, 0,         0,    0, -1/Params.T1D];

B = [0 0 Params.Ra*Params.M0a, Params.Rb*Params.M0b, 0]';

I = eye(5);


%% Calculate Gradient Spoiling:
G_t = Params.G_t;
G = Params.GradientSpoilingStrength/1000;
gam = 2*pi*42.577478518e6;
N_spin = size(M_in,2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% another iteration... working right to left. Not combining all at once, do separately and compare. 

% Next apply spin diffusion matrix.
t = 0.007;
[Beta1, Beta2] = ComputeDiffusionBetas(M_in, Params, gam, G, G_t);


v = [exp(-Beta2*t), exp(-Beta2*t),...
    exp(-Beta1*t), exp(-Beta1*t),...
    exp(-Beta1*t)];
 
M_out2 = zeros(size(M_in));
for i = 1:N_spin
        M_out2(:,i) = diag(v)*M_in(:,i);
end

figure;
plot(M_in(1,:),'-r','LineWidth',1)
hold on
plot(M_out2(1,:),'--r')
plot(M_in(2,:),'-b','LineWidth',1)
plot(M_out2(2,:),'--b')
hold off



v = [(-Beta2), (-Beta2),...
    (-Beta1), (-Beta1),...
    (-Beta1)];

A_D = E*diag(v);
t = 1;
M_final = zeros(size(M_in));
for i = 1:N_spin
        M_final(:,i) =expm(A_D*t)*M_in(:,i) + (expm(A_D*t) - I)* (A_D\B);
end



figure;
plot(M_in(1,:),'-r','LineWidth',3)
hold on
plot(M_final(1,:),'--r')
plot(M_in(2,:),'-b','LineWidth',3)
plot(M_final(2,:),'--b')
hold off









v = [(-Beta2), (-Beta2),...
    (-Beta1), (-Beta1),...
    (-Beta1)];

A_D = E*diag(v);
t = 1;
M_final = zeros(size(M_in));
for i = 1:N_spin
        M_final(:,i) =expm(A_D*t)*M_in(:,i) + (expm(A_D*t) - I)* (A_D\B);
end



























% Test to ignore transverse relaxation to see impact of diffusion pool
E = [-1, 0,  0,     0,      0;...
      0, -1,  0,     0,      0;...
      0, 0, -Params.kf-Params.Ra, Params.kr,   0;...
      0, 0, Params.kf, -Params.kr-Params.Rb,   0;...
      0, 0,         0,    0, -1/Params.T1D];

% E = [-1/Params.T2a, 0,  0,     0,      0;...
%       0, -1/Params.T2a,  0,     0,      0;...
%       0, 0, -Params.kf-Params.Ra, Params.kr,   0;...
%       0, 0, Params.kf, -Params.kr-Params.Rb,   0;...
%       0, 0,         0,    0, -1/Params.T1D];

B = [0 0 Params.Ra*Params.M0a, Params.Rb*Params.M0b, 0]';



%% Slight change to the equations used to pull out time
M_final = zeros(size(M_in));

for i = 1:N_spin

    v = [exp(-Beta2(:,i)), exp(-Beta2(:,i)),...
        exp(-Beta1(:,i)), exp(-Beta1(:,i)),...
        exp(-Beta1(:,i))];

    A_D = E*diag(v);
    M_final(:,i) =expm(A_D*t)*M_in(:,i) + (expm(A_D*t) - I)* (A_D\B);
end


figure;
plot(M_in(1,:),'-r','LineWidth',3)
hold on
plot(M_final(1,:),'-b')
hold off


figure;
plot(M_in(2,:),'-r','LineWidth',3)
hold on
plot(M_final(2,:),'-b')
hold off


% Difference on the order of 2e-4 when t = 1e-3sec
% Difference on the order of 2e-3 when t = 1e-2sec
% Difference on the order of 2e-2 when t = 1e-1sec
t1 = sqrt( sum(M_in(1:2,:).^2));
t2 = sqrt( sum(M_final(1:2,:).^2));
figure;
plot(t2-t1);


%% Play with the gradient strength


G_t = Params.G_t;
G = 0;
t = 1e-1; % in seconds

[Beta1, Beta2] = ComputeDiffusionBetas(M_in, Params, gam, G, G_t);


M_final = zeros(size(M_in));

for i = 1:N_spin

    v = [exp(-Beta2(:,i)), exp(-Beta2(:,i)),...
        exp(-Beta1(:,i)), exp(-Beta1(:,i)),...
        exp(-Beta1(:,i))];

    A_D = E*diag(v);
    M_final(:,i) =expm(A_D*t)*M_in(:,i) + (expm(A_D*t) - I)* (A_D\B);
end



% Difference on the order of 10e-8 when t = 8e-3sec
% Difference on the order of 10e-6 when t = 8e-2sec
% Difference on the order of 10e-4 when t = 8e-1sec
t1 = sqrt( sum(M_in(1:2,:).^2));
t2 = sqrt( sum(M_final(1:2,:).^2));
figure;
plot(t2-t1);




%%
%%%%%%%%%% Comoing from  https://github.com/lamyj/sycomore/blob/master/src/sycomore/epg/Discrete3D.cpp
G = [Params.GradientSpoilingStrength/1000;0; 0];
tau = Params.G_t;
delK = gam*G*tau;


delKprod = zeros(3);

for m = 1:3
    for n = 1:3
        delKprod(m,n) = 1.3*tau*delK(m)*delK(n);
    end
end



G_t = Params.G_t;
G = Params.GradientSpoilingStrength/1000;
gam = 2*pi*42.577478518e6;
N_spin = size(M_in,2);








