
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
rmMain([1 3],[],5,'model',{'one gaussian'},'hrf',{'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},'matfilename','ONEGAUSSIAN_wholebrain', 'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1]);
