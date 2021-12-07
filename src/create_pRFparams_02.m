function create_pRFparams_02(action)

% action == 1 prepares 1 averaged images.mat and params.mat files. 
% action == 2 prepares params file per run

% go back to examplar params:
% cd('/Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code');
% load('params_SSD_new.mat');
% load('images_SSD_new.mat');

% CB 18.10.2018 makes params.mat file for the pRF analysis
% CB 07.12.2021 general edit on 



blankimg = 1; % putting blank frames (e.g. frame#160) for 1-back response task
subject = 'AlSapilot';
group = 'SC';
runNb = 7; % DaZo has 8 runs

% set the paths
data = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/';
mainpath = fullfile(data,group,subject);

switch action
    
% create average image and params - in mrVista style
    case 1
        
        ims = 0;
        for iRun = 1:runNb
            
            matFileName =  ['images_pRF_run',num2str(iRun)];
            temp = load(fullfile(mainpath,'Stimuli', matFileName), 'images');
            
            % average images across runs
            ims = ims + temp.images;
            
        end
        
        % save averaged images
        images = ims./runNb;
        newMatFile = 'images_pRF_average';
        save(fullfile(mainpath, 'Stimuli',newMatFile),'images');
        

        % original stimulus save it in - mrVista style
        original_stimulus.images = images;
        
        % seq = is sequence to take from images.mat
        frames = 1:160;
        original_stimulus.seq = frames;
        
        %% timing
        seqTiming = 0:2.5:398;
        original_stimulus.seqtiming = seqTiming;
        
        %% params
        tr = 2.5;
        frameperiod = 2.5;
        params.tr = tr;
        params.frameperiod = frameperiod;
        
        %% stimulus - mrVista style
        % load cmap for color code later on
        stimulus.cmap = load(fullfile(mainpath,'Stimuli','cmap.mat'), 'cmap');
        stimulus.seq = frames;
        stimulus.seqtiming = seqTiming;
        
        newMatFile = 'params_tr_average.mat';
        save(fullfile(mainpath,'Stimuli',newMatFile), 'original_stimulus', 'params','stimulus');

% create average image and params  for each run separately      
    case 2 
        
        for runNb = 1:runNb
            
            % load images
            matFileName = [images_pRF_run', num2str(runNb), '.mat'];
            load(fullfile(mainpath,'Stimuli',matFileName), 'images');
            
            % save images into original_stimulus
            original_stimulus.images = images; %#ok<NODEF>

            % could be inserted 163, it was 160 19.10.2018, 
            % and later on these 3 images/frames could be discarded
            frames = 1:160;
            
            % mini-check point to put 160 (black -0 image in images.mat)
            % for the response pressed 1-back task
            load(sprintf('%slogfiles/%s_logfile%d.mat',mainpath,subject,runNb));
            if blankimg == 1
            
            for jj = 3:160
                if stim_tr(jj) == stim_tr(jj-2)
                    frames(jj) = 160;
                end
            end
            
            end
            
            
            original_stimulus.seq = frames;
            
            %% timing
            seqTiming = 0:2.5:398;
            original_stimulus.seqtiming = seqTiming;
            
            %% params
            tr = 2.5;
            frameperiod = 2.5;
            params.tr = tr;
            params.frameperiod = frameperiod;
            
            %% stimulus
            % cmap
            load('Stimuli/cmap.mat');
            stimulus.cmap = cmap;
            stimulus.seq = frames;
            stimulus.seqtiming = seqTiming;
            
            %% save files
            if blankimg == 0
                save(sprintf('Stimuli/params_tr_run%d_withresponse.mat',runNb), 'original_stimulus', 'params','stimulus');
            else
                save(sprintf('Stimuli/params_tr_run%d.mat',runNb), 'original_stimulus', 'params','stimulus');
                
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
