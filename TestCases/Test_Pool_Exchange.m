%% Test Pool Exchange

M_1 = M_in(:,1);

E = diag([ 1; 1; ...
    exp(-Params.Ra*t); exp(-Params.Rb*t); exp(-1/Params.T1D*t)] ) ;

t = 7e-3;
Eex = E;%eye(5);
Eex(3,3) = exp((-Params.kf-Params.Ra)*t);
Eex(4,3) = exp(Params.kf*t);
Eex(3,4) = exp(Params.kr*t);
Eex(4,4) = exp(( -Params.kr-Params.Rb)*t);

 



E = [-1/Params.T2a, 0,  0,     0,      0;...
      0, -1/Params.T2a,  0,     0,      0;...
      0, 0, -Params.kf-Params.Ra, Params.kr,   0;...
      0, 0, Params.kf, -Params.kr-Params.Rb,   0;...
      0, 0,         0,    0, -1/Params.T1D];


%% The problem is that exchange makes this not a tractable problem. 



M_final = zeros(size(M_in));

for i = 1:N_spin
    v = [exp(-Beta2(:,i)*Params.D), exp(-Beta2(:,i)*Params.D),...
        exp(-Beta1(:,i)*Params.D), exp(-Beta1(:,i)*Params.D),...
        exp(-Beta1(:,i)*Params.D)];

    A_D = diag(v) ;
    %M_final(:,i) = expm(A_D*t)*M_in(:,i) + (expm(A_D*t) - I)* (A_D\B);
    M_final(:,i) = E*A_D*M_in(:,i) + E0;
end












