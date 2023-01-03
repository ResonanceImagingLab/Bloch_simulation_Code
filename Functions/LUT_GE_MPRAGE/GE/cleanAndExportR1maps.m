function R1 = cleanAndExportR1maps(T1, size_vol, BaseFldr, SPACE, Hdrinfo)

R1 = (1./T1)*1000;
R1( R1 < 0 | isnan(R1) | isinf(R1)) = 0; % remove nan and inf
R1( R1>3 ) = 3; 

%% Put back into cube and export
q = 1:length(R1);
R1_vol = zeros( size_vol);
R1_vol(q)  = R1;

outputName = fullfile(BaseFldr, SPACE, 'R1_map.nii' );

% Clean up
Hdrinfo.Datatype = 'double'; % change from single
niftiwrite(R1_vol, char(outputName), Hdrinfo, 'Compressed',false);