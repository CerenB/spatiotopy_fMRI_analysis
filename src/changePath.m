
% script is for changing dataTYPES input/paths

% load a session from ubuntu PC. which we already RUN pRF modeling with the
% paths set according to ubuntu PC
% we will use this paths and adjust with our new subject name

% load old subject from ubuntu
oldSubject = 'DaBe';
load(['/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/', ...
    oldSubject,'/studentUbuntu/mrSESSION.mat'])

% save its datatypes - individual runs
individualRuns = dataTYPES(3).retinotopyModelParams;

% save its datatypes - averaged runs
averagedRuns = dataTYPES(5).retinotopyModelParams;



%load new subject' session:
subject = 'AnTo';
mainPath =  '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/';
path2Session = fullfile(mainPath,subject, 'studentUbuntu', 'mrSESSION.mat');
load(path2Session)

% first check anatomical, is it OK?
vANATOMYPATH = ['/data2/spatiotopy/raw/SC/',subject,...
                '/sSPATIO_pRF_',subject,'.nii'];

%% assigned averaged runs
dataTypeInd = 6;
dataTYPES(dataTypeInd).retinotopyModelParams = averagedRuns;

% now changed the paths:
dataTYPES(dataTypeInd).retinotopyModelParams.paramsFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/params_pRF_averageAll.mat'];

dataTYPES(dataTypeInd).retinotopyModelParams.jitterFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/none'];

dataTYPES(dataTypeInd).retinotopyModelParams.imFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/images_pRF_average.mat'];


% save the mrSESSION.mat
save(path2Session, 'mrSESSION', 'dataTYPES', 'vANATOMYPATH');


%% now also do it for the individual runs:
% assigned individuals runs into MotionCom level, which is 3:
dataTYPES(3).retinotopyModelParams = individualRuns;

% now changed the paths:
for iFile = 1:7
    
    % it is fixed to none
    dataTYPES(3).retinotopyModelParams(iFile).jitterFile = ...
        ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/none'];
    
    % it is also fixed to 1 image file, 
    dataTYPES(3).retinotopyModelParams(iFile).imFile = ...
        ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/images_pRF.mat'];
    
    % this changes across runs
    dataTYPES(3).retinotopyModelParams(iFile).paramsFile = ...
        ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/params_tr_run', ...
        num2str(iFile),'.mat'];
    
end

save(path2Session, 'mrSESSION', 'dataTYPES', 'vANATOMYPATH');

%% assigned even and odd runs
dataTypeInd = 7; % 7 is Odd runs, and 8 is even in AnTo
dataTYPES(dataTypeInd).retinotopyModelParams = averagedRuns;

% now changed the paths:
dataTYPES(dataTypeInd).retinotopyModelParams.paramsFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/params_pRF_averageOdd.mat'];

dataTYPES(dataTypeInd).retinotopyModelParams.jitterFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/none'];

dataTYPES(dataTypeInd).retinotopyModelParams.imFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/images_pRF_averageOdd.mat'];

% save the mrSESSION.mat
save(path2Session, 'mrSESSION', 'dataTYPES', 'vANATOMYPATH');

% now even runs
dataTypeInd = 8;
dataTYPES(dataTypeInd).retinotopyModelParams = averagedRuns;

% now changed the paths:
dataTYPES(dataTypeInd).retinotopyModelParams.paramsFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/params_pRF_averageEven.mat'];

dataTYPES(dataTypeInd).retinotopyModelParams.jitterFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/none'];

dataTYPES(dataTypeInd).retinotopyModelParams.imFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/images_pRF_averageEven.mat'];


% save the mrSESSION.mat
save(path2Session, 'mrSESSION', 'dataTYPES', 'vANATOMYPATH');
