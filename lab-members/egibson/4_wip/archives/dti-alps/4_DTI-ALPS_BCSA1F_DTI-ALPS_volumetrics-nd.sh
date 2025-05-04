#!/bin/bash -eux

readonly INPUT_DIR="/net/synapse/nt/data/BCSA1F/MRI/processed/DTI-ALPS/TBSS/tensor"

find_sessions () {
	# set the pattern to find the directories we care about
	if [[ "$#" -eq 0 ]]
	then
		local pattern="*"
	else
		local pattern=".*("
		for num; do
			pattern="${pattern}${num}|"
		done
		pattern="${pattern:0:-1}).*"	# cut the last pipe
	fi

	find "${INPUT_DIR}" -maxdepth 1 -mindepth 1 -type d -regextype posix-extended -regex "${pattern}"
}


function process_session {
	local session_path=$1
	local session_name=$(basename $session_path)
	local subject_dir=$(dirname $session_path)

	echo $session_path
	echo $session_name
	echo $subject_dir
	
	export HDF5_USE_FILE_LOCKING=FALSE

	# generating all the diffusion values needed for the DTI-ALPS calculation and storing into variables
	L_Hemi_Dxproj=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dxx.nii.gz -k L_hemi_proj.nii.gz -m)
	L_Hemi_Dxassoc=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dxx.nii.gz -k L_hemi_assoc.nii.gz -m)
	L_Hemi_Dyproj=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dyy.nii.gz -k L_hemi_proj.nii.gz -m)
	L_Hemi_Dzassoc=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dzz.nii.gz -k L_hemi_assoc.nii.gz -m)
	R_Hemi_Dxproj=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dxx.nii.gz -k R_hemi_proj.nii.gz -m)
	R_Hemi_Dxassoc=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dxx.nii.gz -k R_hemi_assoc.nii.gz -m)
	R_Hemi_Dyproj=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dyy.nii.gz -k R_hemi_proj.nii.gz -m)
	R_Hemi_Dzassoc=$(fsl5.0-fslstats ${INPUT_DIR}/${session_name}/${session_name}_tensor_comp_Dzz.nii.gz -k R_hemi_assoc.nii.gz -m)

	# using the diffusion values to calculate the ALPS Index
	# L_Hemi_ALPS_Index=$(((${L_Hemi_Dxproj}*${L_Hemi_Dxassoc})/2)/((${L_Hemi_Dyproj}*${L_Hemi_Dzassoc})/2))
	# R_Hemi_ALPS_Index=$(((${R_Hemi_Dxproj}*${R_Hemi_Dxassoc})/2)/((${R_Hemi_Dyproj}*${R_Hemi_Dzassoc})/2))

	echo Subject, L_Hemi_Dxproj, L_Hemi_Dxassoc, L_Hemi_Dyproj, L_Hemi_Dzassoc, R_Hemi_Dxproj, R_Hemi_Dxassoc, R_Hemi_Dyproj, R_Hemi_Dzassoc > ${INPUT_DIR}/${session_name}/${session_name}_DTI-ALPS_volumetrics.csv
	echo ${session_name}, ${L_Hemi_Dxproj}, ${L_Hemi_Dxassoc}, ${L_Hemi_Dyproj}, ${L_Hemi_Dzassoc}, ${R_Hemi_Dxproj}, ${R_Hemi_Dxassoc}, ${R_Hemi_Dyproj}, ${R_Hemi_Dzassoc} >> ${INPUT_DIR}/${session_name}/${session_name}_DTI-ALPS_volumetrics.csv

	echo ${session_name}, ${L_Hemi_Dxproj}, ${L_Hemi_Dxassoc}, ${L_Hemi_Dyproj}, ${L_Hemi_Dzassoc}, ${R_Hemi_Dxproj}, ${R_Hemi_Dxassoc}, ${R_Hemi_Dyproj}, ${R_Hemi_Dzassoc} >> ${INPUT_DIR}/PSCS1F_DTI-ALPS_volumetrics.csv

	
}

sessions=( $(find_sessions $@) )

for session in ${sessions[@]}; do
	echo $session
    process_session $session
done
