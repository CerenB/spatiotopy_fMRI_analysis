function locate_RF

% this funtion is for calculating the location of RFs across all the voxels
% in the brain

% /Users/cerenbattal/Documents/MATLAB/vistasoft-master/mrBOLD/Analysis/retinotopyModel/rfGaussian2d.m
% function which takes: 
%RF = rfGaussian2d(X,Y,sigmaMajor,sigmaMinor,theta, x0,y0);

%    X,Y        : Sample positions in deg
%    sigmaMajor : standard deviation longest direction
%    sigmaMinor : standard deviation shortest direction
%                 [default: sigmaMinor = sigmaMajor]
%    theta      : angle of sigmaMajor (radians, 0=vertical)
%                 [default = 0];
%    x0         : x-coordinate of center of RF [default = 0];
%    y0         : y-coordinate of center of RF [default = 0];

% Allow sigma, x,y to be a matrix so that the final output will be
% size(X,1) by size(x0,2). This way we can make many RFs at the same time.


% example : RF = rfGaussian2d(X,Y,2,2,0,5,7);
% in this case x0 = 5, y0=7 in degrees so it could be around stimulus2

% it takes already calculated pRF models from:
path = '/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/EB/ChSc/Gray/Averages';
% office PC
%path = '/Cerens_files/fMRI/Processed/Spatio_pRF/EB/AnBa/Gray/Averages_all_runs';

cd(path);
m = load('ONEGAUSSIAN_wholebrain-fFit-fFit-fFit.mat');


% then take:
x0 = m.model{1}.x0; % matrix contain preferred x location per voxel
y0 = m.model{1}.y0; % matrix contain preferred y location per voxel
sigmaMajor =  m.model{1}.sigma.major;
sigmaMinor = sigmaMajor; % sigma.minor should be equal to major
theta = 0;
% this is my stimuli - grid
% made from images.mat
X = m.params.analysis.X;
Y = m.params.analysis.Y;

%check point for stimuli space
%figure; plot(X,Y,'.')
tic

% find RF locationsfor every voxels = for loop across voxels
for i = 1:length(x0)
    
    RF(:,i) = rfGaussian2d(X,Y,sigmaMajor(i),sigmaMinor(i),theta, x0(i),y0(i));
    
end


% check point
% now I want to see the overlap of RF with each stimulus (1:8)
% k=1;
% figure(100); plot3(X,Y,RF(:,k),'.')



% 1st Q: how can I know with which stimulus it's overlapping
% within a voxel ,make theta  from each X,Y
% take RFs from theta 0- 45 an assign that into stimulus1
% take RFs from theta 45- 90 an assign that into stimulus2
% do this for 8 stimuli and sum all the RF heights and divide in into
% maximum
% to see if there's preferred stimuli
%theta = (cart2pol(X,Y)./pi).*180;
theta = rad2deg(cart2pol(X,Y));

%theta itself has -178deg, which I find it confusing so here is conversion
%to 0 to 360 deg, instead of 0 180 -178
theta_positive = theta;
for i=1:length(theta_positive) 
    if theta_positive(i)<0 
        theta_positive(i)=360+theta_positive(i);
    end
end
%Z = [X,Y, theta];
stim =[];
limdeg = 22.5;

for ith = 1:length(theta_positive)
    if theta_positive(ith) >=limdeg && theta_positive(ith) <45+limdeg
        stim(ith) = 2;
    
    elseif theta_positive(ith) >=45+limdeg && theta_positive(ith) <90+limdeg
        stim(ith) = 1;
    
    elseif theta_positive(ith) >=90+limdeg && theta_positive(ith) <135+limdeg
        stim(ith) = 8;  
        
    elseif theta_positive(ith) >=135+limdeg && theta_positive(ith) <180+limdeg
        stim(ith) = 7;
        
    elseif theta_positive(ith) >=180+limdeg && theta_positive(ith) <225+limdeg
        stim(ith) = 6;
    
    elseif theta_positive(ith) >=225+limdeg && theta_positive(ith) <270+limdeg
        stim(ith) = 5;   
        
    elseif theta_positive(ith) >=270+limdeg && theta_positive(ith) <315+limdeg
        stim(ith) = 4; 
        
    elseif theta_positive(ith) >=315+limdeg  
        stim(ith) = 3; 
    elseif theta_positive(ith) <limdeg
        stim(ith) = 3; 
    end
    
end

stim = stim';
%check-point for stim is set right
figure;hist(stim,1:8) %should be equally distributed
%same idea of this: figure; hist(theta,-180:45:180);

