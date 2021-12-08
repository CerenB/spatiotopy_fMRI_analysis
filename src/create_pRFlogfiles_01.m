function create_pRFlogfiles_01(action)
%cb edited on 16.10.2018 
% this function created logfiles for pRF mrVista analysis.
% for now it needs to be in the same folder as the .mat files.
% for now, it only makes TR -- condition onset files
% later on actualy time (in seconds) ca nbe added)

% action == 1 makes stimTR with the logfile as input
% action == 2 makes stimuli space across time 

% cb 27.02.2019
% making logfiles - fMRI and Stimuli folders. 
% transfering logfiles from spatiotopy_cer to fMRI 

% cb 07.12.2021
% general edit + replacing sphere with a grid of 5x5x160 grid

%% set parameters
subject = 'AlSapilot';
group = 'SC'; 

data = '/Volumes/extreme/Cerens_files/fMRI/Processed/Spatio_pRF/';
mainpath = fullfile(data,group,subject);

gap = 12.5; % in seconds
TR = 2.5; % in seconds
runNb = 7;
 
% stimuli type = 1, it's circular
% stimuli type = 2, it's one point in the grid
stimuliType = 2;

%% let's beging
switch action
    case 1
        for iRun = 1:runNb
            
            logfileName = [subject(1:end-5), '_fMRI_pRF_', num2str(iRun)];
            load(fullfile(mainpath,'logfiles/fMRI/', logfileName), 'rndNum_p');
            
            
            % pause at 24, 48, 72 trials --> 48, 96, 144 volumes/frames
            % now zeros are 12.5 s / 2.5 = 5 zeros
            zeroArray = zeros((gap)/TR,1);
            stimulusArray = reshape(repmat(rndNum_p,[2,1]),[1, length(rndNum_p)*2]);
            stimulusArrayWithZeros = stimulusArray';
            
            % insert zeros into gaps
            tempArray = [stimulusArrayWithZeros(1:48); zeroArray];
            tempArray = [tempArray; stimulusArrayWithZeros(49:96); zeroArray];
            
            % creating stimulus order (1:8 labeling with zeros indicating
            % gaps)
            stimOrder = [tempArray; stimulusArrayWithZeros(97:end); zeroArray; 0]; %#ok<NASGU>
            
            % save
            newMatFile = [subject,'_logfile', num2str(iRun)];
            save(fullfile(mainpath, 'logfiles',newMatFile),'rndNum_p','stimOrder');
            
        end
        
    case 2
        
        for iRun = 1:runNb

            % load the mat file
            matFile = [subject, '_logfile', num2str(iRun)];
            load(fullfile(mainpath,'logfiles', matFile), 'stimOrder');
            
            % assign stimuli into number of frames
%             frameNb = length(stimOrder); 
            frameNb = length(unique(stimOrder)); 

            % change 0 into 9 labelling for silences
            stimOrder(stimOrder == 0) = 9;
            
            %% inserting 1s into stimuli grid
            if stimuliType == 1
                
                %radius of your stimuli in space
                radius = 10;
                
                %grid dimension
                gridDimension = 101;
                
                % create empty grid
                myGrid = linspace(-70,70,gridDimension);
                [x,y] = meshgrid(myGrid, -myGrid);

                stimImg = zeros(length(myGrid)*length(myGrid),frameNb);
            
                center_90deg = 60;
                center_45deg = center_90deg/sqrt(2);
                
                for iFrame = 1:frameNb
                    if stimOrder(iFrame) == 1 % UP 90deg
                        C = sqrt((x).^2+(y-center_90deg).^2)<=radius;
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 2 % RU 45deg
                        C = sqrt((x-center_45deg).^2+(y-center_45deg).^2)<=radius;
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 3 % Right 0deg
                        C = sqrt((x-center_90deg).^2+(y).^2)<=radius;
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 4 % RD 315deg
                        C = sqrt((x-center_45deg).^2+(y+center_45deg).^2)<=radius;
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 5 % DOWN 270deg
                        C = sqrt((x).^2+(y+center_90deg).^2)<=radius;
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 6 % LD 225deg
                        C = sqrt((x+center_45deg).^2+(y+center_45deg).^2)<=radius;
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 7 % Left 180deg
                        C = sqrt((x+center_90deg).^2+(y).^2)<=radius;
                        
                        stimImg(C,iFrame)=1;
                    end
                    if stimOrder(iFrame) == 8 % LU 135deg
                        C = sqrt((x+center_45deg).^2+(y-center_45deg).^2)<=radius;
                        stimImg(C,iFrame)=1;
                        
                    end
                    
                    if stimOrder(iFrame) == 9 % silences
                        C = sqrt((x+center_45deg).^2+(y-center_45deg).^2)<=radius;
                        stimImg(C,iFrame)=0;
                        
                    end
                end
                
            % restucture our stim space
            for iFrame = 1:frameNb
                images(:,:,iFrame) = reshape(stimImg(:,iFrame),gridDimension,gridDimension);
            end
            
            % visualisation
            for iFrame = 1:frameNb
                figure(100)
                imagesc(images(:,:,iFrame) );
                colormap gray
                axis square
                drawnow
                pause(0.1)
            end
            
            % save           
            newMatFile = ['images_pRF_run',num2str(iRun), '_r', num2str(radius)];
            save(fullfile(mainpath, 'Stimuli',newMatFile),'images');

                
            
            elseif stimuliType == 2

                %grid dimension
                gridDimension = 5;
                
                %create zero grid
                myGrid = linspace(-1,1,gridDimension);

                stimImg = zeros(length(myGrid),length(myGrid),frameNb);
                
                for iFrame = 1:frameNb
                    if iFrame == 1 % UP 90deg
                        stimImg(1,3,iFrame)=1;
                    end
                    if iFrame == 2 % RU 45deg
                        stimImg(2,4,iFrame)=1;
                    end
                    if iFrame == 3 % Right 0deg
                        stimImg(3,5,iFrame)=1;
                    end
                    if iFrame == 4 % RD 315deg
                        stimImg(4,4,iFrame)=1;
                    end
                    if iFrame == 5 % DOWN 270deg
                        stimImg(5,3,iFrame)=1;
                    end
                    if iFrame == 6 % LD 225deg
                        stimImg(4,2,iFrame)=1;
                    end
                    if iFrame == 7 % Left 180deg                        
                        stimImg(3,1,iFrame)=1;
                    end
                    if iFrame == 8 % LU 135deg
                        stimImg(2,2,iFrame)=1;
                        
                    end
                end
            end
            
%             
%             % visualisation
%             for iFrames = 1:frameNb
%                 figure(100)
%                 imagesc(stimImg(:,:,iFrames));
%                 colormap gray
%                 axis square
%                 drawnow
%                 pause(0.1)
%             end

            % save as pRF analysis would like to have
            images = stimImg;
            newMatFile = ['images_pRF_run',num2str(iRun)];
            save(fullfile(mainpath, 'Stimuli',newMatFile),'images');
            
        end
end