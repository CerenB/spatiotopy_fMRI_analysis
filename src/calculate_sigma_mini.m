function [Results,extra] = calculate_sigma_mini(RF,path)

%calculate_sigma_mini(RF)

% this function first calls RF = calculate_RF_only function to have RFs
% and then uploads already other parameters from
% preference.mat files to
% calculate the sigma/mu by fitting a von mises function to the 8 position RFs.
% cb 18.02.2019, different point from calculate_sigma.m is it does not go
% through 1300 RF points.

% it takes already calculated pRF models from:
% PC at LLN
%path = '/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/EB/AnDe_nonFS_anatomy/Gray/Averages';
%Ceren's laptop
%path = '/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSa/Gray/Averages';

cd(path);
a = load('preference.mat');

%% calculate VM parameters

%% calculate all RFs
% CHANGE ME AGAIN
%RF = calculate_RF_only(path); %this is calling the function to calculate all the RFs and takes couple of seconds to run

%%
theta = 0:pi/4:7*pi/4;
%reorder the stim_RF according to the angle 0:45:360. Now it was from
%stim1:8 (90, 45, 0, 315, ...)
reorder_stim = [3 2 1 8:-1:4];

%plot some random ivox values, to observe the data
plot_when = randi(size(RF,2),10,1);

% nan indices
[nanrow nan_col] = find(isnan(RF));
nan_vox_id = unique(nan_col);
x=nan;

