function create_pRFparams_02(action)

% action == 1 prepares 1 averaged images.mat and params.mat files. 
% action == 2 prepares params file per run

% go back to examplar params:
% cd('/Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code');
% load('params_SSD_new.mat');
% load('images_SSD_new.mat');

% CB 18.10.2018 makes params.mat file for the pRF analysis
% CB 07.12.2021 general edit on 

labelForResponse = 0; % putting blank frames (e.g. frame#160) for 1-back response task
subject = 'AlSapilot';
group = 'SC';
runNb = 7; % DaZo has 8 runs

% set the paths
data = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/';
mainpath = fullfile(data,group,subject);

switch action
    
% create average image , stimulus - in mrVista style
% this part will not work with 9images - let's not run it now
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

% create params  for each run separately      
    case 2 
        
        for iRun = 1:runNb
            
            % load images
            matFileName = 'images_pRF';
            load(fullfile(mainpath,'Stimuli',matFileName), 'images');
            
            % save images into original_stimulus
            original_stimulus.images = images; %#ok<NODEF>

            % could be inserted 163, it is set to 160
            % later on these 3 images/frame is discarded in mrVista
            % preprocessing
            matFileName = [subject,'_logfile', num2str(iRun)];
            load(fullfile(mainpath, 'logfiles',matFileName),'stimOrder');
            
            % old way
            % frames = 1:160;
            
            % new way - 07.12.2021
            % read from logfile how the stim was presented
            frames = stimOrder;
            
            % replace zeros with label 9
            % images(:,:,9) would be with zeros
            frames(frames == 0) = 9;
            
            % mini-check point to assign response/button press to number 160 
            % 160 corresponds to "blank/zero image" in images.mat
            % we we label button press to "zero image".
            if labelForResponse == 1

                for iStim = 3:160

                    if stimOrder(iStim) == stimOrder(iStim-2) && stimOrder(iStim)~=9
                        frames(iStim) = 9;
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
            load(fullfile(mainpath, 'Stimuli','cmap'),'cmap');
            stimulus.cmap = cmap;
            stimulus.seq = frames;
            stimulus.seqtiming = seqTiming;
            
            %% save files
            if labelForResponse == 1
                newMatFile = ['params_tr_run', num2str(iRun),'_response.mat'];
            else
                newMatFile = ['params_tr_run', num2str(iRun),'.mat'];
            end
            save(fullfile(mainpath, 'Stimuli',newMatFile), 'original_stimulus', 'params','stimulus');

            % visualisation
            figure; plot(stimulus.seq)
            
%             for i = 1:160
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
