function Params = DefaultTissueParams(Params)

%% Sort based on field strength and tissue type
% currently only 3T and 7T are supported fields;
% currently only 'GM' and 'WM' are the supported tissue types.

% Tissue Types:
% corticalGM
% WM
% CSF
% subcorticalGM
% brainStemWM
% substantiaNigra
% locusCoeruleus


% 3T parameters taken from lots of studies... 
% Christopher Rowley 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%  3T %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if Params.B0 == 3

    if strcmp(Params.TissueType, 'corticalGM')
        Params.M0a = 1;
        Params.Raobs = 1/1.4; 
        Params.R = 17; % 
        Params.T2a = 50e-3; % Sled and Pike 2001
        Params.T1D = 7.5e-4; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11.5e-6; 
        Params.Ra = [];
        Params.M0b =  0.071;
        Params.PD =  82; % Proton Density
        Params.T2 = 120e-3; 
        Params.T2star = 62e-3; 
        Params.D = 0.8e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'WM')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/0.9; 
        Params.R = 16; % k_f / M0b
        Params.T2a = 81e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.14;
        Params.PD =  70; % Proton Density
        Params.T2 = 85e-3; 
        Params.T2star = 48e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'subcorticalGM')
        Params.M0a = 1;
        Params.Raobs = 1/1.4; 
        Params.R = 20; % 
        Params.T2a = 50e-3; % Sled and Pike 2001
        Params.T1D = 7.5e-4; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11.5e-6; 
        Params.Ra = [];
        Params.M0b =  0.071;
        Params.PD =  82; % Proton Density
        Params.T2 = 100e-3; 
        Params.T2star = 48e-3; 
        Params.D = 0.8e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'brainStemWM')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/0.9; 
        Params.R = 16; % k_f / M0b
        Params.T2a = 81e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.12;
        Params.PD =  73; % Proton Density
        Params.T2 = 85e-3; 
        Params.T2star = 48e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s


    elseif strcmp(Params.TissueType, 'CSF')
        Params.M0a = 1;
        Params.Raobs = 1/3; 
        Params.R = 0; % 
        Params.T2a = 2000e-3; % Sled and Pike 2001
        Params.T1D = 0.01e-4; % Varma 2017 was 6ms
        Params.lineshape = 'Lorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11.5e-6; 
        Params.Ra = [];
        Params.M0b =  0;
        Params.PD =  100; % Proton Density
        Params.T2 = 2000e-3; 
        Params.T2star = 175e-3; 
        Params.D = 3e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'substantiaNigra')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/1.1; 
        Params.R = 16; % k_f / M0b
        Params.T2a = 60e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.10;
        Params.PD =  82; % Proton Density
        Params.T2 = 60e-3; 
        Params.T2star = 40e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s       

    elseif strcmp(Params.TissueType, 'locusCoeruleus')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/1.350; 
        Params.R = 16; % k_f / M0b
        Params.T2a = 60e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.05;
        Params.PD =  82; % Proton Density
        Params.T2 = 110e-3; 
        Params.T2star = 60e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s    

    else
        error('Please set Params.TissueType to either GM or WM, or build an additional field')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%  7T %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
