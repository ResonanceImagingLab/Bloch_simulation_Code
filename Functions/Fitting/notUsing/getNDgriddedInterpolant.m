function F = getNDgriddedInterpolant( iP, StandardizedResidudals, LP, HP)

% use griddatan to convert input values into a meshgrid.

%% generate sampleGrid:
gridL = 8;
fitSz = length(LP);

v = zeros(gridL,fitSz);

for i = 1:fitSz
      v(:,i)= linspace(LP(i),HP(i), gridL);
end

if fitSz == 1
      output = v;

elseif fitSz == 2
      [x1, x2] = ndgrid(v(:,1), v(:,2));
      output = {x1, x2};

elseif fitSz == 3
      [x1, x2, x3] = ndgrid(v(:,1), v(:,2), v(:,3));
      output = {x1, x2, x3};

elseif fitSz == 4
      [x1, x2, x3, x4] = ndgrid(v(:,1), v(:,2), v(:,3), v(:,4));
      output = {x1, x2, x3, x4};

elseif fitSz == 5
      [x1, x2, x3, x4, x5] = ndgrid(v(:,1), v(:,2), v(:,3), v(:,4), v(:,5));
      output = {x1, x2, x3, x4, x5};

elseif fitSz == 6
      [x1, x2, x3, x4, x5, x6] = ndgrid(v(:,1), v(:,2), v(:,3), v(:,4), v(:,5), ...
            v(:,6));
      output = {x1, x2, x3, x4, x5, x6};

elseif fitSz == 7
      [x1, x2, x3, x4, x5, x6, x7] = ndgrid(v(:,1), v(:,2), v(:,3), v(:,4), v(:,5),...
       v(:,6), v(:,7));
      output = {x1, x2, x3, x4, x5, x6, x7};

elseif fitSz == 8
      [x1, x2, x3, x4, x5, x6, x7, x8] = ndgrid(v(:,1), v(:,2), v(:,3), v(:,4), v(:,5),...
       v(:,6), v(:,7), v(:,8));
      output = {x1, x2, x3, x4, x5, x6, x7, x8};

end


%% Use griddatan on the input values and use the grid as the query points
outVec = getNDvectors(fitSz, v);
% reformat grid for use in 

vq = griddatan( iP, StandardizedResidudals, outVec, 'linear');

vq = interpn( iP(:,1),iP(:,2),iP(:,3),iP(:,4),StandardizedResidudals,...
    x1, x2, x3, x4);


%% Fit a griddedInterpolant to the querypoints
F = griddedInterpolant(iP{1,2},iP{1,3},iP{1,4},SR, 'spline');
















