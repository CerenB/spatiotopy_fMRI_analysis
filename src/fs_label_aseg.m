function fs_label_aseg


subject = 'ArRa';
group = 'EB';

pc = 1;


if pc == 2
    cd(sprintf('/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/Native_space',group,subject));
else
    cd(sprintf('/Users/cerenbattal/Cerens_files/fMRI/Processed/Spatio_pRF/%s/%s/Native_space',group,subject));
end


LG=niftiRead('LeftGrayMatter_rib.nii'); %_rib
RG=niftiRead('RightGrayMatter_rib.nii');
LW=niftiRead('LeftWhiteMatter_rib.nii');
RW=niftiRead('RightWhiteMatter_rib.nii');
New=LG;
New.data(LG.data==1)=0;
New.data(LG.data==0)=1;
New.data(RG.data==1)=0;
New.data(LW.data==1)=3;
New.data(RW.data==1)=4;
New.fname = sprintf('Segmentation_%s_rib.nii',subject); %_rib
%New.fname= ['Segmentation_subj001.nii'];
writeFileNifti(New);


end