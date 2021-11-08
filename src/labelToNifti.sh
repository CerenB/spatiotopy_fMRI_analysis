#!/bin/bash
# documentation: http://brainybehavior.com/neuroimaging/2010/05/converting-cortical-labels-from-freesurfer-to-volumetric-masks/

# Usage: labelToNifti.sh subject label hemisphere
# Ex: bash labelToNifti.sh AlCh V1 lh
# Output: subject/label_nifti/hemisphere_subject_label.nii.gz
# Output is registered in rawavg.nii.gz space (which is the original T1 space)
# My advice is to use fslview or itk-snap to visualise the result.

subject=$1
label=$2
hemisphere=$3 # lh or rh

# change me
cd /Users/mohamed/Desktop/AL/

export SUBJECTS_DIR=$PWD

mkdir ${subject}/label_nifti

tkregister2 --mov ${subject}/mri/rawavg.mgz --noedit --s ${subject} --regheader --reg ${subject}/register.dat

mri_label2vol --label ${subject}/label/${hemisphere}.${label}.label --temp ${subject}/mri/rawavg.mgz --subject ${subject} --hemi $hemisphere --o ${subject}/label_nifti/${hemisphere}_${subject}_${label}.nii.gz --proj frac 0 1 .1 --fillthresh .3 --reg ${subject}/register.dat

mri_convert ${subject}/mri/rawavg.mgz ${subject}/mri/rawavg.nii.gz

fslview ${subject}/mri/rawavg.nii.gz ${subject}/label_nifti/${hemisphere}_${subject}_${label}.nii.gz



