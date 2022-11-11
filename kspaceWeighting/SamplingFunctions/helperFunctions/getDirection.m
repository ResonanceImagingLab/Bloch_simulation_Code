function NextDir = getDirection(currentDirection, checkIteration)

% checkIteration is variable that we loop over for conditions
directions = [ 0,1; 1,0; 0, -1; -1,0]; % right, up, left, down

if isequal( currentDirection , directions(1,:))
    switch checkIteration
        case 1
            NextDir = directions(4,:);
        case 2
            NextDir = directions(1,:);
        case 3
            NextDir = directions(2,:);
        case 4
            NextDir = directions(3,:);
        otherwise
            error(' only 4 iterations allowed')
    end

elseif isequal( currentDirection ,directions(2,:))
    switch checkIteration
        case 1
            NextDir = directions(1,:);
        case 2
            NextDir = directions(2,:);
        case 3
            NextDir = directions(3,:);
        case 4
            NextDir = directions(4,:);
        otherwise
            error(' only 4 iterations allowed')
    end
elseif isequal( currentDirection ,directions(3,:))
    switch checkIteration
        case 1
            NextDir = directions(2,:);
        case 2
            NextDir = directions(3,:);
        case 3
            NextDir = directions(4,:);
        case 4
            NextDir = directions(1,:);
        otherwise
            error(' only 4 iterations allowed')
    end

elseif isequal( currentDirection ,directions(4,:))
    switch checkIteration
        case 1
            NextDir = directions(3,:);
        case 2
            NextDir = directions(4,:);
        case 3
            NextDir = directions(1,:);
        case 4
            NextDir = directions(2,:);
        otherwise
            error(' only 4 iterations allowed')
    end

else
    error('Unrecognized direction');

end