
%% Problem is that I have a long running script over many iterations
% you cannot save things mid -parallel loop, because the results are not
% together.

% One option is to break down a loop vector into chunks. Then run parfor
% loop inside that loop. Example:

loopVec = 1:1e6;
numChunk = 20;
st = linspace( min(loopVec),max(loopVec), numChunk +1);
ed = st(2:end); % remove start index
ed(1:end-1) = ed(1:end-1)+1; % increment to prevent overlap
st = st(1:end-1); % remove last index

tic
for i = 1:numChunk
    stVal = st(i);
    edVal = ed(i);

    parfor qi = stVal:edVal

        % run function here
    end

    save(outputs);

    disp(i/numchunks*100) % print progress
    toc
end
toc
































tic % Took 90 hours to run
parfor qi = 1:simLength2

    t1 = parametersSet2(qi,1);
    t2 = parametersSet2(qi,2);
    t3 = parametersSet2(qi,3);
    t4 = parametersSet2(qi,4);
    t5 = parametersSet2(qi,5);
    t6 = parametersSet2(qi,6);

    for i = 1:10
         [Ssig1,~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'single', 'b1', B1rms(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 ); 
         Single_sig1_v7(qi,:,i) = Ssig1;
               
    end
    for i = 1:10
         [Ssig2,~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'single', 'b1', B1rms(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
         Single_sig2_v7(qi,:,i) = Ssig2;
    end
    for i = 1:10
         [Ssig3,~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'single', 'b1', B1rms(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
         Single_sig3_v7(qi,:,i) = Ssig3; 
    end
    
    for i = 1:10
         [Dsig1,~, ~]  = BlochSimFlashSequence_v2(Params,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
         Dual_sig1_v7(qi,:,i)   = Dsig1;     
    end
    for i = 1:10
         [Dsig2,~, ~]  = BlochSimFlashSequence_v2(Params2,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 );
         Dual_sig2_v7(qi,:,i)   = Dsig2;  
    end

    for i = 1:10
         [Dsig3,~, ~]  = BlochSimFlashSequence_v2(Params3,'freqPattern', 'dualAlternate', 'b1', B1rms(i),...
             'R', t1, 'T2a', t2, 'T1D',t3, 'T2b', t4, 'M0b', t5, 'R1b', t6 ); 
         Dual_sig3_v7(qi,:,i)   = Dsig3;    
    end
                        
            
                                               
    if rem(qi, 50) == 0

       qi/simLength *100 % print percent done
        parsave(strcat(SavDir,'Single_sig1_v7.mat'), Single_sig1_v7)
        parsave(strcat(SavDir,'Single_sig2_v7.mat'), Single_sig2_v7)
        parsave(strcat(SavDir,'Single_sig3_v7.mat'), Single_sig3_v7)
        parsave(strcat(SavDir,'Dual_sig1_v7.mat'), Dual_sig1_v7)
        parsave(strcat(SavDir,'Dual_sig2_v7.mat'), Dual_sig2_v7)
        parsave(strcat(SavDir,'Dual_sig3_v7.mat'), Dual_sig3_v7)
    end

          
end      
toc


      parsave(strcat(SavDir,'intermed_Sig_v7'), 10,...
            (Single_sig1_v7), (Single_sig2_v7), (Single_sig3_v7),...
            (Dual_sig1_v7), (Dual_sig2_v7), (Dual_sig3_v7));

        parsave(strcat(SavDir,'intermed_Sig_v7'), 10,...
            getLocalPart(Single_sig2_v7(qi,:,:)), getLocalPart(Single_sig2_v7(qi,:,:)), getLocalPart(Single_sig3_v7(qi,:,:)),...
            getLocalPart(Dual_sig1_v7(qi,:,:)), getLocalPart(Dual_sig2_v7(qi,:,:)), getLocalPart(Dual_sig3_v7(qi,:,:)));

%         parsave(strcat(SavDir, num2str(labindex),'Single_sig2_v7.mat'), getLocalPart(Single_sig2_v7));
%         parsave(strcat(SavDir, num2str(labindex),'Single_sig3_v7.mat'), getLocalPart(Single_sig3_v7));
%         parsave(strcat(SavDir, num2str(labindex),'Dual_sig1_v7.mat'), getLocalPart(Dual_sig1_v7));
%         parsave(strcat(SavDir, num2str(labindex),'Dual_sig2_v7.mat'), getLocalPart(Dual_sig2_v7));
%         parsave(strcat(SavDir, num2str(labindex),'Dual_sig3_v7.mat'), getLocalPart(Dual_sig3_v7));