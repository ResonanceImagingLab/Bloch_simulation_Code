% The goal of this is to show how gradients build 'waves' in kspace
clear all
clc

numSpins = 50; 
tinc = linspace(-1, 1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = tinc'; % looks better this way
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );


% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 7;

filename = 'freqEncodeSurf.gif';
tincScale = 0.08;
t = zeros(numSpins, numSpins);

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
theta = zeros(numSpins2, numSpins2);
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';

% Background gradient
[xp, yp] = meshgrid( linspace(-5, numSpins+5), linspace(-5, numSpins+5));
zp = ones(size(xp)) *-1;

figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-21, 51);

    t = t+tinc*tincScale;
    

    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, xp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Frequency  Encoding', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Phase encoding, is just in y-direction

clear all
clc

numSpins = 50; 
tinc = linspace(1, -1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = flip(tinc,2);
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );


% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 7;

filename = 'phaseEncodeSurf.gif';
tincScale = 0.08;
t = zeros(numSpins, numSpins);

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
theta = zeros(numSpins2, numSpins2);
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';

% Background gradient
[xp, yp] = meshgrid( -5: numSpins+5, -5: numSpins+5);
zp = ones(size(xp)) *-1;

figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-21, 51);

    t = t+tinc*tincScale;
    

    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, yp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Phase  Encoding', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Now show phase encode follow by frequency encode!

clear all
clc

numSpins = 50; 
tinc = linspace(1, -1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = flip(tinc,2);
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );

% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 3;

filename = 'phaseFreqEncodeSurf_Low.gif';
tincScale = 0.08;
t = zeros(numSpins, numSpins);

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
theta = zeros(numSpins2, numSpins2);
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';

% Background gradient
[xp, yp] = meshgrid( -5: numSpins+5, -5: numSpins+5);
zp = ones(size(xp)) *-1;

figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-16, 72);

    t = t+tinc*tincScale;
    

    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, yp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Phase  Encoding', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end

numSpins = 50; 
tinc = linspace(-1, 1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = tinc'; % looks better this way
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );

% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 7;

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';
% Background gradient
[xp, yp] = meshgrid( linspace(-5, numSpins+5), linspace(-5, numSpins+5));
zp = ones(size(xp)) *-1;
for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-16, 72);

    t = t+tinc*tincScale;
    
    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, xp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Frequency  Encoding', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Now add in negative frequency encode too.  phase encode follow by frequency encode!

clear all
clc

numSpins = 50; 
tinc = linspace(1, -1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = flip(tinc,2);
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );

% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 3;

filename = 'phaseFreqEncodeSurf_FreqDephase.gif';
tincScale = 0.08;
t = zeros(numSpins, numSpins);

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
theta = zeros(numSpins2, numSpins2);
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';

% Background gradient
[xp, yp] = meshgrid( -5: numSpins+5, -5: numSpins+5);
zp = ones(size(xp)) *-1;

figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-16, 72);

    t = t+tinc*tincScale;
    

    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, yp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Phase  Encoding', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end

%% Reverse Frequency
numSpins = 50; 
tinc = linspace(1, -1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = tinc'; % looks better this way
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );

% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 7-4;

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';
% Background gradient
[xp, yp] = meshgrid( linspace(-5, numSpins+5), linspace(-5, numSpins+5));
zp = ones(size(xp)) *-1;
fxp = flip(xp,2);

for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-16, 72);

    t = t+tinc*tincScale;
    
    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, fxp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Frequency  Encoding - Dephase', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end


%% Forward Frequency
numSpins = 50; 
tinc = linspace(-1, 1, numSpins);
tinc = repmat(tinc, numSpins,1);
tinc = tinc'; % looks better this way
[xx, yy] = ndgrid( -1*(numSpins-1)/2:(numSpins-1)/2 , -1*(numSpins-1)/2:(numSpins-1)/2  );

% Start at time t, and increat with tinc to show increasing. 
fps = 25;
sec = 7+4;

% I want to repeat this using quiver arrows
numSpins2 = numSpins/5;
z = ones(numSpins2,numSpins2)*2;
[X,Y] = meshgrid(1:5:numSpins,1:5:numSpins);
tinc2 = tinc(1:5:end, 1:5:end)';
% Background gradient
[xp, yp] = meshgrid( linspace(-5, numSpins+5), linspace(-5, numSpins+5));
zp = ones(size(xp)) *-1;
for i = 1:fps*sec
    
    %surf
    zz = sin(t);
    nexttile(1); cla;
    surf(xx, yy, zz, 'EdgeColor','none')
    colormap('turbo')
    zlim([-2 2])
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    view(-16, 72);

    t = t+tinc*tincScale;
    
    % Quiver
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    
    nexttile(2); cla;
    surf(xp, yp, zp, xp, 'FaceAlpha', 0.3, 'EdgeColor','none'); % signal gradient strength

    hold on;
    quiver(X,Y,U,V, 0, 'k','LineWidth', 1.75, 'MaxHeadSize', 0.9);
    view(0,90);
    xticks([ ]); yticks([ ]); axis image;
    xlabel('X', FontSize=18)
    ylabel('Y', FontSize=18)
    xlim([-2, numSpins+1]); ylim([-2, numSpins+1]); 
    hold off
    theta = theta +tinc2*tincScale;

    drawnow;
    set(gcf,'Position',[200 300 1200 600])
    sgtitle('Frequency  Encoding - Rephase', 'FontSize', 30)

    exportgraphics(gcf,filename,'Append',true);
    
end


















