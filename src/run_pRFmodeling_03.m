
clear all;
close all;

%add path mrvista
mrvistaPath = '/Users/battal/Documents/MATLAB/vistasoft';
addpath(genpath(mrvistaPath));

% go to subject's folder
subjectPath = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot';
cd(subjectPath);


% rmMain([1 3],ROIname,5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain');

%rmMain([1 3],[],5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain');
rmMain([1 6],[],5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain');

rmMain([1 6],'Right_Aud',5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_right_aud');

%cd /home/battal/Documents/AnBa
rmMain([1 6],'left_Auditory',5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_left_aud2');

%AlSa
rmMain([1 7],'left_Auditory',5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_left_aud2');


% 08.12.2021
rmMain([1 3],[],1,'model',{'one gaussian'},'hrf',...
    {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
    'matfilename','ONEGAUSSIAN_wholebrain', ...
    'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
    'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);


%Making the average run stimulus description
seq(:,1)=stimulus.seq;
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/params_tr_run2.mat')
seq(:,2)=stimulus.seq;
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/params_tr_run3.mat')
seq(:,3)=stimulus.seq;
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/params_tr_run4.mat')
seq(:,4)=stimulus.seq;
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/params_tr_run5.mat')
seq(:,5)=stimulus.seq;
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/params_tr_run6.mat')
seq(:,6)=stimulus.seq;
load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/params_tr_run7.mat')
seq(:,7)=stimulus.seq;

load('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot/Stimuli/images_pRF.mat')

whichRuns=1:7;
TRs=160;
imagesNew=zeros([size(images, 1), size(images, 2), TRs]);
for run=whichRuns;
    for TR=1:TRs
        imagesNew(:,:,TR)=imagesNew(:,:,TR)+images(:,:,seq(TR,run));
    end
end
    
imagesNew=imagesNew./max(imagesNew(:));


figure; 
for TR=1:TRs
    imagesc(imagesNew(:,:,TR), [0 1]);
    drawnow;
    WaitSecs(0.1)
end
    
images=imagesNew;
save('Stimuli/images_pRF_average','images');
 
stimulus.seq=(1:TRs)';
save('Stimuli/params_pRF_average','params', 'stimulus');
    
    
    
    
    
    
    
    
    
    
