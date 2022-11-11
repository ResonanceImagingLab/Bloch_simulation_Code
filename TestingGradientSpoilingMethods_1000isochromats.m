% The goal of this script is to test out two ways of implementing gradient
% spoiling. Both would start with creating a bunch of isochromats between
% 0:2pi, at varying x-position (2D matrix)


% Implement diffusion and gradient spoiling into simulations:

% Params.GradientSpoilingStrength = 24; % mT/m
% Params.ReadoutResolution = 1; % mm - for calculating spoiling
% Params.IncreasedGradSpoil = true; % binary
addpath(genpath('C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\qMRlab_CR_addons'))

savDir =  'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v1\Figures\';

%% Test on a sequence with short TR and higher flip angle
Params.TR = 45/1000;
Params.flipAngle = 10;
Params.numExcitation = 1;
Params.MTC = 0; % Magnetization Transfer Contrast

Params = DefaultCortexTissueParams(Params);
Params = CalcImagingParams(Params);
Params = CalcVariableImagingParams(Params);



%%  Reference method
REFERENCE_VALUE1 =  CR_FLASH_solver(Params.flipAngle, Params.TR, 1, Params.M0a, 1./Params.Raobs);

%% Method 1 - Simple Excitation and Relaxation
loops = 500;
M_t2 = zeros(1,2*loops +1);
M_t2(1) = 1;
time_vect1 = zeros(length(M_t2),1);
idx = 2;
for i = 1:loops
    % Apply Flip Angle
    M_t2(idx) = M_t2(idx-1) * cos (Params.flipAngle  *pi/180);
    time_vect1(idx) = time_vect1(idx-1);
    idx = idx +1;

    % Relaxation
    M_t2(idx) = 1*(1-exp(-Params.TR*Params.Raobs)) + M_t2(idx-1)*exp(-Params.TR*Params.Raobs);
    time_vect1(idx) = time_vect1(idx-1) + Params.TR;
    idx = idx +1;
end
M_t2(idx:end) = [];
time_vect1(idx:end) = [];

REFERENCE_VALUE2 = M_t2(idx-1)*sin(Params.flipAngle *pi/180);


figure; plot(time_vect1, M_t2)






% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Method 2 - DEBUG WITH WATER ONLY POOLS. 
% % play out the gradients on the isochromat and find the rotation 
% % and scaling matrix that could be applied each time the gradient spoiling
% % is played out
% % Average the signal over the last 100 readouts
% 
% % Note that since only one pool was used, Params.Ra converted to
% % Params.Raobs
% 
% [M_t4, time_vect, REFERENCE_VALUE4] = BlochSimFlashSequence_FreeWaterOnly(Params, 'GradientSpoiling',1);
% [M_t5, ~, REFERENCE_VALUE5] = BlochSimFlashSequence_FreeWaterOnly(Params, 'PerfectSpoiling',1);
% 
% 
% t_M_t4 = mean(M_t4,3);
% t_M_t5 = mean(M_t5,3);
% 
% f1 = figure; 
% plot(time_vect1, M_t2, 'LineWidth', 2.5)
% hold on
% plot(time_vect(:), t_M_t4(:,3), 'LineWidth', 2.5)
% plot(time_vect(:), t_M_t5(:,3), 'LineWidth', 2.5)
% legend('z only', 'xyz with RF and Grad spoil',...
%     'xyz with Perfect spoil','FontSize', 20)
% ylabel('M_z', 'FontSize', 20)
% xlabel('Time(s)', 'FontSize', 20)
% xlim([0 6])
% set(f1, 'position',[100, 100, 800, 800])
% 
% 
% f2 = figure; 
% hold on
% plot(time_vect(:), t_M_t4(:,2), 'LineWidth', 2.5)
% plot(time_vect(:), t_M_t5(:,2), 'LineWidth', 2.5)
% legend('xyz with RF and Grad spoil',...
%     'xyz with Perfect spoil', 'FontSize', 20)
% ylabel('M_y', 'FontSize', 20)
% xlabel('Time(s)', 'FontSize', 20)
% xlim([5 6])
% set(f2, 'position',[100, 100, 800, 800])
% 
% 
% % Look at the magnitude of the x-y magnetization, 
% % sum across spins to get avg over voxel, then take mag
% 
% temp1 = sqrt(sum(mean( M_t4(:,1:2,:), 3).^2,2));
% temp2 = sqrt(sum(mean( M_t5(:,1:2,:), 3).^2,2));
% 
% f3 = figure; 
% hold on
% plot(time_vect(2:2:end), temp1(2:2:end), 'LineWidth', 2.5)
% plot(time_vect(2:2:end), temp2(2:2:end), 'LineWidth', 2.5)
% legend('xyz with RF and Grad spoil',...
%     'xyz with Perfect spoil', 'FontSize', 20)
% ylabel('M_{xy} Magnitude', 'FontSize', 20)
% xlabel('Time(s)', 'FontSize', 20)
% xlim([5 6])
% set(f3, 'position',[100, 100, 800, 800])
% 
% 
% 
% 
% % save outputs if interested
% saveas(f1, strcat(savDir,'WaterPoolOnly_Mz.png'))
% saveas(f2, strcat(savDir,'WaterPoolOnly_My.png'))
% saveas(f3, strcat(savDir,'WaterPoolOnly_MxyMag.png'))

