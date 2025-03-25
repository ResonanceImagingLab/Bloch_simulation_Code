%% Test the effect of different TI's for promoting T1 contrast

% params
fa =deg2rad( 7 );
numEnc = 256; 
echoSpacing = 7.7;
T1 = [800; 1400; 3000];
startMz = -0.5;

%% Now for different TIs
rows = 2;
cols = 3;
ti = 0:250:1000;
ex = exp(-echoSpacing./T1);
x = 1:numEnc;
t = (x-1)*echoSpacing;
T1_mz = startMz.* exp(-t./T1) + (1-exp(-t./T1)); 

for i = 1:rows*cols -1
    TI = ti(i);
    subplot(rows, cols, i);
    Mz = zeros(3,numEnc+1);
    ex_TI = exp(-TI./T1);
    Mz(:,1) = startMz.* ex_TI + (1-ex_TI); % initialize with 180
    
    
    for j = 2:numEnc+1
        Mtemp = Mz(:,j-1) * cos(fa);
        Mz(:,j) = Mtemp.* ex + (1-ex);
    end
    
    %% Plot
    temp = Mz(:,2:end)';
    plot(x', Mz(:,2:end)','LineWidth',3)
    title(['TI = ',num2str(TI)]);
    xlabel('NumEnc'); ylabel('M_z');
    ax = gca; ax.FontSize = 16;
    xline(125,'--r', ['t=',num2str( TI + 125*echoSpacing)] )
    ylim([-1 1])

end
subplot(rows, cols,6)
plot(t', T1_mz','LineWidth',3)
    title('T1 relaxation');
    xlabel('NumEnc'); ylabel('M_z');
    ax = gca; ax.FontSize = 16;
    xline(t(125),'--r', ['t=',num2str( t(125))] )
    ylim([-1 1])