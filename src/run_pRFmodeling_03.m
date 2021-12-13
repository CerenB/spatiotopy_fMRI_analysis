
clear all;
close all;

pc = 2;
mrvistaPath = '/data2/spatiotopy/code/vistasoft';
subjectPath = '/data2/spatiotopy/raw/SC/AlSapilot';

if pc == 1
    mrvistaPath = '/Users/battal/Documents/MATLAB/vistasoft';
    subjectPath = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSapilot';

end
%add path mrvista
addpath(genpath(mrvistaPath));

% go to subject's folder
cd(subjectPath);


% 08.12.2021
rmMain([1 3],[],1,'model',{'one gaussian'},'hrf',...
    {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
    'matfilename','ONEGAUSSIAN_wholebrain', ...
    'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
    'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);
