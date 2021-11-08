% this is only to plot frequecny spectrum of the 8 sounds
% mostly performed for the pRF analysis

sub = 'AlSa';
input_path= ['/Users/cerenbattal/Documents/MATLAB/Spatiotopy_fMRIcode/',sub];
cd(input_path);

sound_files= {'Down','Left','LeftDown','LeftUp','Up','Right','RightDown','RightUp'};
%isound = 1;
figure; 
for isound=1:length(sound_files)
    
    file_name = [sound_files{isound},'.csv'];
    F = importdata(file_name);
    
    x = F.data(:,1);
    y = F.data(:,2);

    subplot(2,4,isound);
    plot(x,y);
    
    xlabel('FrequencyHz')
    ylabel('LeveldB')
    title(sprintf(' %s Location',sound_files{isound}));
    
end

suptitle(sprintf('Subject# %s Power Spectrum',sub));
