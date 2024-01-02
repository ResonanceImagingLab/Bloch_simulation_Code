function R = Rotation3D( x , y, z)
% Rotation matrix for rotations in each dimension. 
% Rotation in degrees around x, y, and z in radians.

% Note that matlab uses flipped axes for plotting, so you may need to do
% something like this to apply a flip angle:
% R = Rotation3D( -flipAng*cos(-spinPhase), -flipAng*sin(spinPhase), 0 );


Rz = [cos(z) -sin(z) 0;...
      sin(z) cos(z) 0;...
      0 0 1];

Ry = [cos(y),  0, sin(y);...
      0, 1, 0;...
      -sin(y), 0, cos(y)];

Rx = [1, 0, 0;...
      0, cos(x), -sin(x);...
      0, sin(x), cos(x)];

R = Rz*Ry*Rx;
