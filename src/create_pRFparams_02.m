function create_pRFparams_02(action)

% action == 1 prepares 1 averaged images.mat and params.mat files for each run 
% action == 2 prepares params/stimulus.seq for average runs

% go back to examplar params:
% cd('/Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code');
% load('params_SSD_new.mat');
% load('images_SSD_new.mat');

% CB 18.10.2018 makes params.mat file for the pRF analysis
% CB 07.12.2021 general edit on 

%% set the paths
subject = 'DaCe';
group = 'SC';
data = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/';
mainpath = fullfile(data,group,subject);

%% averageAllRun, averageOddRun, averageEvenRun
averageType = 'All'; %'Even', 'Odd', 'All'

% average across runs, or even-odd runs?
runNb = 7; % DaZo has 8 runs

%% timing parameters
tr = 2.5;
frameperiod = tr;
seqTiming = 0:2.5:398;
        
% putting blank frames (e.g. frame#160) for 1-back response task
labelForResponse = 0; 
% visualise the stimulus space?
visualise = 0;

%% let's start
switch action
    
    % create individual params(stimulus.seq) file by looking at logfiles
    case 1
        
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
            
            % timing
            original_stimulus.seqtiming = seqTiming;
            original_stimulus.seq = frames;
            
            % params
            params.tr = tr;
            params.frameperiod = frameperiod;
            
            % stimulus
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
        

        % create averaged images according to the individual params(stimulus.seq)
    case 2
        
        volumeNb = 160;
        
        % find the averaging order
        if strcmp(averageType, 'Even')
            averageOrder = 2:2:7;
        elseif strcmp(averageType, 'Odd')
            averageOrder = 1:2:7;
        elseif strcmp(averageType, 'All')
            averageOrder = 1:runNb;
            
        end
        
        % loading image order == params (stimulus.seq)
        for iRun = 1:runNb
            
            matFileName =  ['params_tr_run',num2str(iRun)];
            temp = load(fullfile(mainpath,'Stimuli', matFileName), 'stimulus');
            
            % load stimuli order across runs
            stimOrder(:, iRun) = temp.stimulus.seq;
        end
        
        % load the images
        load(fullfile(mainpath,'Stimuli', 'images_pRF.mat'), 'images');
        
        % preallocate new images
        imagesNew = zeros([size(images, 1), size(images, 2), volumeNb]);
        
        % sum the images according to stimulus order across runs
        for iRun = averageOrder
            for iVol=1:volumeNb
                imagesNew(:,:,iVol) = imagesNew(:,:,iVol)+...
                                    images(:,:,stimOrder(iVol,iRun));
            end
        end
        
        %normalise to 1
        imagesNew = imagesNew./max(imagesNew(:));
        
        % visualisation
        if visualise
            figure;
            for iVol = 1:volumeNb
                imagesc(imagesNew(:,:,iVol), [0 1]);
                drawnow;
                WaitSecs(0.1)
            end
        end
        
        % save averagd images
        images = imagesNew;
        save(fullfile(mainpath,'Stimuli','images_pRF_average'),'images');
        
        % not sure if we need original_stimulus
        original_stimulus.images = images;
        original_stimulus.seqtiming = seqTiming;
        
        % params
        params.tr = tr;
        params.frameperiod = frameperiod;
        
        % cmap
        load(fullfile(mainpath, 'Stimuli','cmap'),'cmap');
        stimulus.cmap = cmap;
        
        %stimulus
        % averaging params means just save the same params in mrVista output
        % structure - from 1:totVolumes in column
        stimulus.seq=(1:volumeNb)';
        stimulus.seqtiming = seqTiming;
        
        % save 
        save(fullfile(mainpath,'Stimuli',['params_pRF_average',averageType]), ...
                        'stimulus', 'params', 'original_stimulus');
       
end

end
