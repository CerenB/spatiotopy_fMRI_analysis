function create_logfiles_pRF(action,pc)
%cb edited on 16.10.2018 
% this function created logfiles for pRF mrVista analysis.
% for now it needs to be in the same folder as the .mat files.
% for now, it only makes TR -- condition onset files
% later on actualy time (in seconds) ca nbe added)

% action ==1 only logfiles - with TR
% action ==2 creates stimuli space across time -- no need - look at script, for TR stepsize:
% makeWedge_cb.m /Users/cerenbattal/Dropbox/Cerens_files/scripts/spatiotopy_code
% for 0.25s stepsize is below


%% THIS ABOT ADDING 27.02.2019
% making logfiles - fMRI and Stimuli folders. 
% transfering logfiles from spatiotopy_cer to fMRI 

%%
subject = 'ChSc';
group = 'EB'; 

if pc ==2
    cd(sprintf('/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/',group,subject));

else
    cd(sprintf('/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/',group,subject));
end

gap = 12.5;
TR = 2.5;
irun = 7; %for DAZo

%radius of your stimuli in space
r = 10 ; %20 19.10.2018

switch action
    case 1
        for irun = 1:irun
            
            load(sprintf('logfiles/fMRI/%s_fMRI_pRF_%d.mat',subject,irun));
            
            
            % pause at 24, 48, 72 --> 48, 96, 144
            % now zeros are 12.5 s / 2.5 = 5 zeros
            add_zeros = zeros((gap)/TR,1);
            stim_array = reshape(repmat(rndNum_p,[2,1]),[1, length(rndNum_p)*2]);
            with_zeros = stim_array';
            
            with_zerosA = [with_zeros(1:48); add_zeros];
            with_zerosA = [with_zerosA; with_zeros(49:96); add_zeros];
            with_zeros = [with_zerosA; with_zeros(97:end); add_zeros; 0];
            
            %% with TR inserted: stim_tr
            
            num = 1:160;
            stim_tr = with_zeros;
            
            %% with 0.25s stepsize : stim_ms
            % every element in log variable will be 19times itself and + 0
            % 4.75s stimuli + 0.25s ISI
            stepsize = 0.25;
            stimlen = 4.75;
            stim_ms =[];
            
            for i =1:length(num)
                
                temp = repmat(stim_tr(i),(stimlen/stepsize),1); %repmat 19 copies
                temp = [temp; 0]; % add ISI as 0
                stim_ms = [stim_ms; temp];
                
            end
            
            save(sprintf('logfiles/%s_logfile%d.mat',subject,irun),'rndNum_p','stim_tr','stim_ms');
            %save(sprintf('%s_logfile%d_250ms.mat',subject,irun),'rndNum_p','stim_tr','stim_ms');

        end
        
    case 2
        
        for id = 1:irun
            load_log = sprintf('logfiles/%s_logfile%d.mat',subject,id);
            %load_log = sprintf('logfiles/%s_logfile%d_250ms.mat',subject,id);
            load(load_log);
            
            %% 250ms or TR? 
            nFrames = length(stim_tr);
           % nFrames = length(stim_ms); % 160 for TR stepsize, 3200 for 0.25s stepsize
            % also nFrames = length(log)
            scan.pos_list =stim_tr; % log is from the logfile uploaded
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