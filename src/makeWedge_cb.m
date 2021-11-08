function params = makeWedge_cb(params,id)
% CB edited 16.10.2018 - it was same as
% makeWedge.m script in /Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/pRF_George/EB/AnDe_13092016
% CB 17.10.2018: creates stimImg -> images.mat file for the stepsize TR.
% create_logfiles_pRF.m instead, create logfiles + images.mat file with
% .25s stepsize

%%%%%%%% CONSIDER IN THE FUTURE DELETING THIS FILE - it's not working as if
%%%%%%%% makeWedge.m file
%%%%%%%%

% id == run numbers as well

% makeWedge - regular retinotopic 'wedge' stimulus
%
% params = makeWedge(params,id);
%
% largely copied from makeRetinotopyStimulus. 
% params should be a retinotopy model parameter structure.
% id is the index of the stimulus (e.g., which scan in the data type is the
% wedge scan we are constructing now?)
%
% 2006/06 SOD

if notDefined('params');     error('Need params'); end;
if notDefined('id');         id = 1;               end;

% Loop that creates the final images
fprintf(1,'[%s]:Creating images:',mfilename);

type       = 'wedge';
params.stim(id).stimSize = 60;
outerRad   = params.stim(id).stimSize;
innerRad   = 0;
wedgeWidth = params.stim(id).stimWidth .* (pi/180);
%ringWidth  = outerRad .* params.stim(id).stimWidth ./ 360;
numImages  = params.stim(id).nFrames ./ params.stim(id).nCycles;
%mygrid     = -params.analysis.fieldSize:params.analysis.sampleRate:params.analysis.fieldSize; 	 
%[x,y]      = meshgrid(mygrid, -mygrid);
%r          = ones(1,360); %sqrt (x.^2  + y.^2);
%theta      = linspace(0,2*pi,361); %atan2 (y, x);	  % atan2 returns values between -pi and pi
%theta      = theta(1:360);
%theta      = mod(theta,2*pi); % correct range to be between 0 and 2*pi
%[x,y]=pol2cart(theta,r); 
%% we need to update the sampling grid to reflect the sample points used
% ras 06/08: this led to a subtle bug in which (in rmMakeStimulus) multiple
% operations of a function would modify the stimulus images, but not the
% sampling grid. These parameters should always be kept very closely
% together, and never modified separately.

%%%%%%%%
id = 1 % in function mode, ease this 16.10.2018

load_log = sprintf('AlSa_logfile%d.mat',id);
load(load_log);
%%%
nFrames = 160; % also nFrames = length(log)
scan.pos_list =log; % log is from the logfile uploaded


%% creating empty grid
mygrid = linspace(-70,70,101);
[x,y] = meshgrid(mygrid, -mygrid);

center_90deg = 60;
center_45deg = center_90deg/sqrt(2);
r = 10 ; %2 16.10.2018

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


% for i = 1:2:nFrames
%         figure(100);
%         imagesc(reshape(stimImg(:,i),101,101));
%         colormap gray
%         axis square
%         drawnow
%         pause(.1)
% end


params.stim(id).images = stimImg;

%% CB 16.10.2018 to save onto logfile%d.mat files
%save(sprintf('AlSa_logfile%d.mat',id),'stimImg','log','logTR','rndNum_p');

%% CB 17.10.2018 save - reorganized sttimImg to images.mat
% restucture our stim space 

for irun =1:7
    
    images =[];
    %load the file contains stimImg
    load(sprintf('AlSa_logfile%d.mat',irun));
    
    for i = 1:nFrames
        images(:,:,i) = reshape(stimImg(:,i),101,101);
    end
    
    save(sprintf('images_pRF_run%d_tr.mat',irun),'images');
end

return;
