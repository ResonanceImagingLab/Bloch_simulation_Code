function R = RotationMatrix_1pool_Inversion(fa, ph)
% Rotation matrix for a flip angle and phase:
% Note that these matlab functions assume both values are in radians

R = [cos(fa)+(1-cos(fa))*cos(ph)^2, (1-cos(fa))*sin(ph)*cos(ph),    -sin(fa)*sin(ph);...
    (1-cos(fa))*sin(ph)*cos(ph),    cos(fa)+(1-cos(fa))*sin(ph)^2 ,  sin(fa)*cos(ph);...
    sin(fa)*sin(ph),                     -sin(fa)*cos(ph),                   cos(fa)];














































