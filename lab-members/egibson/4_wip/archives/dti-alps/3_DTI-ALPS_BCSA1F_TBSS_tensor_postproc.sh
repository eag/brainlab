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


	# moving TBSS non-FA output into the tensor directory
	mkdir ${OUTPUT_DIR}/tensor/origal_data || true
	mv ${OUTPUT_DIR}/tensor/${session_name}_FA.nii.gz ${OUTPUT_DIR}/tensor/origal_data/${session_name}_tensor.nii.gz

	mkdir ${OUTPUT_DIR}/tensor/${session_name}

	mv ${OUTPUT_DIR}/FA/${session_name}_FA_to_target_tensor.nii.gz ${OUTPUT_DIR}/tensor/${session_name}/

	# separating out the 4D tensor image to their individual tensors and renaming
	ImageMath 4 ${OUTPUT_DIR}/tensor/${session_name}/${session_name}_tensor_comp.nii.gz TimeSeriesDisassemble ${OUTPUT_DIR}/tensor/${session_name}/${session_name}_FA_to_target_tensor.nii.gz
	i=0 
	for index in xx xy xz yy yz zz; do
		mv ${OUTPUT_DIR}/tensor/${session_name}/${session_name}_tensor_comp100${i}.nii.gz ${OUTPUT_DIR}/tensor/${session_name}/${session_name}_tensor_comp_D${index}.nii.gz
		i=$((i+1))
	done


}

sessions=( $(find_sessions $@) )

for session in ${sessions[@]}; do
	echo $session
    process_session $session
done