elseif Params.B0 == 7

    if strcmp(Params.TissueType, 'corticalGM')
        Params.M0a = 1;
        Params.Raobs = 1/1.95; 
        Params.R = 24; % 
        Params.T2a = 45e-3; 
        Params.T1D = 5.25e-4; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11e-6; 
        Params.Ra = [];
        Params.M0b =  0.075;
        Params.PD =  73; % Proton Density
        Params.T2 = 50e-3; 
        Params.T2star = 35e-3; 
        Params.D = 0.8e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'WM')
        Params.M0a = 1;
        Params.Raobs = 1/1.35; 
        Params.R = 14;
        Params.T2a = 45e-3; 
        Params.T1D = 5.25e-4; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11.1e-6;
        Params.Ra = [];
        Params.M0b =  0.155;
        Params.PD =  63; % Proton Density
        Params.T2 = 38e-3; 
        Params.T2star = 25e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

     elseif strcmp(Params.TissueType, 'subcorticalGM')
        Params.M0a = 1;
        Params.Raobs = 1/1.6; 
        Params.R = 26; % 
        Params.T2a = 50e-3; % Sled and Pike 2001
        Params.T1D = 7.5e-4; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11.5e-6; 
        Params.Ra = [];
        Params.M0b =  0.071;
        Params.PD =  77; % Proton Density
        Params.T2 = 50e-3; 
        Params.T2star = 25e-3; 
        Params.D = 0.8e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'brainStemWM')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/1.4; 
        Params.R = 14; % k_f / M0b
        Params.T2a = 81e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.16;
        Params.PD =  73; % Proton Density
        Params.T2 = 60e-3; 
        Params.T2star = 42e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s


    elseif strcmp(Params.TissueType, 'CSF')
        Params.M0a = 1;
        Params.Raobs = 1/3.5; 
        Params.R = 0; % 
        Params.T2a = 1000e-3; % Sled and Pike 2001
        Params.T1D = 0.01e-4; % Varma 2017 was 6ms
        Params.lineshape = 'Lorentzian'; % or 'SuperLorentzian';
        Params.R1b = 0.25;
        Params.T2b = 11.5e-6; 
        Params.Ra = [];
        Params.M0b =  0;
        Params.PD =  100; % Proton Density
        Params.T2 = 1000e-3; 
        Params.T2star = 90e-3; 
        Params.D = 3e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s

    elseif strcmp(Params.TissueType, 'substantiaNigra')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/1.1; 
        Params.R = 16; % k_f / M0b
        Params.T2a = 60e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.1;
        Params.PD =  77; % Proton Density
        Params.T2 = 30e-3; 
        Params.T2star = 15e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s       

    elseif strcmp(Params.TissueType, 'locusCoeruleus')
        % Parameters from: Teixeira et al 2019, note T2b wasn't specified, so taken from Sled and Pike 2001 
        Params.M0a = 1;
        Params.Raobs = 1/1.20; 
        Params.R = 16; % k_f / M0b
        Params.T2a = 60e-3; % 
        Params.T1D = 1e-3; % Varma 2017 was 6ms
        Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
        Params.R1b = 1;
        Params.T2b = 11.8e-6;
        Params.Ra = [];
        Params.M0b =  0.05;
        Params.PD =  77; % Proton Density
        Params.T2 = 50-3; 
        Params.T2star = 35e-3; 
        Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s   

    else
        error('Please set Params.TissueType to either GM or WM, or build an additional field')
    end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%%%%%%%%%%% 1.5T %%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% % Use the optimizations from: Levesque, I.R., Sled, J.G., Pike, G.B., 2011. 
% % Iterative optimization method for design of quantitative magnetization transfer 
% % imaging experiments. Magn. Reson. Med. 66, 635–643. https://doi.org/10.1002/mrm.23071
% elseif Params.B0 == 1.5
% 
%     if strcmp(Params.TissueType, 'GM')
%         Params.M0a = 1;
%         Params.Raobs = 1/2; 
%         Params.R = 25.7; % 
%         Params.T2a = 51e-3; 
%         Params.T1D = 5.25e-4; % Varma 2017 was 6ms
%         Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
%         Params.R1b = 0.25;
%         Params.T2b = 11e-6; 
%         Params.Ra = 1;
%         Params.M0b =  0.07;
%         Params.D = 0.8e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s
% 
%     elseif strcmp(Params.TissueType, 'WM')
%         Params.M0a = 1;
%         Params.Raobs = 1/0.55; 
%         Params.R = 25;
%         Params.T2a = 35e-3; 
%         Params.T1D = 5.25e-4; % Varma 2017 was 6ms
%         Params.lineshape = 'SuperLorentzian'; % or 'SuperLorentzian';
%         Params.R1b = 0.25;
%         Params.T2b = 12e-6;
%         Params.Ra = 1.8;
%         Params.M0b =  0.16;
%         Params.D = 1e-3/1e6; % diffusion coefficient-> convert from mm^2/s to m^2/s
% 
%     else
%         error('Please set Params.TissueType to either GM or WM, or build an additional field')
%     end

else
    error('Please set Params.B0 to either 3,7, or build an additional field')
end


% if isempty(Params.Ra) % allow you to specify either Ra or Raobs
%     Params.Ra = Params.Raobs - ((Params.R * Params.M0b * (Params.R1b - Params.Raobs)) / (Params.R1b - Params.Raobs + Params.R));
%     if isnan(Params.Ra)
%         Params.Ra = 1;
%     end
% end