% check the stim space is OK
ivox = 1;
Z = [X,Y, theta, stim, RF(:,ivox), theta_positive deg2rad(theta_positive)];
figure; plot3(Z(:,1),Z(:,2),Z(:,5),'.')
% figure; hist(pref_stim(1,:))
% figure; hist(pref_stim(1,:),1:8)
% figure; hist(pref_stim(2,:),1:8)

%ivox = 1;
% make a for loop for all the voxels
temp = [];
stim_RF = [];

for ivox = 1:length(RF)
    
    %create temp for a given voxel
    temp = RF(:,ivox);
    
    for istim = 1:8
        
        %find indices for each stimuli
        idx = find(stim==istim);
        
        % take RF(idx) sum & normalize
        %take 1 voxel's all RF heights & sum and divide e.g. stim1/sum(all RF)
        norm_rf = sum(temp(idx))/sum(temp); % each element / sum(idx)
        
        %save the normalized RF height into corresponding stimulus
        stim_RF(istim,ivox) = norm_rf;
        stim_RF_per(istim,ivox) = norm_rf*100;

    end
end

%% the rest is for findging for each voxel what is the preferred stimulus among those 8
% check for given voxel how is RF
ivox = 1;
figure; plot(stim_RF(:,ivox))
set(gca,'FontSize',14)

% 2nd Q: how much its overlapping = percentage
% if within  voxel, more than 12.5% RF height is there for more than 1
% stimuli, then write down the preferred stimulus
thres = .125;
count = 1;
count2 = 1;
pref8 =[]; pref4 =[]; % this is a check-point if they will not be created

for ivox =1:length(stim_RF)
    
    temp = stim_RF(:,ivox);
    
    
    ind = [find(temp>thres)]';
    max_id = find(temp== max(temp));
        
    if isnan(temp) % check-point for NaNs
        pref_stim(1,ivox)=0;
        pref_stim(2,ivox)=0;
        
        %keep the voxel index
        NaN_vx(count) = ivox;
        count = count +1;
        
    elseif length(max_id) >1 % check-point for 2 or more max values
        pref_stim(1,ivox)  = length(ind);
        pref_stim(2,ivox)  = 9; % 9 would indicate 2 max response
        
        %keep the voxel index
        pref8(count2) = ivox;
        count2 = count2 +1;
    else

        pref_stim(1,ivox)  = length(ind);
        pref_stim(2,ivox)  = max_id;
    
    end
end

pref_count = pref_stim(1,:);
pref_ori = pref_stim(2,:);
% 9 == responsive to all stimuli space equally.
% 0 == responsive to more than 3
count3 = 1;
for i=1:length(pref_count)
    if pref_count(i) >3 && pref_ori(i) <9
        pref_ori(i) =0;
        %keep the voxel index
        pref4(count3) = ivox;
        count3 = count3 +1;   
    end   
end

    
figure; hist(pref_ori(:),0:9);
showme = [pref_count; pref_ori];

% plot one voxel's preference 
% ivox = 12;
% figure; plot(stim_RF(:,ivox));

% insert if statement for if pref_num>3
% and the first one is not 2 times higher than second/third one
% put that to 0 to show preference is 0 pref_loc = 0

save('preference.mat','pref_ori','pref_count','thres','NaN_vx','pref8', 'pref4','stim_RF','theta_positive'); % add voxel indeces here

toc
[Results, extra] = calculate_sigma_mini(RF,path);

% make another preference map with different threshold
% when it's below threshold, add zeros?


% 3rd Q: amplitude


% example with Wietske:

% % for summing the images.mat
% cd ('/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/EB/AnBa/Stimuli');
% a = load('params_tr_average_r10.mat')
% a.original_stimulus
% ims = a.original_stimulus.images;
% imsavg = zeros([101 101]);
% for i = 1:160 imsavg = imsavg+ims(:,:,i); end
% figure; imagesc(imsavg)
% unique(imsavg)
% % it should contin 0 and 1s, that's it.


% % load fit. mat
% m = load('ONEGAUSSIAN_wholebrain-fFit')
% X = m.params.analysis.X;
% Y = m.params.analysis.Y;
% figure; plot(X,Y,'.')
% 
% %find where RF is:
% RF = rfGaussian2d(X,Y,2,2,0,5,7);
% 
% % to see the overlap with other stimuli
% figure; plot3(X,Y,RF,'.')
% 
% % look into your model 
% % the voxel numbers are there
% m.model{1}
% %look at your sigma (major/minor)
% m.model{1}.sigma
% 
% %plot the overlap/RF location - not sure if you needed that 
% figure; plot3(X,Y,RF,'.')
% %sum the RF in the particular stimulus (?)
% sum(RF(:))





end
