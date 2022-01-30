
clear all;
close all;

subject = 'AnTo';

pc = 2;
mrvistaPath = '/data2/spatiotopy/code/vistasoft';
subjectPath = ['/data2/spatiotopy/raw/SC/',subject];

if pc == 1
    mrvistaPath = '/Users/battal/Documents/MATLAB/vistasoft';
    subjectPath = ['/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/SC/', subject];

end

%add path mrvista
addpath(genpath(mrvistaPath));

% go to subject's folder
cd(subjectPath);

% AnTo - individual runs
% rmMain([1 3],[],1,'model',{'one gaussian'},'hrf',...
%     {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
%     'matfilename','ONEGAUSSIAN_wholebrain', ...
%     'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
%     'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% AnTo - odd runs
rmMain([1 7],[],1,'model',{'one gaussian'},'hrf',...
    {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
    'matfilename','ONEGAUSSIAN_wholebrain_odd', ...
    'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
    'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% AnTo - even runs
rmMain([1 8],[],1,'model',{'one gaussian'},'hrf',...
    {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
    'matfilename','ONEGAUSSIAN_wholebrain_even', ...
    'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
    'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% % DaCe - not run yet
% rmMain([1 5],[],1,'model',{'one gaussian'},'hrf',...
%     {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
%     'matfilename','ONEGAUSSIAN_wholebrain', ...
%     'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
%     'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, ...
%     'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% % DaBe - averaged runs done
% rmMain([1 5],[],1,'model',{'one gaussian'},'hrf',...
%     {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
%     'matfilename','ONEGAUSSIAN_wholebrain', ...
%     'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
%     'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% % DaBe - the ind runs - cannot run, no calculation for tSeries in Gray/MotionComp
% rmMain([1 3],[],1,'model',{'one gaussian'},'hrf',...
%     {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
%     'matfilename','ONEGAUSSIAN_wholebrain', ...
%     'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
%     'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% % AlSa  - ran both individual + averaged 
% rmMain([1 7],[],1,'model',{'one gaussian'},'hrf',...
%     {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
%     'matfilename','ONEGAUSSIAN_wholebrain', ...
%     'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
%     'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);

% % AnTo - ran averaged runs
% rmMain([1 6],[],1,'model',{'one gaussian'},'hrf',...
%     {'t',[5.4000 5.2000 10.8000 7.3500 0.35000]},...
%     'matfilename','ONEGAUSSIAN_wholebrain', ...
%     'stimx', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], 'stimy', [-1 -1/sqrt(2) 0 1/sqrt(2) 1], ...
%     'minrf', 0.05, 'maxrf', 2, 'numbersigmas', 79, 'relativeGridStep', 1, 'coarsetofine',0, 'coarsesample',0);
