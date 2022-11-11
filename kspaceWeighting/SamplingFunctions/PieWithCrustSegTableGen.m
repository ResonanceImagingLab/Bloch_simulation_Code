% Custom pie with crust sampling scheme
% goal of this is to circle around the outside for the first minute
% then pie seg the middle

iNumLines = 216;
iNumPart = 196;
ellipticalMask = 1;
iTurbofactor = 14;
TR = 0.2;

%% LibKspace starts page 229 in IDEA user guide:

% need to output sample table consider 5 1xN arrays
elementIdx  = (1: iNumLines*iNumPart)';
lineIdx = repmat(1:iNumLines,1,iNumPart); lineIdx = lineIdx(:);
partIdx = repmat(1:iNumLines,iNumPart,1); partIdx = partIdx(:);

segIdx  = zeros(iNumLines*iNumPart,1); % which segment it belongs to
subIdx  = zeros(iNumLines*iNumPart,1); % the ordering within the segment
tempView = zeros(iNumLines*iNumPart,1); % I will build this one to view the results

mask = zeros(iNumLines*iNumPart,1); % the mask will get added for pieSeg after

if ellipticalMask
    A = ellipMask([floor(iNumLines/2)*1.02 floor(iNumPart/2)*1.02], [iNumLines iNumPart], [floor(iNumLines/2) floor(iNumPart/2)]) ;
    A = A(:);
    mask(A == 0) = 1;
else
    mask = zeros(iNumLines*iNumPart,1); % the mask will get added for pieSeg after
end



% viewResult = reshape(mask,iNumLines,iNumPart);
% figure;
% imagesc(rot90(viewResult))
% axis image
% %caxis([0 15])
% colormap(jet)
% colorbar



%% Find how many lines acquired in the first 1min to make the crust

linesCrust = 60/TR *iTurbofactor;


%% Crust algorithm:
% keep searching right, if right is filled, then go straight, if not then
% left. Else return error.

directions = [ 0,1; 1,0; 0, -1; -1,0]; % right, up, left, down

currentDirection = directions(1,:); % store row of current direction

currIdx = [iNumLines, floor(iNumPart/2)]; % start mid right of matrix
currSeg = 0;
counter = 1;

while counter < linesCrust
    
    % loop through the segments
    for iter = 1:iTurbofactor 

        % get element index
        idx = getElementIndex(currIdx(1), currIdx(2), iNumLines);

        % set values:
        segIdx(idx) = currSeg;
        subIdx(idx) = iter;
        mask(idx) = 1;
        tempView(idx) = counter;
        

        % update values for next loop;
        valid = 0;
        checkIteration = 1;

        while valid == 0
            NextDir = getDirection(currentDirection, checkIteration);

            % invalid if exceed matrix size, or mask is 1
            proposedIdx = [currIdx(1)+ NextDir(1) ,  currIdx(2)+ NextDir(2)];
            temp = getElementIndex(proposedIdx(1), proposedIdx(2), iNumLines);

            if proposedIdx(1) > iNumLines || proposedIdx(2) > iNumPart || proposedIdx(1) < 1 || proposedIdx(2) < 1
                checkIteration = checkIteration +1;
                continue;
            elseif mask(getElementIndex(proposedIdx(1), proposedIdx(2), iNumLines)) == 1
                checkIteration = checkIteration +1;
                continue;
            end
    
            currentDirection = NextDir;
            currIdx = proposedIdx;
            valid = 1;
        end

        counter = counter+1;
    end

    currSeg = currSeg+1;
end



viewResult = reshape(tempView,iNumLines,iNumPart);
figure;
imagesc(rot90(viewResult))
axis image
%caxis([0 15])
colormap(jet)
colorbar

















