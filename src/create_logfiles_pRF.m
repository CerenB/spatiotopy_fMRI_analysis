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
runNb = 7;
 
%radius of your stimuli in space
raduis = 1 ; 

%grid dimension
gridDimension = 5;

% stimuli type = 1, it's circular
% stimuli type = 2, it's one point in the grid
stimuliType = 2;

switch action
    case 1
        for iRun = 1:runNb
            
            logfile = [subject(1:end-5), '_fMRI_pRF_', num2str(iRun)];
            load(fullfile(mainpath,'logfiles/fMRI/', logfile), 'rndNum_p');
            
            
            % pause at 24, 48, 72 --> 48, 96, 144
            % now zeros are 12.5 s / 2.5 = 5 zeros
            zeroArray = zeros((gap)/TR,1);
            stimArray = reshape(repmat(rndNum_p,[2,1]),[1, length(rndNum_p)*2]);
            stimArrayWithZeros = stimArray';
            
            % insert zeros in to gaps
            tempArray = [stimArrayWithZeros(1:48); zeroArray];
            tempArray = [tempArray; stimArrayWithZeros(49:96); zeroArray];
            stimTR = [tempArray; stimArrayWithZeros(97:end); zeroArray; 0];
            
            save(sprintf('logfiles/%s_logfile%d.mat',subject,iRun),'rndNum_p','stimTR');

        end
        
    case 2
        
        for iRun = 1:runNb

            % load the mat file
            matFile = [subject, '_logfile', num2str(iRun)];
            load(fullfile(mainpath,'logfiles', matFile), 'stimTR');
            
            % assign stimuli into number of frames
            frameNb = length(stimTR);

            scan.pos_list = stimTR; 

           
            %% creating empty grid
            
            
            %% inserting 1s into stimuli grid
            if stimuliType == 1
                
                myGrid = linspace(-70,70,gridDimension);
                [x,y] = meshgrid(myGrid, -myGrid);

                stimImg = zeros(length(myGrid)*length(myGrid),frameNb);
            
                center_90deg = 60;
                center_45deg = center_90deg/sqrt(2);
                
                for iFrame = 1:frameNb
                    if scan.pos_list(iFrame) == 1 % UP 90deg
                        C = sqrt((x).^2+(y-center_90deg).^2)<=raduis;
                        stimImg(C,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 2 % RU 45deg
                        C = sqrt((x-center_45deg).^2+(y-center_45deg).^2)<=raduis;
                        stimImg(C,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 3 % Right 0deg
                        C = sqrt((x-center_90deg).^2+(y).^2)<=raduis;
                        stimImg(C,iFrame)=1;%stimImg(((nTimepoints-range):nTimepoints),i) = 1;
                    end
                    if scan.pos_list(iFrame) == 4 % RD 315deg
                        C = sqrt((x-center_45deg).^2+(y+center_45deg).^2)<=raduis;
                        stimImg(C,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 5 % DOWN 270deg
                        C = sqrt((x).^2+(y+center_90deg).^2)<=raduis;
                        stimImg(C,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 6 % LD 225deg
                        C = sqrt((x+center_45deg).^2+(y+center_45deg).^2)<=raduis;
                        stimImg(C,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 7 % Left 180deg
                        C = sqrt((x+center_90deg).^2+(y).^2)<=raduis;
                        
                        stimImg(C,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 8 % LU 135deg
                        C = sqrt((x+center_45deg).^2+(y-center_45deg).^2)<=raduis;
                        stimImg(C,iFrame)=1;
                        
                    end
                end
                
            elseif stimuliType == 2
                
                myGrid = linspace(-1,1,gridDimension);
                [x,y] = meshgrid(myGrid, -myGrid);

                stimImg = zeros(length(myGrid),length(myGrid),frameNb);
                
                for iFrame = 1:frameNb
                    if scan.pos_list(iFrame) == 1 % UP 90deg
                        stimImg(1,3,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 2 % RU 45deg
                        stimImg(2,4,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 3 % Right 0deg
                        stimImg(3,5,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 4 % RD 315deg
                        stimImg(4,4,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 5 % DOWN 270deg
                        stimImg(5,3,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 6 % LD 225deg
                        stimImg(4,2,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 7 % Left 180deg                        
                        stimImg(3,1,iFrame)=1;
                    end
                    if scan.pos_list(iFrame) == 8 % LU 135deg
                        stimImg(2,2,iFrame)=1;
                        
                    end
                end
            end
            
            
            %% CB 17.10.2018 save - reorganized sttimImg to images.mat
            % restucture our stim space
            for iFrame = 1:frameNb
                images(:,:,iFrame) = reshape(stimImg(:,iFrame),gridDimension,gridDimension);
            end
            
            
%             for i = 1:nFrames
%                 figure(100)
%                 imagesc(reshape(stimImg(:,i),101,101));
%                 colormap gray
%                 axis square
%                 drawnow
%                 pause(0.1)
%             end

for i=1:nFrames
    figure(100)
    imagesc(stimImg(:,:,i));
    colormap gray
    axis square
    drawnow
    pause(0.1)
end


            save(sprintf('Stimuli/images_pRF_run%d_r%d.mat',iRun,raduis),'images');
            
        end
end