%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Method 2 - Expand to a 3 pool model.play out the gradients on the isochromat and find the rotation 
% and scaling matrix that could be applied each time the gradient spoiling
% is played out


[M_t7, time_vect6, REFERENCE_VALUE7] = BlochSimFlashSequence_v1(Params, 'GradientSpoiling',1);
[M_t8,          ~, REFERENCE_VALUE8] = BlochSimFlashSequence_v1(Params, 'PerfectSpoiling',1);


f1 = figure; 
%plot(time_vect1(1:610), M_t2(1:610), 'LineWidth', 2.5)
plot(time_vect(:), M_t5(3,:), 'LineWidth', 2.5)
hold on
plot(time_vect6(:), M_t7(3,:), 'LineWidth', 2.5)
plot(time_vect6(:), M_t8(3,:), 'LineWidth', 2.5)
legend('Water-only Perfect Spoil','xyz with RF and Grad spoil',...
    'xyz with Perfect spoil', 'FontSize', 20)
ylabel('M_z', 'FontSize', 20)
xlabel('Time(s)', 'FontSize', 20)
xlim([0 3])
set(f1, 'position',[100, 100, 800, 800])


st_id = 1;
ed = 900;
f2 = figure; 
hold on
plot(time_vect6(:), M_t7(2,:), 'LineWidth', 2.5)
plot(time_vect6(:), M_t8(2,:), 'LineWidth', 2.5)
legend('xyz with RF and Grad spoil',...
    'xyz with Perfect spoil', 'FontSize', 20)
ylabel('M_y', 'FontSize', 20)
xlabel('Time(s)', 'FontSize', 20)
xlim([0 3])
set(f2, 'position',[100, 100, 800, 800])



saveas(f1, strcat(savDir,'ThreePool_1avgSpin_Mz.png'))
saveas(f2, strcat(savDir,'ThreePool_1avgSpin_My.png'))







%% check using VFA approach:

tic

Params.TR = 15/1000;
Params.flipAngle = 4;
[lfa,~,~] = BlochSimFlashSequence_v2(Params, 'GradientSpoiling',1);

Params.flipAngle = 20;
[hfa,~,~] = BlochSimFlashSequence_v2(Params, 'GradientSpoiling',1);

a1 = 4 * pi/180;
a2 = 20 * pi / 180;
TR = Params.TR;
T1_1 = 1./(0.5 .* (hfa.*a2./ TR - lfa.*a1./TR) ./ (lfa./(a1) - hfa./(a2))) *1000;
Aapp_1 = lfa .* hfa .* (TR .* a2./a1 - TR.* a1./a2) ./ (hfa.* TR .*a2 - lfa.* TR .*a1);

Params.TR = 15/1000;
Params.flipAngle = 4;
[lfa1,~,~] = BlochSimFlashSequence_v2(Params, 'PerfectSpoiling',1);
Params.flipAngle = 20;
[hfa1,~,~] = BlochSimFlashSequence_v2(Params, 'PerfectSpoiling',1);

T1_2 =1./( 0.5 .* (hfa1.*a2./ TR - lfa1.*a1./TR) ./ (lfa1./(a1) - hfa1./(a2))) *1000;
Aapp_2 = lfa1 .* hfa1 .* (TR .* a2./a1 - TR.* a1./a2) ./ (hfa1.* TR .*a2 - lfa1.* TR .*a1);

toc
    



figure; plot(N_spin, perDif,"LineWidth",3)
ylabel('VFA T_1 Difference (%)', 'FontSize', 20)
xlabel('N_{isochromat}', 'FontSize', 20)
set(gca, 'FontSize',16)
saveas(gcf, strcat(savDir,'NumIsoChromat_on_T1Stability.png'))

% Here is looks like the number of 180 that was used in ... was a good
% value
% Yarnykh, V.L., 2010. Optimal radiofrequency and gradient spoiling for improved 
% accuracy of T1 and B1 measurements using fast steady-state techniques. Magn. 
% Reson. Med. 63, 1610–1626. https://doi.org/10.1002/mrm.22394








vec = zeros(10,100);

parfor i = 1:100
    vec(:,i) = i;
end







































