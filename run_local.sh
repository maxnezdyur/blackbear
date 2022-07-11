#!/bin/bash
#PBS -N local
#PBS -l select=1:ncpus=20:mpiprocs=20
#PBS -l place=scatter:excl
#PBS -l walltime=48:00:00
#PBS -P neams

cd $PBS_O_WORKDIR
module load use.moose moose-dev
 
mpiexec /scratch/nezdmn/projects/blackbear/blackbear-opt -i /scratch/nezdmn/projects/blackbear/self/notch/notched_local_exofile.i  >> local.log
