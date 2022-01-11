
% changing dataTYPES input 

% load a session from ubuntu PC
oldSubject = 'DaBe';
load(['/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/', ...
    oldSubject,'/studentUbuntu/mrSESSION.mat'])

% save its datatypes - individual runs
individualRuns = dataTYPES(3).retinotopyModelParams;

% save its datatypes - averaged runs
averagedRuns = dataTYPES(5).retinotopyModelParams;

% dataTYPES(7).retinotopyModelParams.imFile
%  
% dataTYPES(7).retinotopyModelParams.jitterFile
% 
% dataTYPES(7).retinotopyModelParams.paramsFile


%load new subject' session:
subject = 'AnTo';
mainPath =  '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/';
path2Session = fullfile(mainPath,subject, 'studentUbuntu', 'mrSESSION.mat');
load(path2Session)

% first check anatomical, is it OK?
vANATOMYPATH = ['/data2/spatiotopy/raw/SC/',subject,...
                '/sSPATIO_pRF_',subject,'.nii'];

%% assigned averaged runs
AverageInd = length(dataTYPES);
dataTYPES(AverageInd).retinotopyModelParams = averagedRuns;

% now changed the paths:
dataTYPES(AverageInd).retinotopyModelParams.paramsFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/params_pRF_averageAll.mat'];

dataTYPES(AverageInd).retinotopyModelParams.jitterFile = ...
    ['/data2/spatiotopy/raw/SC/',subject,'/Stimuli/none'];

dataTYPES(AverageInd).retinotopyModelParams.imFile = ...
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




