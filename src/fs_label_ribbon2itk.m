function fs_label_ribbon2itk


subject = 'DaPr';
group = 'SC';

pc = 1;


if pc == 2
    cd(sprintf('/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/Native_space',group,subject));
else
    cd(sprintf('/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/Native_space',group,subject));
end

infile = 'ribbon-in-rawavg.nii';
m = niftiRead(infile);

%% check point
% check that we have the expected values in the ribbon file
% relabelled = 'ribbon-in-rawavg_GM0_WM.nii';
% l = niftiRead(relabelled);
% vals_relabelled = sort(unique(l.data(:)));
% 
vals = sort(unique(m.data(:)));
if ~isequal(vals, [0 2 3 41 42]')
    warning('The values in the ribbon file - %s - do no match the expected values [2 3 41 42]. Proceeding to rounding...')
    m.data = round(m.data);
end
%vals = sort(unique(m.data(:)));


%% Convert freesurfer label values to itkGray label values
% We want to convert
%   Right GM:  42 => 0
%   Left GM:    3 => 0

m.data(m.data ==42) = 0;
m.data(m.data ==3) = 0;

%%write out the nifti
% m.fname = 'ribbon-in-rawavg_GM0.nii';
% writeFileNifti(m)

%%Now convert 
%%Left WM: 2 => 4
%%Right WM: 41 => 3
%infile = 'ribbon-in-rawavg_GM0.nii';
%m = niftiRead(infile);
m.data(m.data ==2) = 3;
m.data(m.data == 41) = 4;

% CSF trial - 22.10.2018
m.data(m.data == 40) = 1;

%% check 41 still exists or not
% vals_relabelled = sort(unique(m.data(:)));
% 
% a = 'aseg-in-rawavg.nii.gz';
% b = niftiRead(a);
% 
% vals_b = sort(unique(b.data(:)));

% write out the nifti
m.fname = 'ribbon-in-raw_relabelled.nii';
writeFileNifti(m)

%m = niftiRead(m.fname);

%% COMMENTED
% %   unlabeled:    0 => 1 (if fillWithCSF == 1)          
% 
% 
% % map the replacement values
% invals  = [0 3 2 41 42];
% outvals = [1 0 4  3  0];
% labels  = {'CSF', 'L GM', 'L WM', 'R WM', 'R GM'};
% 
% fprintf('\n\n****************\nConverting voxels....\n\n');
% for ii = 1:length(invals);
%     inds = m.data == invals(ii);
%     m.data(inds) = outvals(ii);
%     fprintf('Number of %s voxels \t= %d\n', labels{ii}, sum(inds(:)));
% end
% 
% 
% 
% 
% 
% %% try again - 17:07
% 
% infile = 'ribbon-in-rawavg_cb.nii';
% ni = niftiRead(infile);
% 
% % itkGray label values
% % We want to convert
% %   Left white:   2 => 3
% %   Left gray:    3 => 5
% %   Right white: 41 => 4
% %   Right gray:  42 => 6
% %   unlabeled:    0 => 0 (if fillWithCSF == 0) or 1 (if fillWithCSF == 1)          
% 
% 
% % check that we have the expected values in the ribbon file
% vals = sort(unique(ni.data(:)));
% if ~isequal(vals, [0 2 3 41 42]')
%     warning('The values in the ribbon file - %s - do no match the expected values [2 3 41 42]. Proceeding anyway...') %#ok<WNTAG>
% end
% 
% % map the replacement values
% invals  = [3 2 41 42];
% outvals = [5 3  4  6];
% labels  = {'L Gray', 'L White', 'R White', 'R Gray'};
% 
% fprintf('\n\n****************\nConverting voxels....\n\n');
% for ii = 1:4;
%     inds = ni.data == invals(ii);
%     ni.data(inds) = outvals(ii);
%     fprintf('Number of %s voxels \t= %d\n', labels{ii}, sum(inds(:)));
% end
% 
% 
% ni.data(ni.data == 0) = 1;
% 
% 
% % add now our criteria
% % GM -> 0
% % all unlabelled -> 1 
% 
% 
% % write out the nifti
% writeFileNifti(ni)

end