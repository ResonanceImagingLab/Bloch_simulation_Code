function MP2RAGE_test(savDir)


Params.B0 = 3;
Params.TissueType = 'GM';
Params.MTC = 1; % Magnetization Transfer Contrast




Params.TR = 5000/1000;
Params.flipAngle = [4,5];
Params.numExcitation = 175;
Params.echoSpacing = 7.7/1000;
Params.Readout = 'linear';
Params.TI = [940, 2830]./1000;
Params.InvPulseDur = 3/1000;
 
Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);


[outSig1, outSig2, M, time_vect] = BlochSim_MP2RAGESequence(Params);

figure; plot(time_vect, M(3,:))
legend
xlabel('Time (s)')
ylabel('M_{a}')
ax = gca; ax.FontSize = 20; 
set(gcf,'position',[10,400,800,600])
xlim([0 10])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MP2RAGE.B0          = Params.B0;                  % In Tesla
MP2RAGE.TR          = Params.TR;                  % MP2RAGE TR in seconds
MP2RAGE.TRFLASH     = Params.echoSpacing;             % TR of the GRE readout
MP2RAGE.TIs         = Params.TI;   % Inversion times - time between middle of refocusing pulse and excitatoin of the k-space center encoding
MP2RAGE.NZslices    = Params.numExcitation;            % Slices Per Slab * [PartialFourierInSlice-0.5  0.5]
MP2RAGE.FlipDegrees = Params.flipAngle;              % Flip angle of the two readouts in degrees

% Check result:
B1.img = 1;
brain.img = 1;
MP2RAGEINV2img.img = outSig2;
MP2RAGEimg.img = calculate_UNI_from_sims(outSig1, outSig2);
T1map = CR_T1B1correctpackageTFL_withM0( B1, MP2RAGEimg, MP2RAGEINV2img, MP2RAGE, brain, 0.96);





saveas(gcf,strcat(savDir,'MP2RAGE_test_1.png')) 






nimages = 2;
MPRAGE_tr = 5;
invtimesAB =Params.TI;
flipangleABdegree =Params.flipAngle;
nZslices = Params.numExcitation;
FLASH_tr = Params.echoSpacing;
sequence = 'normal';


[Intensity, T1vector, IntensityBeforeComb] = MP2RAGE_lookuptable(nimages,MPRAGE_tr,invtimesAB,flipangleABdegree,nZslices,FLASH_tr,sequence);

inversiontimes = invtimesAB;
flipangle = flipangleABdegree;
T1s = 0.7;
MPRAGEfunc(nimages,MPRAGE_tr,inversiontimes,nZslices,FLASH_tr,flipangle,sequence,T1s);

%% Negative is introduced at MPRAGEfunc line 136 @ temp = (-inv...























