function outVec = getNDvectors(fitSz, LP, HP, numPoints)

% since the matrix gets large, do an iterative search approach based on LP
% and HP (low and high)

% for i = 1:fitSz
%       v1{i} = unique(iPr(:,i));
%       vs(i) = vs2(1)ngth(v1{i});
% end

%% Generate vectors
for i = 1:fitSz
      vq{i} = linspace( LP(i), HP(i), numPoints ); 
      vs2(i) = length(vq{i});
end


idx = 1;
outVec = zeros( prod(vs2),fitSz);

if fitSz == 1
      outVec = vq{1};

elseif fitSz == 2
    
    for a = 1:vs2(1)
        for b = 1:vs2(2)
            outVec(idx,:) = [vq{1}(a),vq{2}(b)];
            idx = idx+1;
        end
    end

elseif fitSz == 3
    for a = 1:vs2(1)
        for b = 1:vs2(2)
            for c = 1:vs2(3)
                outVec(idx,:) = [vq{1}(a),vq{2}(b),vq{3}(c)];
                idx = idx+1;
            end
        end
    end

elseif fitSz == 4
    for a = 1:vs2(1)
        for b = 1:vs2(2)
            for c = 1:vs2(3)
                for d = 1:vs2(4)
                    outVec(idx,:) = [vq{1}(a),vq{2}(b),vq{3}(c),vq{4}(d)];
                    idx = idx+1;
                end
            end
        end
    end

elseif fitSz == 5
    for a = 1:vs2(1)
        for b = 1:vs2(2)
            for c = 1:vs2(3)
                for d = 1:vs2(4)
                    for e = 1:vs2(5)
                        outVec(idx,:) = [vq{1}(a),vq{2}(b),vq{3}(c),vq{4}(d),vq{5}(e)];
                        idx = idx+1;
                    end
                end
            end
        end
    end

elseif fitSz == 6
    for a = 1:vs2(1)
        for b = 1:vs2(2)
            for c = 1:vs2(3)
                for d = 1:vs2(4)
                    for e = 1:vs2(5)
                        for f = 1:vs2(6)

                            outVec(idx,:) = [vq{1}(a),vq{2}(b),vq{3}(c),vq{4}(d),vq{5}(e)...
                                vq{6}(f)];
                            idx = idx+1;

                        end
                    end
                end
            end
        end
    end


elseif fitSz == 7

    for a = 1:vs2(1)
        for b = 1:vs2(2)
            for c = 1:vs2(3)
                for d = 1:vs2(4)
                    for e = 1:vs2(5)
                        for f = 1:vs2(6)
                            for g = 1:vs2(7)
                                outVec(idx,:) = [vq{1}(a),vq{2}(b),vq{3}(c),vq{4}(d),vq{5}(e)...
                                    vq{6}(f),vq{7}(g)];
                                idx = idx+1;
                            end
                        end
                    end
                end
            end
        end
    end

elseif fitSz == 8

    for a = 1:vs2(1)
        for b = 1:vs2(2)
            for c = 1:vs2(3)
                for d = 1:vs2(4)
                    for e = 1:vs2(5)
                        for f = 1:vs2(6)
                            for g = 1:vs2(7)
                                for h = 1:vs2(8)
                                    outVec(idx,:) = [vq{1}(a),vq{2}(b),vq{3}(c),vq{4}(d),vq{5}(e)...
                                        vq{6}(f),vq{7}(g),vq{8}(h)];
                                    idx = idx+1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

