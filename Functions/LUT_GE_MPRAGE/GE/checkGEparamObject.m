function checkGEparamObject(T1wInfo, PDwInfo )

% Check to make sure all the necessary parameters are filled in:
%% T1w images

% Timing info
if ~isfield(T1wInfo, 'TI');            error('Missing T1wInfo TI'); end
if ~isfield(T1wInfo, 'echoSpacing');   error('Missing T1wInfo echoSpacing'); end
if ~isfield(T1wInfo, 'numExcitation'); error('Missing T1wInfo numExcitation'); end
if ~isfield(T1wInfo, 'Readout');       error('Missing T1wInfo Readout encoding centric or linear'); end
if ~isfield(T1wInfo, 'TR');            error('Missing T1wInfo TR'); end    
if ~isfield(T1wInfo, 'flipAngle');     error('Missing T1wInfo flipAngle'); end

% Acceleration info for sampling table:
if ~isfield(T1wInfo, 'Orientation');   error('Missing T1wInfo Orientation: Axial, Sagittal, Coronal'); end
if ~isfield(T1wInfo, 'NumLines');      error('Missing T1wInfo NumLines'); end
if ~isfield(T1wInfo, 'NumPartitions'); error('Missing T1wInfo NumPartitions'); end
if ~isfield(T1wInfo, 'Slices');        error('Missing T1wInfo Slices'); end

if ~isfield(T1wInfo, 'Grappa');     error('Missing T1wInfo Grappa - 0 or 1'); end
if ~isfield(T1wInfo, 'ellipMask');  error('Missing T1wInfo ellipMask - 0 or 1'); end

if T1wInfo.Grappa
    if ~isfield(T1wInfo, 'AccelerationFactor'); error('Missing T1wInfo AccelerationFactor'); end
    if ~isfield(T1wInfo, 'ReferenceLines');     error('Missing T1wInfo ReferenceLines'); end
end

%% PDw images
if ~isfield(PDwInfo, 'TR');         error('Missing PDw TR');        end
if ~isfield(PDwInfo, 'flipAngle');  error('Missing PDw flipAngle'); end

% Acceleration info for sampling table:
if ~isfield(PDwInfo, 'Orientation');   error('Missing PDwInfo Orientation: Axial, Sagittal, Coronal'); end
if ~isfield(PDwInfo, 'NumLines');      error('Missing PDwInfo NumLines'); end
if ~isfield(PDwInfo, 'NumPartitions'); error('Missing PDwInfo NumPartitions'); end
if ~isfield(PDwInfo, 'Slices');        error('Missing PDwInfo Slices'); end


if ~isfield(PDwInfo, 'Grappa');     error('Missing PDwInfo Grappa - 0 or 1'); end
if ~isfield(PDwInfo, 'ellipMask');  error('Missing PDwInfo ellipMask - 0 or 1'); end

if PDwInfo.Grappa
    if ~isfield(PDwInfo, 'AccelerationFactor'); error('Missing PDwInfo AccelerationFactor'); end
    if ~isfield(PDwInfo, 'ReferenceLines');     error('Missing PDwInfo ReferenceLines'); end
end




