function MPRAGE_test(savDir)

Params.TR = 2000/1000;
Params.flipAngle = 5;
Params.numExcitation = 176;
Params.MTC = 0; % Magnetization Transfer Contrast

 
Params.B0 = 3;
Params.MTC = 0; % Magnetization Transfer Contrast
Params.TissueType = 'GM';
Params.echoSpacing = 7.7/1000;

Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);

Params.Readout = 'linear';
Params.TI = 900/1000;
Params.InvPulseDur = 3/1000;

Params.M0b = 0; % no MT effect


[outSig, M, time_vect] = BlochSim_MPRAGESequence(Params );

figure; plot(time_vect, M(1:3,:))
legend
xlabel('Time (s)')
ylabel('M_{a}')
ax = gca; ax.FontSize = 20; 
set(gcf,'position',[10,400,800,600])
xlim([0 10])
saveas(gcf,strcat(savDir,'FLASH_test_1.png')) 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Test out an inversion recovery
Params.TI = 900/1000;
Params.TR = 2000/1000;
Params.flipAngle = 90;
Params.numExcitation = 1;
Params.TE = 8.5/1000;
Params.InvPulseDur = 3/1000;
Params.CalcVector = 1;
Params.PerfectSpoiling = 1;
Params.DummyEcho = 0;
Params.echoSpacing = 0;

[outSig, M, time_vect] = BlochSim_MPRAGESequence(Params );


figure; plot(time_vect, M(1:3,:))
legend
xlabel('Time (s)')
ylabel('M_{a}')
ax = gca; ax.FontSize = 20; 
set(gcf,'position',[10,400,800,600])
xlim([0 10])








