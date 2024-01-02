%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% T2* with gradients refocus

clear all;
saveGIF = 1;

filename = 'Spins_T2star_refocus.gif';

% Grid of 5x5 spins. top half have oppositive spin of bottom.

numSpins = 15;

gradient = linspace(0.5, 1.5, numSpins);
gradient = repmat( gradient', 1, numSpins);



% Make a 3D time grid, 5x5xt
fps = 25;
sec = 5;
t2 = 2*pi*3;
te = linspace(0, t2, 2*fps*sec);
inc = te(2) - te(1);
plotT = linspace(-0.7, 0.7, 430);
[X,Y] = meshgrid(1:numSpins,1:numSpins);

% Just track the angle
theta = zeros(numSpins,numSpins); % all start at 0;
z = ones(numSpins,numSpins)*0.5;
idx = 1;

%% Free precession

figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:100

    % theta = spin.*te(i);
    theta = theta + 0.5.*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0, 18, 18],'FaceColor',...
        [0.1, 0.1, 0.1, 0.1], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 
    hold off

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
    Zs(idx) = sqrt(Us^2 + Vs^2);
    plot(plotT(1:idx), Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('Free Precession', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
   
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end

%% Dephase Gradient
for i = 1:80
    
    theta = theta + gradient*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0, 18, 18],'FaceColor',...
        [1, 0, 0, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 
    hold off

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
    Zs(idx) = sqrt(Us^2 + Vs^2);
    plot(plotT(1:idx), Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('Positive Gradient Dephase', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
   
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end

%% Rephase Gradient
gradient = -1* gradient;
for i = 1:80
    
    theta = theta + gradient*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0, 18, 18],'FaceColor',...
        [0, 0, 1, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 
    hold off

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
    Zs(idx) = sqrt(Us^2 + Vs^2);
    plot(plotT(1:idx), Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('Negative Gradient Rephase', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
   
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end


%% Keep playing rephase to dephase
%% Rephase Gradient
for i = 1:80
    
    theta = theta + gradient*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0, 18, 18],'FaceColor',...
        [0, 0, 1, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 
    hold off

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
    Zs(idx) = sqrt(Us^2 + Vs^2);
    plot(plotT(1:idx), Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('Negative Gradient Dephase', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
   
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end

%% Then flip to rephase. 
%% Rephase Gradient
gradient = -1* gradient;
for i = 1:80
    
    theta = theta + gradient*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0, 18, 18],'FaceColor',...
        [1, 0, 0, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    quiver(X,Y,U,V, 0, 'LineWidth', 1.5, 'MaxHeadSize', 0.8);
    xticks([ ]); yticks([ ]); axis image;
    xlim([0, numSpins+1]); ylim([0, numSpins+1]); 
    hold off

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
    Zs(idx) = sqrt(Us^2 + Vs^2);
    plot(plotT(1:idx), Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('Positive Gradient Rephase', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
   
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end






