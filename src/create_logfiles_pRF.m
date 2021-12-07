function create_logfiles_pRF(action)
%cb edited on 16.10.2018 
% this function created logfiles for pRF mrVista analysis.
% for now it needs to be in the same folder as the .mat files.
% for now, it only makes TR -- condition onset files
% later on actualy time (in seconds) ca nbe added)

% action ==1 only logfiles - with TR
% action ==2 creates stimuli space across time -- no need - look at script, for TR stepsize:
% makeWedge_cb.m /Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code
% for 0.25s stepsize is below


% cb 27.02.2019
% making logfiles - fMRI and Stimuli folders. 
% transfering logfiles from spatiotopy_cer to fMRI 

% cb 07.12.2021
% general edit 

%%
subject = 'AlSapilot';
group = 'SC'; 

data = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/';
mainpath = fullfile(data,group,subject);
cd(mainpath);

gap = 12.5; %in seconds
TR = 2.5; % in seconds
irun = 7;
 
%radius of your stimuli in space
r = 1 ; 

switch action
    case 1
        for irun = 1:irun
            
            logfile = [subject(1:end-5), '_fMRI_pRF_', num2str(irun)];
            load(fullfile(mainpath,'logfiles/fMRI/', logfile), 'rndNum_p');
            
            
            % pause at 24, 48, 72 --> 48, 96, 144
            % now zeros are 12.5 s / 2.5 = 5 zeros
            zeroArray = zeros((gap)/TR,1);
            stimArray = reshape(repmat(rndNum_p,[2,1]),[1, length(rndNum_p)*2]);
            stimArrayWithZeros = stimArray';
            
            % insert zeros in to gaps
            tempArray = [stimArrayWithZeros(1:48); zeroArray];
            tempArray = [tempArray; stimArrayWithZeros(49:96); zeroArray];
            stimArrayWithZeros = [tempArray; stimArrayWithZeros(97:end); zeroArray; 0];
            
            %% with TR inserted: stim_tr
            
            volumes = 1:160;
            stimTR = stimArrayWithZeros;
            
            %% with 0.25s stepsize : stim_ms
            % every element in log variable will be 19times itself and + 0
            % 4.75s stimuli + 0.25s ISI
            stepSize = 0.25;
            stimulusLength = 4.75;
            stimMilliSeconds =[];
            
            for i =1:length(volumes)
                
                temp = repmat(stimTR(i),(stimulusLength/stepSize),1); %repmat 19 copies
                temp = [temp; 0]; % add ISI as 0
                stimMilliSeconds = [stimMilliSeconds; temp];
                
            end
            
            save(sprintf('logfiles/%s_logfile%d.mat',subject,irun),'rndNum_p','stimTR','stimMilliSeconds');

        end
        
    case 2
        
        for id = 1:irun
            load_log = sprintf('logfiles/%s_logfile%d.mat',subject,id);
            load(load_log);
            
            %% 250ms or TR? 
            nFrames = length(stimTR);
           % nFrames = length(stim_ms); % 160 for TR stepsize, 3200 for 0.25s stepsize
            % also nFrames = length(log)
            scan.pos_list =stimTR; % log is from the logfile uploaded
           % scan.pos_list =stim_ms;
           
            %% creating empty grid
            mygrid = linspace(-70,70,101);
            [x,y] = meshgrid(mygrid, -mygrid);
            
            center_90deg = 60;
            center_45deg = center_90deg/sqrt(2);

            stimImg=zeros(length(mygrid)*length(mygrid),nFrames);
            
            %% inserting 1s into stimuli grid
            for i = 1:nFrames
                if scan.pos_list(i) == 1 % UP 90deg
                    C = sqrt((x).^2+(y-center_90deg).^2)<=r;
                    stimImg(C,i)=1;
                end
                if scan.pos_list(i) == 2 % RU 45deg
                    C = sqrt((x-center_45deg).^2+(y-center_45deg).^2)<=r;
                    stimImg(C,i)=1;
                end
                if scan.pos_list(i) == 3 % Right 0deg
                    C = sqrt((x-center_90deg).^2+(y).^2)<=r;
                    stimImg(C,i)=1;%stimImg(((nTimepoints-range):nTimepoints),i) = 1;
                end
                if scan.pos_list(i) == 4 % RD 315deg
                    C = sqrt((x-center_45deg).^2+(y+center_45deg).^2)<=r;
                    stimImg(C,i)=1;
                end
                if scan.pos_list(i) == 5 % DOWN 270deg
                    C = sqrt((x).^2+(y+center_90deg).^2)<=r;
                    stimImg(C,i)=1;
                end
                if scan.pos_list(i) == 6 % LD 225deg
                    C = sqrt((x+center_45deg).^2+(y+center_45deg).^2)<=r;
                    stimImg(C,i)=1;
                end
                if scan.pos_list(i) == 7 % Left 180deg
                    C = sqrt((x+center_90deg).^2+(y).^2)<=r;
                    
                    stimImg(C,i)=1;
                end
                if scan.pos_list(i) == 8 % LU 135deg
                    C = sqrt((x+center_45deg).^2+(y-center_45deg).^2)<=r;
                    stimImg(C,i)=1;
                    
                end
            end
            
            
            %% CB 17.10.2018 save - reorganized sttimImg to images.mat
            % restucture our stim space
            for i = 1:nFrames
                images(:,:,i) = reshape(stimImg(:,i),101,101);
            end
            
            
%             for i = 1:nFrames
%                 figure(100)
%                 imagesc(reshape(stimImg(:,i),101,101));
%                 colormap gray
%                 axis square
%                 drawnow
%                 pause(0.1)
%             end

% for i=1:nFrames
%     figure(100)
%     imagesc(images(:,:,i));
%     colormap gray
%     axis square
%     drawnow
%     pause(0.1)
% end


            save(sprintf('Stimuli/images_pRF_run%d_r%d.mat',id,r),'images');
            
        end
end