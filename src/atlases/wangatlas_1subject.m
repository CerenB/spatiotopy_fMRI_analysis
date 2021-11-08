% t_atlasAndTemplates
% source : https://github.com/vistalab/vistasoft/blob/master/tutorials/anatomy/anatomy/t_atlasAndTemplates.m

% to make ROIs and templates from Wang maximum probabiltiy atlas
% and from Benson V1-V3 atlas for 1 subject
% 
%
% Dependencies: to be ran in bash editor / terminal window: 
% /Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code/pRF_codes
% Wangatlas_docker.sh runs the below:
%   Freesurfer
%   Docker

% Summary
%
% - Run Noah Benson's template docker on subject's freesurfer directory
% - Navigate and open the subject's vistasession
% - Open and smooth meshes
% - Create and visualize 25 ROIs from Wang et al maximum probability atlas
% - Create and visualize V1-V3 ROIs from Benson atlas
% - Load and visualize eccentricity and polar angle maps from Benson atlas
%
% Tested 12/5/2016 - MATLAB r2015b, Mac OS 10.12.1
%
% Winawerlab, NYU
% cb edited on 03.05.2019 / 25.02.2020

%% Run Noah Benson's docker on AlSa freesurfer directory
% add path
% restore matlab default paths in order to start clean

% freesurfer remote desktop
addpath(genpath('/Users/cerenbattal/Documents/MATLAB/RemoteDataToolbox-master'));

% mrVista
addpath(genpath('/Users/cerenbattal/Documents/MATLAB/vistasoft-master'));

%% freesurfer
% Check whether freesurfer paths exist
fssubjectsdir = getenv('SUBJECTS_DIR');
if isempty(fssubjectsdir)
    error('Freesurfer paths not found. Cannot proceed.')
end


% 
% Get subject's freesurfer directory and install it in freesurfer subjects dir.
%   If we find the directory, do not bother unzipping again.
subject = 'AlSa2'; %AlSa is with deprecated docker

forceOverwrite = false;
dFolder = ['/Applications/freesurfer/subjects/',subject];

fprintf('Freesurfer directory for subject are here:\n %s\n', dFolder)

% Now run the docker, first checking whether it has already been run. 
wangAtlasPath = sprintf(fullfile(dFolder, 'surf',...
    'rh.wang15_mplbl.mgz'));

% does not have the link between FS and matlab atm
if exist(wangAtlasPath, 'file')
    warning(strcat('It looks like the docker was already run on subject.', ...
        ' We will proceed without re-running the docker.'))
else
    % Run the docker using a system call
    %str = sprintf('docker run -ti --rm -v %s:/input \\nben/occipital_atlas:latest', dFolder);
    str = sprintf('docker run -ti --rm -v %s:/subjects nben/neuropythy \atlas --verbose %s',dFolder,subject);
    system(str)
end

if ~exist(wangAtlasPath, 'file')
   error('Cannot find the file %s, which is an expected output of the docker. Cannot proceed', wangAtlasPath);
end
%% Navigate

% Find ernie PRF session in scratch directory
subject = 'AlSa';
subjectPRF = ['/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/SC/',subject];



% Clean start in case we have a vista session open
mrvCleanWorkspace();

% Remember where we are
%curdir = pwd();

cd(subjectPRF);

% Open a 3-view vista session

% Check that scratch ernie directory has been set up with a intialized
% vistasession
if ~exist(fullfile('Gray', 'coords.mat'), 'file')    
    warning(strcat('It looks like you do not have pRF maps for this subject'))
end

vw = mrVista('3');

%% Open meshes
% CHANGE THIS ONE ACCORDINGLY 

% make inflated.mat files.

mesh1 = fullfile('left_01032019.mat');
mesh2 = fullfile('right_01032019.mat');

if ~exist(mesh1, 'file') || ~exist(mesh2, 'file')
    error('Meshes not found. Please run t_meshFromFreesurfer.')
end
[vw, OK] = meshLoad(vw, mesh1, 1); if ~OK, error('Mesh server failure'); end
[vw, OK] = meshLoad(vw, mesh2, 1); if ~OK, error('Mesh server failure'); end


