#!/bin/bash

module purge
module load impi-2021.6.0/2021.6.0
module load intel-2021.6.0/libszip/2.1.1-tvhyi
module load oneapi-2022.1.0/2022.1.0
module load oneapi-2022.1.0/mkl/2022.1.0
module load intel-2021.6.0/impi-2021.6.0/hdf5-threadsafe/1.13.3-zbgha
module load intel-2021.6.0/impi-2021.6.0/netcdf-c-threadsafe/4.9.0-wpe4t
module load intel-2021.6.0/impi-2021.6.0/netcdf-fortran-threadsafe/4.6.0-75oow
module load intel-2021.6.0/impi-2021.6.0/parallel-netcdf/1.12.3-eshb5
module load intel-2021.6.0/curl/7.85.0-djjip
module load intel-2021.6.0/perl/5.36.0-jj4hw
module load intel-2021.6.0/perl-uri/1.72-6at2i
module list

export ARCH=ia64
