function [LP, HP] = updateSearchParams(fitVal, lp, hp)

% the goal of this function is to take an input fit, and move the
% search space closer to the optimal value by 1/3 on each side.
% step size becomes a trade off between avoiding wrong local minimum
% and speed

% Inputs:
% fitVal = 1xn vector of parameter estimates 
% lp = 1xn vector of low estimate limits
% hp = 1xn vector of high estimate limits


% Initialize with starting values
diffHigh = hp - fitVal;
diffLow = fitVal - lp;

HP = fitVal + 0.67*diffHigh;
LP = fitVal - 0.67*diffLow;

% It shouldn't happen, but if you end up outside the limits, this should fix them
HP(HP>hp) = hp(HP>hp);
LP(LP<lp) = lp(LP<lp);

