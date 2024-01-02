%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% T2 with 180 refocus

clear all;
saveGIF = 1;

filename = 'Spins_T2_refocus.gif';

% Grid of 5x5 spins. top half have oppositive spin of bottom.
upper = 1;
numSpins = 15;

spin = linspace(-upper, upper, numSpins);
spin = repmat( spin', 1, numSpins);



% Make a 3D time grid, 5x5xt
fps = 25;
sec = 5;
t2 = 2*pi*3;
te = linspace(0, t2, fps*sec*3);
inc = te(2) - te(1);
plotT = linspace(-0.7, 0.7, 3*fps*sec+30);
[X,Y] = meshgrid(1:numSpins,1:numSpins);

% Just track the angle
theta = zeros(numSpins,numSpins); % all start at 0;
z = ones(numSpins,numSpins)*0.5;
idx = 1;

figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = 1:fps*sec

    % theta = spin.*te(i);
    theta = theta + spin.*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0,numSpins+2, numSpins/3+0.5],'FaceColor',...
        [0, 0.45, 0.75, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    rectangle('Position',[0, 2*numSpins/3+0.5, numSpins+2, numSpins/3+2],'FaceColor',...
        [1, 0, 0, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');

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
    title('T_2 Dephasing', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
   
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end

%% Now do the 180 pulse
flipDur = linspace(1, -1, 30);
for i = 1:30

    U = real(z)*flipDur(i);
    V = imag(z)*flipDur(i);
    nexttile (1); cla;
    rectangle('Position',[0, 0, 18, 18],'FaceColor',...
        [0, 1, 0, 0.1], 'LineWidth', 0.1, 'EdgeColor', 'none');
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
    plot(plotT(1:idx),Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('180° RF Pulse', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])

    if saveGIF; exportgraphics(gcf,filename,'Append',true); end
end

%% Now Rephasing
% Flip the spins

spin = spin*-1;
theta = theta+ pi; % bake in the flip.

% figure; tiledlayout(1,2,"TileSpacing","compact",'Padding','compact');
for i = fps*sec:2*fps*sec

    
    theta = theta + spin.*inc;
    z = abs(z).*exp(1i*theta);
    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0,numSpins+2, numSpins/3+0.5],'FaceColor',...
        [0, 0.45, 0.75, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    rectangle('Position',[0, 2*numSpins/3+0.5, numSpins+2, numSpins/3+2],'FaceColor',...
        [1, 0, 0, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');

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
    plot(plotT(1:idx),Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('T_2 Rephasing', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])
    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end

%% One more dephasing
for i = 2*fps*sec+1:3*fps*sec

    theta = theta + spin.*inc;
    z = abs(z).*exp(1i*theta);

    U = real(z);
    V = imag(z);
    nexttile (1); cla;
    rectangle('Position',[0, 0,numSpins+2, numSpins/3+0.5],'FaceColor',...
        [0, 0.45, 0.75, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');
    hold on;
    rectangle('Position',[0, 2*numSpins/3+0.5, numSpins+2, numSpins/3+2],'FaceColor',...
        [1, 0, 0, 0.2], 'LineWidth', 0.1, 'EdgeColor', 'none');

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
    plot(plotT(1:idx),Zs-0.7, 'LineWidth', 3, "Color", "r");
    idx = idx+1;
    hold off
    title('T_2 Dephasing', 'FontSize', 14)
    drawnow;
    set(gcf,'Position',[200 300 800 400])

    if saveGIF; exportgraphics(gcf,filename,'Append',true); end

end






