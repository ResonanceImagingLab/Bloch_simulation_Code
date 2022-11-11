% Trying to figure out how to make the code run faster for isochromat
% multiplcation

% https://www.mathworks.com/matlabcentral/answers/456711-how-can-i-do-matrix-multiplication-on-sets-of-data-in-an-array-without-looping
% https://www.mathworks.com/matlabcentral/fileexchange/25977-mtimesx-fast-matrix-multiply-with-multi-dimensional-support

% Some large sample data
n = 1000000;
Tc0 = rand(4*n,4);
T01 = rand(4*n,4);
T12 = rand(4*n,4);

% The loop method with 4x4 elements scattered in memory
disp(' ');
disp('The M-code loops method:')
tic

q = size(T12,1);
Tc3 = zeros(q,4);
    for i=1:4:q
        Tc3(i:i+3,1:4) = ((Tc0(i:i+3,1:4)*T01(i:i+3,1:4))*T12(i:i+3,1:4));
    end
toc    

% Suppose we had the 4x4 elements contiguous in memory to start with in 3D arrays
Tc0t = reshape(Tc0.',4,4,[]); Tc0t = permute(Tc0t,[2 1 3]);
T01t = reshape(T01.',4,4,[]); T01t = permute(T01t,[2 1 3]);
T12t = reshape(T12.',4,4,[]); T12t = permute(T12t,[2 1 3]);
disp(' ');
disp('The MTIMESX method:');
fprintf('The compiler used: %s\n',mtimesx('compiler')) % Load mtimesx and print out the compiler used
fprintf('The calculation mode: %s\n',mtimesx('speedomp')) % Put mtimesx into fastest mode
fprintf('Number of threads available: %d\n',mtimesx('omp_get_max_threads')) % Print number of threads available
% Do the nD matrix multiply on the 2D pages with compiled parallel mex C-code
tic
Tc3x = mtimesx(mtimesx(Tc0t,T01t),T12t);
toc
% Compare the results
disp(' ');
disp('Are the results equal?');
Tc3m = permute(reshape(Tc3.',4,4,[]),[2 1 3]);
isequal(Tc3m,Tc3x)




%% The above requires a compiled C version. Another answerer (Jon) suggested using a sparse matrix.
% https://www.mathworks.com/matlabcentral/answers/456711-how-can-i-do-matrix-multiplication-on-sets-of-data-in-an-array-without-looping

% put stacked matrices into block diagonal matrices and multiply
Tc3diag = blkdiag(Tc0(1:4,:),Tc0(5:8,:),Tc0(9:12,:))*...
    blkdiag(T01(1:4,:),T01(5:8,:),T01(9:12,:))*...
    blkdiag(T12(1:4,:),T12(5:8,:),T12(9:12,:));
% collapse the output block diagonal matrix into a stacked matrix
Tc3= [Tc3diag(1:4,1:4);Tc3diag(5:8,5:8);Tc3diag(9:12,9:12)];



%% There was the issue in the above that he assumed only 3 matrices, for more:
%% sparse block matrix multiplication
N = 1e6;
% make sparse block diagonal matrices
Tc0blocks = cell(N,1);
T01blocks = cell(N,1);
T12blocks = cell(N,1);
% loop to assign individual block elements
for k = 1:N
    Tc0blocks{k} = sparse(rand(4,4));
    T01blocks{k}= sparse(rand(4,4));
    T12blocks{k} = sparse(rand(4,4));
end
    
% combine into block diagonal matrices
% They will be sparse because elements are sparse
Tc0 = blkdiag(Tc0blocks{:});
T01 = blkdiag(T01blocks{:});
T12 = blkdiag(T12blocks{:});
disp('  ')
disp('elapsed time for sparse block diagonal matrix approach')
tic
Tc3 = Tc0*T01*T12;
toc





%% In the MTIMESX page discussion, the auther noted that matlab has provided a function in R2020b called:
% pagemtimes which should do the same as the MTIMESX

% Z = pagemtimes(X,Y)
% Z(:,:,i) = X(:,:,i)*Y(:,:,i).
% X is a matrix, then Z(:,:,i) = X*Y(:,:,i).



%%
% Try this out:
j = 1;
R = RotationMatrix_withBoundPool(Params.flipAngle*pi/180, RFphase(j)*pi/180, Params);


temp1 = zeros(size(M_t));
tic
for ns = 1:N_spin
    temp1(:,ns) = R*squeeze(M_t(:,ns));
end
toc % 0.008887 sec

tic
temp2 = pagemtimes(R,M_t);
toc % 0.004625


isequal(temp1,temp2)


figure;
plot(temp1(1,:))
hold on
plot(temp2(1,:))



%% Different rotation matrix:
tic
M_out = M_t;
for i = 1: N_spin
    R = [ cos(theta(i)) , -sin(theta(i)); ...
        sin(theta(i)), cos(theta(i))];
    M_out(1:2,i) = R * M_out(1:2,i);
end
toc


R = [ cos(theta) , -sin(theta); ...
        sin(theta), cos(theta)];


tic
M_out = M_t;
R1 = cos(theta);
R2 = sin(theta);
R = permute( reshape(   [R1;-R2;R2; R1]  , 2,2,[]) , [2,1,3]);

temp = M_t(1:2,:);
temp = permute(temp,[1,3,2]);
tic
temp2 = pagemtimes(R, temp);
toc % 0.004625



tic
M_out = M_t;
R1 = cos(theta);
R2 = sin(theta);
R = permute( reshape(   [R1;-R2;R2; R1]  , 2,2,[]) , [2,1,3]);
toc
for i = 1: N_spin

    M_out(1:2,i) = R(:,:,i) * M_out(1:2,i);
end
toc


%% Spin evolution:
tic
temp = zeros(size(M_in));
for i = 1:ns
    temp(:,i) = expm(E*t) * M_in(:,i) + (expm(E*t) - I)* (E\B);
end
toc


tic
temp2 = zeros(size(M_in));
tExp = fastExpm(E*t);
for i = 1:ns
    
    temp2(:,i) = tExp * M_in(:,i) + (tExp - I)* (E\B);
end
toc



tic

tExp = fastExpm(E*t);
toc
tic
ttexp = expm(E*t);
toc

tEnd = (tExp - I)* (E\B);
temp3 = pagemtimes(tExp, M_in) + tEnd;
toc

for i = 1:ns
    
    temp2(:,i) = tExp * M_in(:,i) + (tExp - I)* (E\B);
end
toc




for i = 1:ns
    
    temp2(:,i) = tExp * M_in(:,i) + (tExp - I)* (E\B);
end
toc


figure;
plot(temp3(1,:))
hold on
plot(temp2(1,:))


figure;
plot(temp3(2,:))
hold on
plot(temp2(2,:))








tic
M_t = repmat(M(:,idx-1),1, Params.N_spin);
toc

%%%%%%%%%%%%%%%%%%%%%%%%
%% Method one
tic
M_out = M_in;
for i = 1: N_spin
    R = [ cos(theta(i)) , -sin(theta(i)); ...
        sin(theta(i)), cos(theta(i))];
    M_out(1:2,i) = R * M_in(1:2,i);
end


delX = Params.ReadoutResolution / Params.N_spin;
Grad2D = zeros(size(M_in));


for i = 1:N_spin
    if i == 1
        Grad2D(:,i) =Params.D * (2*M_out(:,i+1)-2*M_out(:,i)) /delX; % handle edge case
    elseif i == N_spin
        Grad2D(:,i) =Params.D * (2*M_out(:,i-1)-2*M_out(:,i)) /delX; % handle edge case
    else
        Grad2D(:,i) =Params.D * (M_out(:,i+1)+M_out(:,i-1)-2*M_out(:,i)) /delX; 
    end
end

% Combine these diffusion terms with relaxation terms.
kf = (Params.R*Params.M0b);
kr = (Params.R*Params.M0a);
B = [0 0 Params.Ra*Params.M0a, Params.Rb*Params.M0b, 0]';
I = eye(5);

E = [-1/Params.T2a, 0,  0,     0,      0;...
      0, -1/Params.T2a,  0,     0,      0;...
      0, 0,        -kf-Params.Ra, kr,   0;...
      0, 0,        kf, -kr-Params.Rb,   0;...
      0, 0,         0,    0, -1/Params.T1D];

temp2 = zeros(size(M_in));

for i = 1:N_spin
    E_t = E;
    E_t(1,1) = E_t(1,1) + Grad2D(1,i);
    E_t(2,2) = E_t(2,2) + Grad2D(2,i);

    temp2(:,i) = expm(E_t*t)*M_out(:,i) + (expm(E_t*t) - I)* (E_t\B);
end

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Method two
tic

M_o = permute(M_in,[1,3,2]);
R1 = cos(theta);
R2 = sin(theta);
Zer = zeros(size(R1));
One = ones(size(R1));
R = permute( reshape( ...
    [R1;-R2;Zer;Zer;Zer;... 
    R2; R1;Zer;Zer;Zer;...
    Zer;Zer;One;Zer;Zer;...
    Zer;Zer;Zer;One;Zer;...
    Zer;Zer;Zer;Zer;One]  , 5,5,[]) , [2,1,3]);

M_out = pagemtimes(R, M_o);



delX = Params.ReadoutResolution / Params.N_spin;
Grad2D = zeros(size(M_in));

for i = 1:N_spin
    if i == 1
        Grad2D(:,i) =Params.D * (M_out(:,i+1)-M_out(:,i)) /delX; % handle edge case
    elseif i == N_spin
        Grad2D(:,i) =Params.D * (M_out(:,i-1)-M_out(:,i)) /delX; % handle edge case
    else
        Grad2D(:,i) =Params.D * (M_out(:,i+1)+M_out(:,i-1)-2*M_out(:,i)) /delX; 
    end
end


B = [0 0 Params.Ra*Params.M0a, Params.Rb*Params.M0b, 0]';
I = eye(5);

E = repmat([-1/Params.T2a, 0,  0,     0,      0;...
      0, -1/Params.T2a,  0,     0,      0;...
      0, 0,        -Params.kf-Params.Ra, Params.kr,   0;...
      0, 0,        Params.kf, -Params.kr-Params.Rb,   0;...
      0, 0,         0,    0, -1/Params.T1D],[1,1,N_spin]);

E(1,1,:) = squeeze(E(1,1,:)) + Grad2D(1,:)';
E(2,2,:) = squeeze(E(2,2,:)) + Grad2D(2,:)';

temp3 = zeros(size(M_in));
for i = 1:N_spin

    temp3(:,i) = expm(E(:,:,i)*t)*M_out(:,i) + (expm(E(:,:,i)*t) - I)* (E(:,:,i)\B);
end
toc















figure;
plot(temp3(1,:))
hold on
plot(temp2(1,:))


figure;
plot(temp3(2,:))
hold on
plot(temp2(2,:))




























