function control_sigma_output(Results,extra)
% control point for the plots vs. RF values 

% %gets the values 
ivox = extra.plot_vox_idx(2);

NF = fieldnames(Results); 
% %a.stim_RF(reorder_stim,ivox) % shows 0 - 2pi orientation
extra.RF.stim_RF(:,ivox); % show 1:8 orientation of our stim space
% 
aa(1,:) = NF';
for kk=1:length(NF)
    
    aa{2,kk}= [Results.(NF{kk})(ivox)];
end

% 
% % NOTES:
% % 1.
% % according to the plots, the w vs. w_all does not change much. But I think
% % overall the fits are neverthless not great. Seems that the coefficient, A
% % should be always a bit more smaller. The fits follow the Rf points but
% % always a bit "higher" in y scale
% % 2. 
% % when kappa goes Inf, there's still mu. Inf in kappa or NaN would be
% indicators of no fit. 
% % 3. Still A (constant) is higher than it should and A is a function of
% kappa. And kappa is related to sigma. So... maybe it needs some repair.
% Or kappa << meaning sigma >>, meaning no selectivity. 

% % THINK about how to calculate themaximum likelyhood + minimising the
% residuals/errors, maybe we can improve the fit

% % cb 18.02.2019

%% make sigmas sigma^2 = 1/kappa
sigma = sqrt(1./Results.kappa); %all_voxel_data.kappa
sigma_w = sqrt(1./Results.kappa_w); %all_voxel_data.kappa_w
% sigma_w_all = sqrt(1./Results.kappa_w_all); %all_voxel_data.kappa_w_all
% 
Results.sigma = sigma;
Results.sigma_w = sigma_w;
% all_voxel_data.sigma_w_all = sigma_w_all;


save('Results_RF_only_sigma.mat','extra','Results');

%% upload weighted_mu and weighted_sigma to calculated pRF VOLUME maps
sub= 'AlSa'; %AlSa
path = ['/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/SC/',sub,'/Gray/Averages'];
% office PC
%path = '/Cerens_files/fMRI/Processed/Spatio_pRF/EB/AnBa/Gray/Averages_all_runs';

%cd(path);
%load('ONEGAUSSIAN_wholebrain-fFit-fFit-fFit.mat');
load('Gray/Averages/Results_RF_only_sigma.mat')
% eccentricity == location map
% mu_w is in radians, between -+pi
angle_mean_pref = rad2deg(Results.mu_w);
min(angle_mean_pref)
max(angle_mean_pref)

%% option b - without conversion to 0 360 but to -pi to pi
% max(Results.mu_w)
% min(Results.mu_w)
% VOLUME{1,1}.ph{1,1} = Results.mu_w;  
% VOLUME{1,1}.map{1,1} = real(Results.sigma_w);
%%
%let's convert it into 0 to 2pi
for i=1:length(angle_mean_pref) 
    if angle_mean_pref(i)<0 
        angle_mean_pref(i)=360+angle_mean_pref(i);
    end
end


%let's scale it down from 360deg to 14 degrees -- mrvista crashes with [0 360] color map scale 
%angle_mean_pref = (angle_mean_pref * 14)/360;

% .map is eccentricity == location in visual degrees 
VOLUME{1,1}.map{1,1} = angle_mean_pref;  

N = length(angle_mean_pref);
theta = 0:pi/4:7*pi/4;
alpha = linspace(0, theta(end), N)';
figure;scatter(alpha,angle_mean_pref);
%figure;hist(angle_mean_pref,[0:45:360])
figure;hist(angle_mean_pref,[0:2.5:14])


% amplitude == pRf size == sigma map
VOLUME{1,1}.amp{1,1} = real(Results.sigma_w); % .map is pRF size, sigma itself. no units. 
figure; plot(real(Results.sigma_w),'.');
ylim([0 7])

maxnum = max(real(Results.sigma_w));
minnum= min(real(Results.sigma_w));
numIntervals = 1000;
interval_w = (maxnum - minnum)/numIntervals;

x = [0:interval_w:maxnum];
y = real(Results.sigma_w);
ncount = histc(y,x);
relativefreq = ncount/length(y);

bar(x-interval_w/2, relativefreq,1)
xlim([min(x),max(x)])


%figure;histogram(real(Results.sigma_w),[0:interval_w:maxnum])



%% organizing/concatenating the 3 Results.mat file below
% % this is organizing DaCe's sigma values across all the voxels
% % cb: 30.01.2019 needed to run calculate_sigma.m for multiple times, thus
% % the three Results_RF had to be merged. Hence, the stupid "workinprogress"
% % script.
% 
% %load('Concatenated_Results_RF_sigma_all_till29217.mat') %brings
% %New_Results variabl/structure (on 33 - all fields)
% 
% %load('Results_RF_only_sigma_start3787.mat') % this one brings all voxels -
% %3787 values/structure on only 10 fields
% 
% limitfields = fieldnames(Results);
% 
% %what happens: after running the below, the structure becomes better, but
% %all the Inf values in mu_ll (confidence interval) got deleted. The rest
% %(e.g. nan values) are kept.
% for i =1:10
%     data1till29217.(limitfields{i})= [New_Results.(limitfields{i})];
% end
% 
% 
% nonemptyResults = [Results(3787:end)];
% 
% for i =1:10
%     data3787tillend.(limitfields{i})= [nonemptyResults.(limitfields{i})];
% end
% 
% save('results_rf_onlysigma_10fields','data1till29217','data3787tillend');
% 
% %% now combine and have 1:all voxels
% 
% limitfields = fieldnames(data1till29217);
% for i=1:10
%     all_voxel_data.(limitfields{i}) = [data1till29217.(limitfields{i})(1:3786), data3787tillend.(limitfields{i})];
% end
% 
% 


% % colormap attempt
hmap(1:256,1) = linspace(0,1,256);
hmap(:,[2 3]) = 0.7; %brightness
huemap = hsv2rgb(hmap);
figure; colormap(huemap)


end