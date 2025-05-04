#!/bin/bash -eux

readonly INPUT_DIR="/net/synapse/nt/data/BCSA1F/MRI/processed/DTI-ALPS/computebrain"
readonly OUTPUT_DIR="/net/synapse/nt/data/BCSA1F/MRI/processed/DTI-ALPS/TBSS"

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

	# copy the FA from computebrain output into TBSS directory
	cp ${INPUT_DIR}/${session_name}/dwipreprocessed/regrid_1.25/dwi_denoised_degibbs_preproc_clean_N4_1.25regrid_FA.nii ${OUTPUT_DIR}/${session_name}_FA.nii
	gzip ${OUTPUT_DIR}/${session_name}_FA.nii

	# make directory for the non-FA images (i.e. tensor)
	mkdir ${OUTPUT_DIR}/tensor || true

	# copy over tensor from computebrain output, renames to having same naming as corresponding FA (NOTE: the tensor WILL get relabelled as FA, this is not a mistake, just a requirement for the function)
	cp ${INPUT_DIR}/${session_name}/dwipreprocessed/regrid_1.25/dwi_denoised_degibbs_preproc_clean_N4_1.25regrid_tensor.nii ${OUTPUT_DIR}/tensor/${session_name}_FA.nii
	gzip ${OUTPUT_DIR}/tensor/${session_name}_FA.nii


}

sessions=( $(find_sessions $@) )

for session in ${sessions[@]}; do
	echo $session
    process_session $session
done