mesh1 = meshSet(vw.mesh{1},'smooth_relaxation',1);   
mesh1 = meshSet(mesh1,'smooth_sinc_method',0);   
mesh1 = meshSet(mesh1,'smooth_iterations',128);   
vw.mesh{1} = meshSmooth(mesh1);

mesh2 = meshSet(vw.mesh{2},'smooth_relaxation',1);   
mesh2 = meshSet(mesh2,'smooth_sinc_method',0);   
mesh2 = meshSet(mesh2,'smooth_iterations',128);   
vw.mesh{2} = meshSmooth(mesh2);

%not sure if you need to visualise it again
meshVisualize(vw.mesh{2});


%% load our data
% https://github.com/WinawerLab/MRI_tools/blob/master/retinotopy/bids_solve_pRFs.m
datasets = {'Averages'};
output_path = fullfile(subjectPRF,'Gray',datasets{1});

flnms = {'xcrds.nii.gz', 'ycrds.nii.gz', 'sigma.nii.gz', 'vexpl.nii.gz'};
vsnms = {'x0', 'y0', 'sigma', 'variance explained'};
fieldnames = {'map','map','map','co'};

    
% load dataType
vw = viewSet(vw, 'current DataTYPE', datasets{1});

% this is the most recent performed f-fit .mat file
ffit_flnm = rmDefaultModelFile(vw,datasets{1});

%load a pRF model (results)
vw = rmSelect(vw, true, ffit_flnm);
rm = viewGet(vw, 'retinotopy model');

% Load and export the angle/eccen
for ii = 1:numel(flnms)
    disp(flnms{ii});
    flnm = fullfile(output_path, flnms{ii});
    if exist(flnm, 'file')
        fprintf('Skipping export of existing file %s\n', flnm);
        continue;
    else
        fprintf('Exporting file %s\n', flnms{ii});
        vw = rmLoad(vw, 1, vsnms{ii}, fieldnames{ii});
        vw = viewSet(vw, 'displaymode', fieldnames{ii});
        %functionals2nifti(vw, [], flnm);
    end
end

% load parameter map
% try eccentricity
vw = rmLoad(vw, 1, 'eccentricity', 'map');
vw = viewSet(vw, 'displaymode', 'map');

% notes:
% i'm suspecting displaymode is not the accurate one here?

% refresh
vw  = setDisplayMode(vw, 'map');
%set the visual limits
% crashes
vw = setClipMode(vw,[vw.ui,[-2 2]]);
        



%%

% refresh it afterwards to see
vw  = refreshScreen(vw);

vw = meshUpdateAll(vw); 



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


% For fun, color the meshes
nROIs = length(viewGet(vw, 'ROIs'));
colors = hsv(nROIs);
for ii = 1:nROIs
   vw = viewSet(vw, 'ROI color', colors(ii,:), ii); 
end
vw = viewSet(vw, 'roi draw method', 'boxes');

vw = meshUpdateAll(vw); 
% Copy the mesh to a Matlab figure
hTmp(2) = figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 


%% Benson ROIs
% LOAD THE BENSON ATLAS AS ROIS (V1-V3)
bensonROIsPath = sprintf(fullfile(dFolder, 'mri',...
    'native.template_areas.mgz'));

[pth, fname] = fileparts(bensonROIsPath);
bensonROIsNifti = fullfile(pth, sprintf('%s.nii.gz', fname));

ni = MRIread(bensonROIsPath); 
MRIwrite(ni, bensonROIsNifti);

% Hide ROIs in the volume view, because it is slow to find and draw the
% boundaries of so many ROIs
vw = viewSet(vw, 'Hide Gray ROIs', true);

% Load the nifti as ROIs
numROIs = length(viewGet(vw, 'ROIs'));
vw = nifti2ROI(vw, bensonROIsNifti);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V1', numROIs + 1);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V2', numROIs + 2);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V3', numROIs + 3);

% Visualize Benson ROIs overlayed on Wang atlas
vw = viewSet(vw, 'ROI draw method', 'perimeter');
vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
hTmp(3) = figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 

%% Benson scanner template -- cb edition 02.05.2019

%cb edited : "rawavg.mgz"  orientation
bensonROIsPath_scan = sprintf(fullfile(dFolder, 'mri',...
    'scanner.template_areas.mgz'));

