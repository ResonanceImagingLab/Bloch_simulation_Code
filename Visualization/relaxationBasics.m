% Basic Relaxation plots
addpath( genpath('E:\GitHub\Bloch_simulation_Code'));

%% T1 Inversion recovery
T1 = 1000; % ms
t = linspace(0, 5*T1, 1000);

a = 1;
b = -2;
S = a+ b*exp(-t/T1);

figure; plot(t, S, 'LineWidth', 3)

% We want to add scatter points where we might take measurements:
tm = [ 50, 200, 500, 1000, 1500, 2500];
Sm = a+ b*exp(-tm/T1);

hold on; scatter(tm, Sm, 50, "red")

% Tissue 2:
T1 = 1500; % ms
S = a+ b*exp(-t/T1);

plot(t, S, 'LineWidth', 3)

Sm = a+ b*exp(-tm/T1);

scatter(tm, Sm, 50, "red")
xlabel('Time (ms)'); 
    ax = gca;    ax.FontSize = 20;
xlim([0 5000])



%% T2 dephasing
clear all;

% Grid of 5x5 spins. Each should have random spin
upper = 3;
lower = -3;
pd = makedist('Uniform', lower, upper);
numSpins = 50;
spin = random(pd, numSpins, numSpins );


% Make a 3D time grid, 5x5xt
fps = 25;
sec = 15;
t2 = 4;
te = linspace(0, t2, fps*sec);
[X,Y] = meshgrid(1:numSpins,1:numSpins);

% Just track the angle
theta = zeros(numSpins,numSpins); % all start at 0;
z = ones(numSpins,numSpins)*0.5;
plotT = linspace(0, 1, fps*sec);

filename = 'T2_relax_50.gif';
clear Zs;
a = 0.55;
b = -3.5;
y = a*exp(b*plotT);

figure;
tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec

    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 

    % Move to next tile to plot summation
    Us = mean(U(:));
    Vs = mean(V(:));
    Zs(i) = sqrt(Us^2 + Vs^2);
    nexttile (2); 
    p = nsidedpoly(1000, 'Center', [0.5 0.5], 'Radius', 0.5);
    plot(p, "FaceColor", "none","EdgeColor", "k") 
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, 1]); ylim([0, 1]);
    hold on
    plot(plotT(1:i),Zs, 'LineWidth', 3, "Color", "r") 
    plot(plotT, y,":" , 'LineWidth', 2, "Color",[0.6350 0.0780 0.1840]);
    quiver(0.5, 0.5,Us,Vs,"off",'filled','k',...
        'LineWidth', 3, 'MaxHeadSize', 0.8)
    hold off
    drawnow;
    set(gcf,'Position',[100 100 800 400])
    theta = spin.*te(i);

    exportgraphics(gcf,filename,'Append',true);

end




%% Spins in phase:

clear all;

% Grid of 5x5 spins. Each should have random spin
upper = 1;
numSpins = 15;
spin = upper* ones( numSpins, numSpins );


% Make a 3D time grid, 5x5xt
fps = 25;
sec = 5;
t2 = 2*pi;
te = linspace(0, t2, fps*sec);
[X,Y] = meshgrid(1:numSpins,1:numSpins);

% Just track the angle
theta = zeros(numSpins,numSpins); % all start at 0;
z = ones(numSpins,numSpins)*0.5;


filename = 'Spins_inPhase.gif';

figure;
tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec

    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 

    % Move to next tile to plot summation
    Us = mean(U(:));
    Vs = mean(V(:));
    nexttile (2); 
    p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 0.5);
    plot(p, "FaceColor", "none","EdgeColor", "k") 
    xticks([ ]); yticks([ ]); axis image;
    xlim([-0.7, 0.7]); ylim([-0.7, 0.7]);
    hold on
    quiver(0, 0,Us,Vs,"off",'filled','k',...
        'LineWidth', 3, 'MaxHeadSize', 0.8)
    hold off
    drawnow;
    set(gcf,'Position',[100 100 800 400])
    theta = spin.*te(i);

    exportgraphics(gcf,filename,'Append',true);

end










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3D spin precessing
clear all

% Create a sphere to be the 'spin'
[X,Y,Z] = sphere(50);
r = 0.2;
X2 = X * r;
Y2 = Y * r;
Z2 = Z * r;

% Now the magnetic vector
ang = 20; % degrees off from center
Mt = [sind(ang), 0, cosd(ang)]';

% We are only looking to rotate around Z:
t = 0.2;
filename = 'Spins_Precession.gif';

