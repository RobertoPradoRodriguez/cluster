#!/bin/bash

#SBATCH -J hello-MPI
#SBATCH -o slurm-%J.out
#SBATCH -e slurm-%J.out
#SBATCH -t 00:00:05
#SBATCH --chdir=/synced_folder/mpi-jobs
#SBATCH -n 2
#SBATCH --tasks-per-node=1
#SBATCH -c 1
#SBATCH -p normal

module purge
module load gnu9
module load openmpi4

mpicc hello-mpi.c -o hello-mpi -Wall -Wextra
export LD_LIBRARY_PATH=/usr/local/lib
mpirun -np 2 -x LD_LIBRARY_PATH ./hello-mpi

#srun --mpi=pmi2 ./hello-mpi
#srun --mpi=none hostname
