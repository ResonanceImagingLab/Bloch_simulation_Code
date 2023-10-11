
addpath(genpath('C:\Users\chris\Documents\GitHub\Bloch_simulation_Code' ))
addpath(genpath('C:\Users\chris\Documents\GitHub\qMRlab' ))
addpath(genpath('C:\Users\chris\Documents\GitHub\NeuroImagingMatlab'))



Params.MTC = 0;
Params.B0 = 3;
Params.TissueType = 'GM';
Params = DefaultCortexTissueParams(Params);
[T1wInfo, PDwInfo] = defaultGEparamObject_MPRAGE(Params, 1);

% Parameters:
T1val = [1000, 1300, 1600];
FlipAngle = 4:15;

% Sim
sig = zeros( length(FlipAngle), length(T1val));

for i = 1:length(FlipAngle)
    for j = 1:length(T1val)

        MPRAGE_vector = BlochSim_MPRAGESequence_1pool(T1wInfo, 'flipAngle',...
                FlipAngle(i), 'Raobs', 1./T1val(j)*1000 );

        sig(i,j) = MPRAGE_vector(T1wInfo.TurboFactor/2);
    end
end

figure;
plot(FlipAngle, sig(:,1),'LineWidth',3)
hold on 
plot(FlipAngle, sig(:,2),'LineWidth',3)
plot(FlipAngle, sig(:,3),'LineWidth',3)
legend('T1=1000ms','T1=1300ms','T1=1600ms')
xlabel('Flip Angle (degrees)')
ylabel('MPRAGE intensity')


(sig(7,2)-sig(end,2))/sig(end,2)