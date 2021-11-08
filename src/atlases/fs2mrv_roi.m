function fs2mrv_roi

% trying to convert FreeSurfer binary masks to mrvista masks


forceOverwrite = false;
dFolder = mrtInstallSampleData('anatomy/freesurfer', 'ernie', ...
    fssubjectsdir, forceOverwrite);

fprintf('Freesurfer directory for ernie installed here:\n %s\n', dFolder)

% Now run the docker, first checking whether it has already been run. 
wangAtlasPath = sprintf(fullfile(dFolder, 'mri',...
    'native.wang2015_atlas.mgz'));

if exist(wangAtlasPath, 'file')
    warning(strcat('It looks like the docker was already run on ernie.', ...
        ' We will proceed without re-running the docker.'))
else
    % Run the docker using a system call
    str = sprintf('docker run -ti --rm -v %s:/input \\nben/occipital_atlas:latest', dFolder);
    system(str)
end

if ~exist(wangAtlasPath, 'file')
   error('Cannot find the file %s, which is an expected output of the docker. Cannot proceed', wangAtlasPath);
end
%% Navigate

mrvCleanWorkspace();

% Find ernie PRF session in scratch directory
erniePRF = fullfile(vistaRootPath, 'local', 'scratch', 'erniePRF');

if ~exist(erniePRF, 'dir')
    % If we did not find the temporary directory created by prior
    % tutorials, then use the full directory, downloading if necessary        
    erniePRF = mrtInstallSampleData('functional', 'erniePRF');
end

% Clean start in case we have a vista session open
mrvCleanWorkspace();

% Remember where we are
curdir = pwd();

cd(erniePRF);

% Open a 3-view vista session

% Check that scratch ernie directory has been set up with a intialized
% vistasession
if ~exist(fullfile('Gray', 'coords.mat'), 'file')    
    warning(strcat('It looks like you did not run the pre-requisite tutorials. ', ...
        ' Therefore we will use the already processed session in local/erniePRF ', ...
        ' rather than local/scratch/erniePRF.'))
    erniePRF = mrtInstallSampleData('functional', 'erniePRF');
    cd(erniePRF);
end

vw = mrVista('3');

%% Open meshes
mesh1 = fullfile('3DAnatomy', 'Left', '3DMeshes', 'Left_inflated.mat');
mesh2 = fullfile('3DAnatomy', 'Right', '3DMeshes', 'Right_inflated.mat');

if ~exist(mesh1, 'file') || ~exist(mesh2, 'file')
    error('Meshes not found. Please run t_meshFromFreesurfer.')
end
[vw, OK] = meshLoad(vw, mesh1, 1); if ~OK, error('Mesh server failure'); end
[vw, OK] = meshLoad(vw, mesh2, 1); if ~OK, error('Mesh server failure'); end

%% Wang ROIs

% Convert mgz to nifti
[pth, fname] = fileparts(wangAtlasPath);
wangAtlasNifti = fullfile(pth, sprintf('%s.nii.gz', fname));

ni = MRIread(wangAtlasPath);
MRIwrite(ni, wangAtlasNifti);

% Load the nifti as ROIs
vw = wangAtlasToROIs(vw, wangAtlasNifti);

% Save the ROIs
local = false; forceSave = true;
saveAllROIs(vw, local, forceSave);
 
% Let's look at the ROIs on meshes
%   Store the coords to vertex mapping for each ROI for quicker drawing
vw = roiSetVertIndsAllMeshes(vw); 

vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
hTmp(1) = figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 


end