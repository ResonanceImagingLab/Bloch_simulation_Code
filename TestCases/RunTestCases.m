%% Run Test Cases:

% this script runs the different test cases, and outputs the figures in the
% according directory.

savDir =  'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\TestCases\Figures\';

FLASH_test(savDir)

% Here we export a table of M0 and T1 values to compare
VFA_resultsTable = VFA_test(savDir);

% With the excitation part of the simulations confirmed to work (?)...
% look to saturation part with a qMT style approach.
qMT_resultsTable = qMT_test(savDir);


