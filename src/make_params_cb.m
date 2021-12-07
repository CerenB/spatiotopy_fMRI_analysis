function make_params_cb(action)

% action == 1 prepares 1 averaged images.mat and params.mat files. 
% action ==2 prepares params file per run


% makes params.mat file for the pRF analysis
% CB 18.10.2018

% go back to examplar params:
% cd('/Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code');
% load('params_SSD_new.mat');
% load('images_SSD_new.mat');

blankimg = 1; % putting blank frames (e.g. frame#160) for 1-back response task
subject = 'AlSapilot';
group = 'SC';
irun = 7; %did it for 7 runs now, consider for 8 for DaZo

%% set the paths
mainpath = sprintf('/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/',group,subject);
cd(mainpath);

% radius
r = 1;

switch action
    
    case 1 %% TO CREATE average images.mat to make 1 images_average.mat
%% set IMAGES.MAT
        ims = 0;
        
        for irun =1:irun
            temp = load(sprintf('Stimuli/images_pRF_run%d_r%d.mat',irun,r));
            %load(sprintf('Stimuli_r%d/images_pRF_run%d_r%d.mat',r,irun,r));
            
            ims = [ims + temp.images];
            
        end
        
        images = ims./irun;
        save(sprintf('Stimuli/images_pRF_average_r%d.mat',r),'images');
        
%% set PARAMS.MAT
        
        original_stimulus.images =images;
        seq = 1:160;
        original_stimulus.seq =seq;
        
        %% timing
        seqtiming = 0:2.5:398;
        original_stimulus.seqtiming =seqtiming;
        
        %% params
        tr = 2.5;
        frameperiod = 2.5;
        params.tr = tr;
        params.frameperiod = frameperiod;
        
        %% stimulus
        % cmap
        load('Stimuli/cmap.mat');
        stimulus.cmap = cmap;
        stimulus.seq = seq;
        stimulus.seqtiming = seqtiming;
        
        save(sprintf('Stimuli/params_tr_average_r%d.mat',r), 'original_stimulus', 'params','stimulus');

        
    case 2 %% TO CREATE IMAGES AND PARAMS FOR EACH RUN SEPARATELY
        
        for irun = 1:irun
            
            load(sprintf('Stimuli/images_pRF_run%d_r%d.mat',irun,r));
            %load(sprintf('%slogfiles/%s_logfile%d_250ms.mat',mainpath,subject,irun));
            
            %% original_stimulus
            original_stimulus.images = images;
            
            %% seq = is sequence to take from images.mat
            
            seq = 1:160;
            % could be inserted 163, it was 160 19.10.2018, and later on these 3 images/frames could be discarded
            
            % mini-check point to put 160 (black -0 image in images.mat)
            % for the response pressed 1-back task
            
            load(sprintf('%slogfiles/%s_logfile%d.mat',mainpath,subject,irun));
            if blankimg == 1
                
                for jj = 3: 160
                    if stim_tr(jj) == stim_tr(jj-2)
                        seq(jj) = 160;
                    end
                end
                
            end
            
            
            original_stimulus.seq =seq;
            
            %% timing
            seqtiming = 0:2.5:398;
            original_stimulus.seqtiming =seqtiming;
            
            %% params
            tr = 2.5;
            frameperiod = 2.5; %%%%%%%% ?
            params.tr = tr;
            params.frameperiod = frameperiod;
            
            %% stimulus
            % cmap
            load('Stimuli/cmap.mat');
            stimulus.cmap = cmap;
            stimulus.seq = seq;
            stimulus.seqtiming = seqtiming;
            
            %% save files
            if blankimg == 0
                save(sprintf('Stimuli/params_tr_run%d_withresponse.mat',irun), 'original_stimulus', 'params','stimulus');
            else
                save(sprintf('Stimuli/params_tr_run%d_r%d.mat',irun,r), 'original_stimulus', 'params','stimulus');
                %save(sprintf('Stimuli_r%d/params_tr_run%d_r%d.mat',r,irun,r), 'original_stimulus', 'params','stimulus');
                
            end
            
            
%             for i = 1:160 %1:2:160
%                     figure(100);
%                     imagesc(images(:,:,seq(i)));
%                     colormap gray
%                     axis square
%                     drawnow
%                     pause(.5)
%             end
            
        end
        
        
end

end
% %% try - with real time
% %though we only have every 5 s - every stimuli onset recordings
% load(sprintf('%slogfiles/fMRI/AlSa_fMRI_pRF_%d.mat',mainpath,irun));
% TR = 2.5;
% temp =[];
% onset5s = onset(:,1);
% 
% for k = 1: length(onset5s)
%     
%     
%     if k ==49 || k == 103 || k ==155
%         
%         for kk = 1:5
%             temp = [temp onset5s(k-1)+TR];
%         end
%         
%     else
%         
%         if mod(k) ==1
%             temp = [temp onset5s(k)];
%         elseif mod(k) ==0
%             temp = [temp (onset5s(k-1)+TR)];
%         end
%         
%     end
%     
% end