%%
tic
for ivox=1:length(RF)
    
    w = a.stim_RF(reorder_stim,ivox);
    
    %control point for nans
    if isnan(w)
        fn = fieldnames(Results);
        
        for kk=1:length(fn)
            Results.(fn{kk})(ivox)=x;
        end
        continue
    end
    %% calculate von Mises function parameters
    % initially it has w but the rest of the calculation is not good.
    
    % only giving our angles (45deg) and the RF (as w)
    [thetahat, kappa] = circ_vmpar(theta',w); %theta and theta' produce same results
    
    %calculte r - resultant vector length
    alpha = theta'; %somehow it doesn't like theta in rows
    % spacing of bins
    dori = diff(theta(1:2));
    r = circ_r(alpha, w,dori);

    
    % to plot VM function with the thetahat & kappa already created
    alpha = linspace(0, theta(end), 101)';
    alpha = alpha(1:end-1);
    
    % evaluate pdf
    % Computes the circular von Mises pdf with preferred direction thetahat
    % and concentration kappa at each of the angles in alpha
    %density function
    %[p alpha] = circ_vmpdf(alpha, thetahat, kappa)
    A = 1/(2*pi*besseli(0,kappa));
    p = A * exp(kappa*cos(alpha-thetahat));
    func = exp(kappa*cos(alpha-thetahat));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        % 8 weight
        %instead of weight, let's "convert" weight into repmat(theta) to see if
        %something will change
        w1000 = round(w*1000);
        temp2 = [];
        for idx = 1:8
            
            if isnan(w1000(idx))
                break
            else
                theta_w =repmat(theta(idx),w1000(idx),1);
                temp2 = [temp2; theta_w];
            end
        end
        alpha_w = temp2;
        alpha_w_deg = rad2deg(alpha_w);
        
        % save alpha_w for Rstudio
        %save('alpha_w','alpha_w','alpha_w_deg');
        % R output is (for a given ivox = 30500)
        % mle.vonmises(x = data$x)
        % mu: -2.254  ( 0.0105 )
        % kappa: 9.586  ( 0.4158 )
        %definitely the same one that matlab calculates below
        
        
        %calculate von Mises function parameters for weighted angles
        [thetahat_w, kappa_w] = circ_vmpar(alpha_w);
        
        %calculate weighted r - same result
        rw = circ_r(alpha_w);
        %rw = circ_r(alpha_w,[],dori);
        
        %calculate weighted variance
        Sw = circ_var(alpha_w); % variance is big S = 1-r
        % S = circ_var(alpha_w,[],[],dori) %crashes
        
        %skewness
        [b, b0] = circ_skewness(alpha_w);
        
        %kurtosis % is not zero, means it's not really mises function shaped
        [k k0] = circ_kurtosis(alpha_w);
        
        %uniformity test Rayleigh test, uniformity assumes all values round the
        %circle are equally likely
        %- reject the null H0 'The population is distributed uniformly around the circle'
        p_rayleigh = circ_rtest(alpha_w);
        p_rao = circ_raotest(alpha_w);
        
        %a general confidence interval for theta
        [mu_bar, ulw, llw] = circ_mean(alpha_w); %mu_bar == thetahat_w
        %2nd way
        d = circ_confmean(alpha_w, 0.05);
        lc = thetahat - d; %lower limit
        uc = thetahat + d; %upper limit
        
        
        % Computes the circular von Mises pdf with preferred direction thetahat
        % and concentration kappa at each of the angles in alpha
        %density function
        %[p alpha] = circ_vmpdf(alpha, thetahat, kappa)
        A_w = 1/(2*pi*besseli(0,kappa_w));
        p_w = A_w * exp(kappa_w*cos(alpha-thetahat_w));
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

    %% space for catch/try
        catch ME
        switch ME.identifier
            
            case 'MATLAB:repmat:invalidReplications'
                warning('repmat failed due to NaN. Assigning ivox values to NaN.');
                x=nan;
                fn = fieldnames(Results);
                %r = cell2struct(repmat({x}, length(fn), 1), fn, 1);
                
                for kk=1:length(fn)
                    Results.(fn{kk})(ivox)=x;
                end
                
            otherwise
                rethrow(ME)
        end
    end
    %% save into a structure
    
    %let's save struture differently cb: 15.02.2019
    %8 theta with w argument
    Results.mu(ivox) = thetahat;
    % Results(ivox).mu_ul = ul;
    % Results(ivox).mu_ll = ll;
    Results.kappa(ivox) = kappa;
    
    
    % 8 theta weight is distributed
    Results.mu_w(ivox) = thetahat_w;
    Results.mu_ulw(ivox) = ulw;
    Results.mu_llw(ivox) = llw;
    Results.kappa_w(ivox) = kappa_w;

    %more parameters for 8point weighted fit
    Results.r(ivox) = r;
    Results.rw(ivox) = rw;
    Results.Sw(ivox) = Sw;
    
    Results.b(ivox) = b;
    Results.b0(ivox) = b0;
    Results.k(ivox) = k;
    Results.k0(ivox) = k0;

    
    %% plot calculated parameters
    % pick random 40numbers from 1 to size(RF,2)
    if ismember(ivox,plot_when)
        
        %%%%%%%%%%%%%%%insert 1300 point calculation %%%%%%%%%%%%%%%%%%%%
        %here so plots can be made for comparison
        
        
        % make RF(:,ivox) as a weight of that theta
        % do not sum up the theta into 8 angles (0:pi/4:2pi) but make
        % repmat (RF(idx,ivox),ones) * theta
        theta_rad = deg2rad(a.theta_positive); % this is same across voxels and subjects
        all_theta_w =[];
        all_theta_rep =[];
        temp_theta =[];
        
        %create temp for a given voxel
        temp = RF(:,ivox);
        
        for i =1:length(temp)
            
            if isnan(temp(i)) || temp(i) ==0
                break
            else
                num_repmat = round((temp(i)/sum(temp)) * 100000);
                all_theta_rep =repmat(theta_rad(i),num_repmat,1);
                temp_theta = [temp_theta ;all_theta_rep];
            end
        end
        
        all_theta_w = temp_theta;
        
        %calculate the parameteres of vm
        [all_thetahat_w, all_kappa_w] = circ_vmpar(all_theta_w);
        all_A_w = 1/(2*pi*besseli(0,all_kappa_w));
        all_p_w = all_A_w * exp(all_kappa_w*cos(alpha-all_thetahat_w));
        all_func_w = exp(all_kappa_w*cos(alpha-all_thetahat_w));
        
        
        %%%%%%%%%%%%%%plot our angle and RF(:,ivox) as w %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        figure; plot(theta,w)
        xticks([0 pi/4 pi/2 (3*pi)/4 pi (5*pi)/4 (3*pi)/2 (7*pi)/4])
        xticklabels({'2\pi','{\pi}/{4}', '{\pi}/{2} ', '3{\pi}/{4}','\pi','5{\pi}/{4}','3\pi/{2}','7{\pi}/{4}'})  %
        xlabel('stimuli')
        ylabel('RF')
        title(sprintf('vox %d RF',ivox))
        hold on;
        
        
        % add plot of VM function - to see where is our values vs. function
        plot(theta,w,'ro',alpha,p,'b-',alpha,func,'g-',alpha,A,'p-');
        %plot(theta,w,'ro')
        %plot(alpha,p,'b-')
        %plot(alpha,A,'p-')
        hold on;
        
        % add plot weighted theta(alpha) -- now no w, but 8w is embedded into theta
        % by using repmat
        plot(alpha,p_w,'m-',alpha,A_w,'y-');
        hold on;
        % plot(theta_rad,temp/sum(temp),'c.'); stupid idea because it's not
        % normalized
        
        % add plot of 1300w embedded into theta by using repmat (1300 == all the
        % sampled positions of RF)
        plot(alpha,all_p_w,'k-',alpha,all_func_w,'c-',alpha,all_A_w,'p-');
        ylim([0 2])
        
        % save the output
        if ~exist(fullfile(path,'figures'),'dir')
            mkdir('figures')
        end
        
        %not sure we need to save these plots...
        saveas(gcf,sprintf('figures/RF_Vox%d_fit',ivox))
        
        
        % Let's compare 1300w makes sense or we are ok with 8w embedding
        % plot alpha_w vs. all_alpha_w
        figure
        suptitle(sprintf('RF, vox = %d\n 8point-weighted vs. 1300point-weighted\n',ivox))
        
        subplot(2,2,1)
        circ_plot(alpha_w,'pretty','bo',true,'linewidth',2,'color','r'),
        
        subplot(2,2,3)
        circ_plot(alpha_w,'hist',[],20,true,true,'linewidth',2,'color','r')
        
        subplot(2,2,2)
        circ_plot(all_theta_w,'pretty','bo',true,'linewidth',2,'color','r'),
        
        subplot(2,2,4)
        circ_plot(all_theta_w,'hist',[],30,true,true,'linewidth',2,'color','r')
        
        
        % save the output
        saveas(gcf,sprintf('figures/Vox%d_weightcomparison',ivox))
        

    end
    
    if mod(ivox,2500)==0
        fprintf('voxel = %d, computation on going\n',ivox);
    end
end

toc

%add last bits to save into structure
extra.plot_vox_idx = plot_when;
extra.RF = a;
extra.nan_vox_idx = nan_vox_id;

%save results
save('Results_RF_only_sigma','Results','extra');


% if you want to investigate the plots with RF values:
% control_sigma_output(Results, extra)

end