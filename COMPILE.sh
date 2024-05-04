#!/bin/bash

#+++ Bash settings
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
#---

#+++ Variables
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
hpc_system="${HPC_SYSTEM}"
hpc_system_dir="${script_dir}/hpc_system"
readonly script_dir
#---

main() {
    # Read conf files
    hpc_system_file="${hpc_system_dir}/${hpc_system}"

    if [ ! -f "${hpc_system_file}" ]; then
        echo 1>&@ "HPC configuration not found: ${hpc_system_file}"
        exit 1
    fi

    echo "Loading ${hpc_system_file}"
    . "${hpc_system_file}"

    make_file="${script_dir}/make.${ARCH}"
    if [ ! -f "${make_file}" ]; then
        echo 1>&@ "Make not found: ${make_file}"
        exit 1
    fi
    echo "Make: ${make_file}"

    # Compile
    export INSTDIR="${script_dir}"
    ./configure -a "${ARCH}"
    make clean
    make ARCH="${ARCH}" drhook 2>&1 | tee log.make
}

main "${@}"
