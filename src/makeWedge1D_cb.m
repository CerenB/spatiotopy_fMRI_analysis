function params = makeWedge1D_cb(params,id)
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
theta      = linspace(-pi,pi,361);%linspace(0,2*pi,361); %atan2 (y, x);	  % atan2 returns values between -pi and pi
theta      = theta(1:360);
%theta      = mod(theta,2*pi); % correct range to be between 0 and 2*pi
%[x,y]=pol2cart(theta,r); 
%% we need to update the sampling grid to reflect the sample points used
% ras 06/08: this led to a subtle bug in which (in rmMakeStimulus) multiple
% operations of a function would modify the stimulus images, but not the
% sampling grid. These parameters should always be kept very closely
% together, and never modified separately.

params.analysis.X = 0:360;
params.analysis.Y = zeros(361,1);
%%%%%%%%
id
load_log = sprintf('MiAr_fMRI_pRF_%d.mat',id);
load(load_log);
%%%
nFrames = 160;
stim.pause = 12.5;
TR = 2.5;

% pause at 24, 48, 72 --> 48, 96, 144
% now zeros are 12.5 s / 2.5 = 5 zeros
add_zeros = zeros((stim.pause)/TR,1);
scan.pos_list = reshape(repmat(rndNum_p,[2,1]),[1, length(rndNum_p)*2]);
scan.pos_list = scan.pos_list';
scan.pos_listA = [scan.pos_list(1:48); add_zeros];
scan.pos_listA = [scan.pos_listA; scan.pos_list(49:96); add_zeros];
scan.pos_list = [scan.pos_listA; scan.pos_list(97:end); add_zeros; 0];



r = 10;
%loR = 55; hiR = 65;
stimImg=zeros(length(theta),160);
step_deg = pi/8;

%%
for i = 1:nFrames
    if scan.pos_list(i) == 1 % UP 90deg
        ind= theta>(pi/2-step_deg) & theta<(pi/2 +step_deg);
        stimImg(ind,i)=1;
    end
    if scan.pos_list(i) == 2 % RU 45deg
        ind= theta>(pi/4-step_deg) & theta<(pi/4 +step_deg);
        stimImg(ind,i)=1;
    end
    if scan.pos_list(i) == 3 % Right 0deg
        ind= theta>-step_deg & theta<step_deg;
        stimImg(ind,i)=1;
    end
    if scan.pos_list(i) == 4 % RD 315deg
        ind= theta>(-pi/4-step_deg) & theta<(-pi/4+step_deg);
        stimImg(ind,i)=1;
    end
    if scan.pos_list(i) == 5 % DOWN 270deg
        ind= theta>(-pi/2-step_deg) & theta<(-pi/2 +step_deg);
        stimImg(ind,i)=1;
    end
    if scan.pos_list(i) == 6 % LD 225deg
        ind= theta>((-3*pi/4)-step_deg) & theta<((-3*pi/4) +step_deg);
        stimImg(ind,i)=1;
    end
    if scan.pos_list(i) == 7 % Left 180deg
       % C = sqrt((x+center_90deg).^2+(y).^2)<=r;
        ind = theta<(pi+step_deg) & theta>(pi-step_deg);
        ind2 = theta<(-pi+step_deg) &  theta>(-pi-step_deg);
%         %theta<(-pi+step_deg) down
%         %ind= theta<(pi+step_deg)up
%         %-pi-step_deg pi-step_deg == 157.5
%         %pi+step_deg -pi+step_deg == 202.5
        stimImg(ind,i)=1;
        stimImg(ind2,i)=1;
    end
    if scan.pos_list(i) == 8 % LU 135deg
        ind= theta>((3*pi/4)-step_deg) & theta<((3*pi/4) +step_deg);
        stimImg(ind,i)=1;
        
    end    
end

% 
% for i = 1:2:nFrames
%         figure(100);
%         imagesc(stimImg(:,i));
%         colormap gray
%         axis square
%         drawnow
%         pause(.1)
% end

%stimImg=stimImg(:);


params.stim(id).images = stimImg;


return;
