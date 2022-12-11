% TempScript_GE_LUT_form.m

% without downloading all the imaging data, just make the lookup tables for
% all the dicom headers.
LUTsavDirEnd = 'LUT_files_t2_80ms';


for location = 1:3  
    
    %% Initialize Variables
    % Location of the Dicom Header script
    if location == 1
        SITE = 'McMaster';
    elseif location == 2
        SITE = 'Dal';
        elseif location == 3
        SITE = 'Calgary';
    elseif location == 4
        %SITE = 'Queens';
        error('Make call to Siemens script instead of the GE script')
    elseif location == 5
        %SITE = 'UNH';
        error('Make call to Siemens script instead of the GE script')
    end
    
    disp(['Working on location ', SITE])

    % load the excel sheet with sbuject name conversions
    if isunix
        filePath  = '/media/chris/SSD/';
        headerDir = '/media/chris/SSD/Research/Bipolar/Longitudinal_ICM_BD/BipolarMatlab/dicomHeaderReader/';
        
        % Location of surface data
        DATA_DIR=[filePath, 'Research/Bipolar/Longitudinal_ICM_BD/Longitudinal_ICM_BD_in_HDD/data/']; % Linux
        BalsaSurf_dir = [filePath, 'Research/Bipolar/Longitudinal_ICM_BD/Atlas/Balsa_Surfaces/' ];
    
        T = readcell(strcat(filePath, 'Research/Bipolar/Longitudinal_ICM_BD/Longitudinal_ICM_BD_in_HDD/data/',SITE,'/subjectNames.xlsx'));
    
            %%%%%%%%%%%%%% NEEDS TO BE CHANGED!
        LUTsavDir = [filePath,'Research\Bipolar\Longitudinal_ICM_BD\',LUTsavDirEndLUT_files,'\']; 
        MNIdir =  [filePath,'simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\'];
        MNISavDir = [filePath,'Research\Bipolar\Longitudinal_ICM_BD\LUT_files'];
    
    elseif ispc
        % Code to run on Windows platform
        %filePath  = 'E:\';
        headerDir = 'E:\Research/Bipolar/Longitudinal_ICM_BD/BipolarMatlab/dicomHeaderReader/';
        
        % Location of surface data
        DATA_DIR= 'F:\user\Research\Longitudinal_ICM_BD/data/'; % Linux
        BalsaSurf_dir = 'F:\user\Research\Longitudinal_ICM_BD/Atlas/Balsa_Surfaces/';
    
        % Location of LUT-related files:
        LUTsavDir = ['E:\Research\Bipolar\Longitudinal_ICM_BD\',LUTsavDirEnd,'\']; 
        MNIdir =  'C:\Users\crowle1\OneDrive - McGill University\ihMT_work\cortical_ihMT_sim\simCode\sim_wSpoil\RF_grad_diffusion_v4\kspaceWeighting\Atlas_reference\mni_icbm152_nlin_sym_09a_minc2\';
        MNISavDir = 'E:\Research\Bipolar\Longitudinal_ICM_BD\LUT_files\'; 
    
        T = readcell(strcat('F:\user\Research\Longitudinal_ICM_BD/data/',SITE,'/subjectNames.xlsx') );
    
    else
        disp('Platform not supported')
    end
    
    
    %% Start by loading the the dicom header
    
    
    storageMat_table = load( strcat(headerDir, SITE, '_header_info.mat'));
    storageMat_table = storageMat_table.storageMat_table;
    
%     
%     %% Find unique entries based on TI, TR and TE
%     tempTable = cell2mat(table2array(storageMat_table(:,3:6)));
%     [C,ia,ic] = unique(tempTable,'rows'); % C = A(ia,:) and A = C(ic,:).
%     subNames = storageMat_table(ia,:);
    %% Find the subject names that correspond to these entries:
    sub = storageMat_table(:,1);
    sub = (table2array(sub));
    sub = sub(~cellfun(@isempty,sub));
    [ExamNames, ~]=unique( sub);

    dcmHdr = table2array(storageMat_table);

    for z = 1:length(ExamNames)

        disp(['Working on number ', num2str(z)])
        disp(['Out of ', num2str(length(ExamNames))])

        %% LUT calc:
        clear Params PDwInfo T1wInfo
    
        Params.MTC = 0;
        Params.B0 = 3;
        Params.TissueType = 'WM';
        Params = DefaultCortexTissueParams(Params);
        [T1wInfo, PDwInfo] = defaultGEparamObject(Params);

        %% Pull subject specific details:

         temp = dcmHdr (strcmp( dcmHdr(:,1), ExamNames{z} ),:);
         pd_row  =  temp(contains(temp(:,2),'FLASH PD'),:); 
        % PD will be same for left and right
         PDwInfo.flipAngle = cell2mat( pd_row(1,6)) ;
         PDwInfo.TR =cell2mat( pd_row(1,3))/1000; % in seconds     

         % Most parameters are set in function defaultGEparamObject.m
         T1wInfoL = T1wInfo;
         T1wInfoR = T1wInfo;

         % Find index with Left T1w
         t1_row  =  temp(contains(temp(:,2),'LT'),:); 
         T1wInfoL.flipAngle = mean(cell2mat(t1_row(:,6))) ;
         T1wInfoL.echoSpacing = mean(cell2mat(t1_row(:,3)))/1000; % in seconds
         T1wInfoL.TR  =  T1wInfoL.TI  + T1wInfoL.TD + T1wInfoL.echoSpacing*(T1wInfoL.TurboFactor + T1wInfoL.DummyEcho) ;
        
         % Right side
         t1_row  =  temp(contains(temp(:,2),'RT'),:); 
         T1wInfoR.flipAngle = mean(cell2mat(t1_row(:,6))) ;
         T1wInfoR.echoSpacing = mean(cell2mat(t1_row(:,3)))/1000; % in seconds
         T1wInfoR.TR  =  T1wInfoR.TI  + T1wInfoR.TD + T1wInfoR.echoSpacing*(T1wInfoR.TurboFactor + T1wInfoR.DummyEcho) ;  
    
        checkGEparamObject(T1wInfoL, PDwInfo );
        
        for y = 1:2 % for left and right values

            if y ==1
                T1wInfo = T1wInfoL;
            elseif y == 2 
                T1wInfo = T1wInfoL;
            end

            % Extract imaging params.
            TI = T1wInfo.TI;
            echoSpacing = T1wInfo.echoSpacing;
            numExcitation = T1wInfo.numExcitation;
            Readout = T1wInfo.Readout;
            TR = T1wInfo.TR;
            t1flip = T1wInfo.flipAngle;
            pdTR = PDwInfo.TR;
            pdflip = PDwInfo.flipAngle;
                       
            % Build LUT filename string:
            
            LUT_str = strcat(Readout, '_TI', num2str(TI), '_TR',num2str(TR), '_flip',num2str(t1flip), ...
                    '_echoSp',num2str(echoSpacing), '_turbofact',num2str(numExcitation), ...
                    '_pdTR',num2str(pdTR), '_pdflip',num2str(pdflip) );
            
            
            % Check if LUT exists for these parameters so that you do not need to recompute them.
            if ~isfile( strcat(LUTsavDir,LUT_str,'.mat'))
            
                disp('Creating new lookup table....')
                disp(LUT_str)
                
%                 % Need to generate the sampling tables and pull k-space segmentations
%                 % The below function does the check for files, and makes if they don't
%                 % exist
%                 str1 = GenFlexible_MNI_KspaceMatrix( T1wInfo, MNISavDir, MNIdir );
%                 str2 = GenFlexible_MNI_KspaceMatrix( PDwInfo, MNISavDir, MNIdir );
%             
%                 T1w_b    = load(strcat(MNISavDir,str1,'/','brain_m.mat'));
%                 T1w_fftb = load(strcat(MNISavDir,str1,'/','fft_brain_m.mat'));
%                 PDw_b    = load(strcat(MNISavDir,str2,'/','brain_m.mat'));
%                 PDw_fftb = load(strcat(MNISavDir,str2,'/','fft_brain_m.mat'));
            
                LUT = compute_2pt_inversion_LUT_1pool(T1wInfo, PDwInfo, LUT_str, LUTsavDir);  
            end

        end % for y = 1:2 % for left and right values

    end % for z = 1:length(ExamNames)


end % end location = 1:3



