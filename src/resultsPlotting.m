
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AnTo/Gray/Averages_All_runs/ONEGAUSSIAN_wholebrain-gFit.mat')
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AnTo/Gray/MotionComp/ONEGAUSSIAN_wholebrain-gFit.mat')


% load
% VOLUME{1}
% VOLUME{1}.rm.retinotopyModels{1} == load your model, "model" structure
modelAverages{1}

% variance explained for average runs
veAverages=rmGet(modelAverages{1}, 've');

% varianece explained for "individual runs"
veRuns=rmGet(modelRuns{1}, 've');

% plot the correlation between these two
figure; plot(veRuns(veAverages>0.3), veAverages(veAverages>0.3),'.')

% plot corr for x0 - in ind runs
figure; plot(modelRuns{1}.x0(veAverages>0.3), modelAverages{1}.x0(veAverages>0.3),'.')

% plot corr for x0 - in average runs
figure; plot(modelAverages{1}.x0(veAverages>0.3), modelAverages{1}.y0(veAverages>0.3),'.')

% increase the threshold
figure; plot(modelAverages{1}.x0(veAverages>0.6), modelAverages{1}.y0(veAverages>0.6),'.')

% parietal - a bit random
VOLUME{1}.ROIs(2)

% get the indices of this roi - left aud
[tmp, roiInds{1}]=intersectCols(VOLUME{1}.coords, VOLUME{1}.ROIs(2).coords);
%roiInds
figure; plot(modelAverages{1}.x0(roiInds{1}), modelAverages{1}.y0(roiInds{1}),'.')
axis([-3 3 -3 3])

% get indices for right aud
[tmp, roiInds{2}]=intersectCols(VOLUME{1}.coords, VOLUME{1}.ROIs(3).coords);
figure; plot(modelAverages{1}.x0(roiInds{2}), modelAverages{1}.y0(roiInds{2}),'.')
axis([-3 3 -3 3])


[tmp, roiInds{3}]=intersectCols(VOLUME{1}.coords, VOLUME{1}.ROIs(1).coords);
figure; plot(modelAverages{1}.x0(roiInds{3}), modelAverages{1}.y0(roiInds{3}),'.')
axis([-3 3 -3 3])

% parietal 
[tmp, roiInds{4}]=intersectCols(VOLUME{1}.coords, VOLUME{1}.ROIs(1).coords);
figure; plot(modelAverages{1}.x0(roiInds{4} & veAverages>0.3), modelAverages{1}.y0(roiInds{4} & veAverages>0.3),'.')

%% under construction...
roiMatrix=zeros(size(roiInds{4} & veAverages>0.3));
roiMatrix=zeros(size(modelAverages{1}.x0);
roiMatrix=zeros(size(modelAverages{1}.x0));
roiMatrix(roiInds{4})=1;
figure; plot(modelAverages{1}.x0(roiMatrix & veAverages>0.3), modelAverages{1}.y0(roiMatrix & veAverages>0.3),'.')
figure; hist2d(modelAverages{1}.x0(roiMatrix & veAverages>0.3), modelAverages{1}.y0(roiMatrix & veAverages>0.3))
figure; hist2(modelAverages{1}.x0(roiMatrix & veAverages>0.3), modelAverages{1}.y0(roiMatrix & veAverages>0.3))
figure; hist3(modelAverages{1}.x0(roiMatrix & veAverages>0.3), modelAverages{1}.y0(roiMatrix & veAverages>0.3))













