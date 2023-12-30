#!/bin/bash

# afni_isc_wat2023.sh
#
# Created 6/22/20 by E. Wat & P. Molfese with assistance from D. Jangraw
# Assumes that user has performed Freesurfer reconstruction on anatomical data
#       recon-all -s subj01 -i subj01_anat.nii.gz -3T -all
# Following Freesurfer reconstruction we make SUMA/AFNI friendly versions of outputs
#       cd $fsroot/subj01
#       @SUMA_Make_Spec_FS -sid subj01 -NIFTI

# Set top level directory structure
topdir=/data/wat2023
task=story
fsroot=/data/wat2023/freesurfer

cd $topdir

for subj in $@
do
	cd $subj
	afni_proc.py -subj_id $subj                                                                 \
		-script $subj.isc_script -scr_overwrite                                             \
		-out_dir ${subj}.storyISC                                                           \
		-blocks despike tshift align tlrc volreg blur mask scale regress                    \
		-copy_anat ${fsroot}/$subj/SUMA/brain.nii.gz                                        \
		-anat_has_skull no                                                                  \
		-anat_follower_ROI aaseg anat ${fsroot}/$subj/SUMA/aparc.a2009s+aseg.nii            \
		          -anat_follower_ROI aeseg epi ${fsroot}/$subj/SUMA/aparc.a2009s+aseg.nii   \
		          -anat_follower_ROI FSvent epi ${fsroot}/$subj/SUMA/fs_ap_latvent.nii.gz   \
		          -anat_follower_ROI FSWMe epi ${fsroot}/$subj/SUMA/fs_ap_wm.nii.gz         \
		          -anat_follower_erode FSvent FSWMe                                         \
		-tlrc_base MNI152_T1_2009c+tlrc							    \
		-dsets ${topdir}/${subj}/func_story/ep2dbold*.nii.gz        			    \
		-tcat_remove_first_trs 6                                            	            \
		-align_opts_aea -giant_move 					    		    \
		-tshift_opts_ts -tpattern alt+z2 				    		    \
	   	-tlrc_NL_warp                                                                       \
	    	-volreg_align_to MIN_OUTLIER                                                        \
	    	-volreg_align_e2a                                                                   \
	    	-volreg_tlrc_warp                                                                   \
		-blur_size 6						 	    		    \
	    	-regress_ROI_PC FSvent 3                                                            \
	    	-regress_make_corr_vols aeseg FSvent                                                \
	    	-regress_anaticor_fast                                                              \
	    	-regress_anaticor_label FSWMe                                                       \
	    	-regress_censor_motion 0.3                                                          \
	    	-regress_censor_outliers 0.1                                                        \
	    	-regress_apply_mot_types demean deriv                                               \
	    	-regress_est_blur_epits                                                             \
	    	-regress_est_blur_errts                                                             \
	    	-regress_run_clustsim no					    		    \
		-bash -execute

	cd $topdir
done
