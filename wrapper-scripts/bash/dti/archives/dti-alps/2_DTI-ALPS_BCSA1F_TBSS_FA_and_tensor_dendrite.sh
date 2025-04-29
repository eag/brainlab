
# TBSS Step 1: erode your FA images slightly and zero the end slices and move these images to a “FA” subdirectory
fsl5.0-tbss_1_preproc *.nii.gz

# TBSS Step 2: runs the nonlinear registration, aligning all FA images to a 1x1x1mm standard space, the -T tage indicates we will be using the FMRIB58_FA_1mm as the target template in fsl
fsl5.0-tbss_2_reg -T 

# TBSS Step 3: Applies the nonlinear transforms found in the previous stage to all subjects to bring them into standard space, also creates files called “mean_FA” and “mean_FA_skeleton” based on the mean of all of the subjects
fsl5.0-tbss_3_postreg -S

# TBSS Step 4: Thresholds the mean FA skeleton image, our chosen value is 0.2
fsl5.0-tbss_4_prestats 0.2

# TBSS Step 5: run TBSS for the non-FA image for all subjects and moving output into the tensor directory
fsl5.0-tbss_non_FA tensor