% Display
hFig = figure;
for n = 1:125
    surf(X2,Y2,Z2, 'FaceColor', [0.6350 0.0780 0.1840],...
        'EdgeColor','none', 'FaceLighting','gouraud'); 
    light("Style","local","Position",[-1 -1 2]);
    axis image;
    xticks([ ]); yticks([ ]); zticks([ ]);
    xlim([-0.3, 0.3]); ylim([-0.3, 0.3]); zlim([-0.5, 0.7]);
    hold on;
    arrow3D(-0.4*Mt, Mt, 'k');  % add magnetization. offset so crosses origin
    color = get(hFig,'Color'); % hide the axis
    set(gca,'XColor',color,'YColor',color,'ZColor',color,'TickDir','out')
    hold off;

    Rz = [cos(t) -sin(t) 0;...
          sin(t) cos(t) 0;...
          0 0 1];

    Mt = Rz*Mt;
    drawnow;
    exportgraphics(gcf,filename,'Append',true);
end

%% RF excitation - 90 deg pulse

clear all

% Create a sphere to be the 'spin'
[X,Y,Z] = sphere(50);
r = 0.2;
X2 = X * r;
Y2 = Y * r;
Z2 = Z * r;

% Now the magnetic vector
ang = 10; % degrees off from center
Mt = [sind(ang), 0, cosd(ang)]';

% Apply as rotation on Z then X
t = 0.15;
Rz = [cos(t) -sin(t) 0;...
      sin(t) cos(t) 0;...
      0 0 1];

t2 = 0.01;
Rz2 = [cos(t) -sin(t) 0;...
      sin(t) cos(t) 0;...
      0 0 1];

flipAng = 0.15;
filename = 'Spins_90deg_RF.gif';

X3= Mt(1); Y3= Mt(2); Z3= Mt(3);
idx = 1;

% Start by precession
hFig = figure;
for n = 1:100
    surf(X2,Y2,Z2, 'FaceColor', [0.6350 0.0780 0.1840],...
        'EdgeColor','none', 'FaceLighting','gouraud'); 
    light("Style","local","Position",[-1 -1 2]);
    axis image;
    xticks([ ]); yticks([ ]); zticks([ ]);
    xlim([-0.7, 0.7]); ylim([-0.7, 0.7]); zlim([-0.5, 0.7]);
    hold on;
    arrow3D(-0.4*Mt, Mt, 'k');  % add magnetization. offset so crosses origin
    plot3(X3*0.5, Y3*0.5, Z3*0.5);
    color = get(hFig,'Color'); % hide the axis
    set(gca,'XColor',color,'YColor',color,'ZColor',color,'TickDir','out')
    hold off;

    Mt = Rz*Mt;
    idx = idx+1;
    X3(idx)= Mt(1); Y3(idx)= Mt(2); Z3(idx)= Mt(3);
    drawnow;
    exportgraphics(gcf,filename,'Append',true);
end


% Now tip
while abs(Mt(3)) > 0.025
    surf(X2,Y2,Z2, 'FaceColor', [0.6350 0.0780 0.1840],...
        'EdgeColor','none', 'FaceLighting','gouraud'); 
    light("Style","local","Position",[-1 -1 2]);
    axis image;
    xticks([ ]); yticks([ ]); zticks([ ]);
    xlim([-0.7, 0.7]); ylim([-0.7, 0.7]); zlim([-0.5, 0.7]);
    hold on;
    arrow3D(-0.4*Mt, Mt, 'k');  % add magnetization. offset so crosses origin
    plot3(X3*0.5, Y3*0.5, Z3*0.5);
    color = get(hFig,'Color'); % hide the axis
    set(gca,'XColor',color,'YColor',color,'ZColor',color,'TickDir','out')
    hold off;
    
    % Get rotation matrix of on-resonance RF
    spinPhase = atan2(Mt(2),Mt(1) ); % it needs to be on phase each time
    R = Rotation3D( -flipAng*cos(-spinPhase), -flipAng*sin(spinPhase), 0 );
    Mt = R*Mt; % push down

    % Keep it spinning
    Mt = Rz2*Mt;
    idx = idx+1;
    X3(idx)= Mt(1); Y3(idx)= Mt(2); Z3(idx)= Mt(3);
    drawnow;
    exportgraphics(gcf,filename,'Append',true);
end


% End with by precession
for n = 1:100
    surf(X2,Y2,Z2, 'FaceColor', [0.6350 0.0780 0.1840],...
        'EdgeColor','none', 'FaceLighting','gouraud'); 
    light("Style","local","Position",[-1 -1 2]);
    axis image;
    xticks([ ]); yticks([ ]); zticks([ ]);
    xlim([-0.7, 0.7]); ylim([-0.7, 0.7]); zlim([-0.5, 0.7]);
    hold on;
    arrow3D(-0.4*Mt, Mt, 'k');  % add magnetization. offset so crosses origin
    plot3(X3*0.5, Y3*0.5, Z3*0.5);
    color = get(hFig,'Color'); % hide the axis
    set(gca,'XColor',color,'YColor',color,'ZColor',color,'TickDir','out')
    hold off;

    Mt = Rz*Mt;
    idx = idx+1;
    X3(idx)= Mt(1); Y3(idx)= Mt(2); Z3(idx)= Mt(3);
    drawnow;
    exportgraphics(gcf,filename,'Append',true);
end



























































