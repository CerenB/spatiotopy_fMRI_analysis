function RF = calculate_RF_only(path)

% this funtion is ONLY for calculating the location of RFs across all the voxels
% in the brain

% for more calculations, please call: locate_RF 
% /Users/cerenbattal/Documents/MATLAB/vistasoft-master/mrBOLD/Analysis/retinotopyModel/rfGaussian2d.m
% function which takes: 
%RF = rfGaussian2d(X,Y,sigmaMajor,sigmaMinor,theta, x0,y0);

%    X,Y        : Sample positions in deg
%    sigmaMajor : standard deviation longest direction
%    sigmaMinor : standard deviation shortest direction
%                 [default: sigmaMinor = sigmaMajor]
%    theta      : angle of sigmaMajor (radians, 0=vertical)
%                 [default = 0];
%    x0         : x-coordinate of center of RF [default = 0];
%    y0         : y-coordinate of center of RF [default = 0];

% Allow sigma, x,y to be a matrix so that the final output will be
% size(X,1) by size(x0,2). This way we can make many RFs at the same time.


% example : RF = rfGaussian2d(X,Y,2,2,0,5,7);
% in this case x0 = 5, y0=7 in degrees so it could be around stimulus2

% it takes already calculated pRF models from:
%path = '/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/SC/AlSa/Gray/Averages';
%path = '/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/SC/DaCe/Gray/Averages_new';

cd(path);
m = load('ONEGAUSSIAN_wholebrain-fFit-fFit-fFit.mat');


% then take:
x0 = m.model{1}.x0; % matrix contain preferred x location per voxel
y0 = m.model{1}.y0; % matrix contain preferred y location per voxel
sigmaMajor =  m.model{1}.sigma.major;
sigmaMinor = sigmaMajor; % sigma.minor should be equal to major
theta = 0;
% this is my stimuli - grid
% made from images.mat
X = m.params.analysis.X;
Y = m.params.analysis.Y;

%check point for stimuli space
%figure; plot(X,Y,'.')


% find RF locationsfor every voxels = for loop across voxels
for i = 1:length(x0)
    
    RF(:,i) = rfGaussian2d(X,Y,sigmaMajor(i),sigmaMinor(i),theta, x0(i),y0(i));
    
end

end