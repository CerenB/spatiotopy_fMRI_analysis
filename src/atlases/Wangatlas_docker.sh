
#!/bin/bash

# Usage: labelToNifti.sh subject label hemisphere
# Ex: bash lWangatlas_docker.sh AlSa
# Output: 
# The script writes the following surface data files to /path/to/your/freesurfer/subject/surf:
# lh.template_angle.mgz, rh.template_angle.mgz
# lh.template_eccen.mgz, rh.template_eccen.mgz
# lh.template_areas.mgz, rh.template_areas.mgz
# lh.wang2015_atlas.mgz, rh.wang2015_atlas.mgz
#It additionally writes out the following volume files to /path/to/your/freesurfer/subject/mri:
# native.template_angle.mgz
# native.template_eccen.mgz
# native.template_areas.mgz
#native.wang2015_atlas.mgz
# Output is registered in rawavg.nii.gz space (which is the original T1 space)

# make sure docker is downloaded and running


# documentation: https://hub.docker.com/r/nben/occipital_atlas/
# set your SUBJECTS_DIR
# e.g. SUBJECTS_DIR=/Applications/freesurfer/subjects

# go to your subjects' folder
cd SUBJECTS_DIR

subject=$1

# Invert the right hemisphere
xhemireg --s ${subject}
# Register the left hemisphere to fsaverage_sym
surfreg --s ${subject} --t fsaverage_sym --lh
# Register the inverted right hemisphere to fsaverage_sym
surfreg --s ${subject} --t fsaverage_sym --lh --xhemi

# note the docker runs from 12:56 to 13:15
docker run -ti --rm -v /Applications/freesurfer/subjects/:${subject}/input \nben/occipital_atlas:latest

# convert atlases from orig space to rawavg space
# To construct volumes oriented in the original T1's orientation (like the rawavg.mgz file),
# use the following FreeSurfer command:
# mri_convert -rl rawavg.mgz native.<volume>.mgz scanner.<volume>.mgz

mri_convert -rl ${subject}/mri/rawavg.mgz ${subject}/mri/native.template_eccen.mgz ${subject}/mri/scanner.template_eccen.mgz
mri_convert -rl ${subject}/mri/rawavg.mgz ${subject}/mri/native.template_areas.mgz ${subject}/mri/scanner.template_areas.mgz
mri_convert -rl ${subject}/mri/rawavg.mgz ${subject}/mri/native.template_angle.mgz ${subject}/mri/scanner.template_angle.mgz

# then convert them from .mgz ro .nii file format
# mri_convert  input_file_name.mgz  output_file_name.nii