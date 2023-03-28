function [ T1, M0, MTsat] = fitHelms2008_MTsat(St1, SMT, SPD,...
        flipMT, flipT1, TR_MT, TR_T1)

% Assumes the flip angles are in degrees.

% Convert to radians
flipMT = deg2rad(flipMT);
flipT1 = deg2rad(flipT1);


% From Helms 2008 and 2010
R1 = 0.5* ( (St1.*flipT1./TR_T1) - (SPD.*flipMT./TR_MT))./((SPD./flipMT) - (St1./flipT1));
T1 = 1./R1;

M0 = (SPD*St1)* ( (TR_MT.*flipT1./flipMT) - (TR_T1.*flipMT./flipT1))./...
        ((St1.*TR_MT.*flipT1) - (SPD.*TR_T1.*flipMT));

MTsat = (M0 *flipMT/SMT - 1)*R1*TR_MT - (flipMT.^2)/2;