[pth, fname] = fileparts(bensonROIsPath_scan);
bensonROIsNifti = fullfile(pth, sprintf('%s.nii.gz', fname));

ni = MRIread(bensonROIsPath_scan); 
MRIwrite(ni, bensonROIsNifti);

% Hide ROIs in the volume view, because it is slow to find and draw the
% boundaries of so many ROIs
vw = viewSet(vw, 'Hide Gray ROIs', true);

% Load the nifti as ROIs
numROIs = length(viewGet(vw, 'ROIs'));
vw = nifti2ROI(vw, bensonROIsNifti);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V1', numROIs + 1);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V2', numROIs + 2);
vw = viewSet(vw, 'ROI Name', 'BensonAtlas_V3', numROIs + 3);

% Visualize Benson ROIs overlayed on Wang atlas
vw = viewSet(vw, 'ROI draw method', 'perimeter');
vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
hTmp(3) = figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 

%% Benson eccentricity and polar angle maps

% Find the volumetric maps in the freesurfer directory made by the benson
% docker
bensonEccPath = sprintf(fullfile(dFolder, 'mri',...
    'native.template_eccen.mgz'));
bensonAnglePath = sprintf(fullfile(dFolder, 'mri',...
    'native.template_angle.mgz'));

% ECCENTRICITY -----------------------------------------------------
% Load and display the eccentricity map
[~, fname] = fileparts(bensonEccPath);
writePth = fullfile('Gray', 'Original');
bensonEccNifti = fullfile(writePth, sprintf('%s.nii.gz', fname));
mkdir(writePth);
ni = MRIread(bensonEccPath); 
MRIwrite(ni, bensonEccNifti);

vw = viewSet(vw, 'display mode', 'map');
vw = loadParameterMap(vw, bensonEccNifti);

% use truncated hsv colormap (fovea is red, periphery is blue)
vw.ui.mapMode = setColormap(vw.ui.mapMode, 'hsvTbCmap'); 

% limit to ecc > 0
vw = viewSet(vw, 'mapwin', [eps 90]);
vw = viewSet(vw, 'mapclip', [eps 90]);
vw = refreshScreen(vw);
vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
hTmp(4) = figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 

% POLAR ANGLE -----------------------------------------------------
% Load and display the angle map
[~, fname] = fileparts(bensonAnglePath);
writePth = fullfile('Gray', 'Original');
bensonAngleNifti = fullfile(writePth, sprintf('%s.nii.gz', fname));
mkdir(writePth);
ni = MRIread(bensonAnglePath); 
MRIwrite(ni, bensonAngleNifti);

vw = viewSet(vw, 'display mode', 'map');
vw = loadParameterMap(vw, bensonAngleNifti);

% use  hsv colormap
vw.ui.mapMode = setColormap(vw.ui.mapMode, 'hsvCmap'); 

% limit to angles > 0
vw = viewSet(vw, 'mapwin', [eps 180]);
vw = viewSet(vw, 'mapclip', [eps 180]);
vw = refreshScreen(vw);
vw = meshUpdateAll(vw); 

% Copy the mesh to a Matlab figure
hTmp(5) = figure('Color', 'w');
imagesc(mrmGet(viewGet(vw, 'Mesh'), 'screenshot')/255); axis image; axis off; 

return

% Clean up
vw = meshDelete(vw, inf);
close(viewGet(vw, 'fignum'));
close(hTmp)
mrvCleanWorkspace
cd(curdir)


%% unused codes
%smooth the meshes
% 
% dataDir     = subjectPRF;
% fName       = fullfile(dataDir, 'Native_space','ribbon-in-rawavg_GM0_WM_new.nii');
% niftiImage  = niftiRead(fName, []);  % Read just the header
% mmPerVox    = niftiImage.pixdim;         % Get the pixel size
% 
% % Run the build code, perform smoothing/coloring
% msh = meshBuildFromClass(fName, mmPerVox, 'left'); % 'right' also works
% 
% 
% msh = mrmReadMeshFile(mesh1);
% msh = meshSmooth(msh,1);
% 
% msh2 = mrmReadMeshFile(mesh2);
% msh2 = meshSmooth(msh2,1);
% 
% 