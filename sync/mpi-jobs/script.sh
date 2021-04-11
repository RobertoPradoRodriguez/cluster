#!/bin/bash

#SBATCH -J hello-MPI
#SBATCH -o slurm-%J.out
#SBATCH -e slurm-%J.out
#SBATCH -t 00:00:05
#SBATCH --chdir=/vagrant/mpi-jobs
#SBATCH -n 1
#SBATCH -c 1

mpicc hello-mpi.c -o hello-mpi -Wall -Wextra
#mpirun -np 1 hello-mpi
srun ./hello-mpi