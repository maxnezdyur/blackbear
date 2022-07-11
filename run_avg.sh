#!/bin/bash
#PBS -N average
#PBS -l select=1:ncpus=10:mpiprocs=10
#PBS -l place=scatter:excl
#PBS -l walltime=48:00:00
#PBS -P neams

cd $PBS_O_WORKDIR
module load use.moose moose-dev
 
mpiexec /scratch/nezdmn/projects/blackbear/blackbear-opt -i /scratch/nezdmn/projects/blackbear/self/notch/notched_avg_exofile.i >> avg.log
