#!/bin/bash

#SBATCH -J hello-MPI
#SBATCH -o slurm-%J.out
#SBATCH -e slurm-%J.out
#SBATCH -t 00:02:00
#SBATCH --chdir=/synced_folder/mpi-jobs
#SBATCH -n 2
#SBATCH -N 2
#SBATCH --ntasks-per-node=1
#SBATCH -c 1
#SBATCH -p normal

module purge
module load gnu9
module load openmpi4

mpicc hello-mpi.c -o hello-mpi -Wall -Wextra
#mpirun -np 2 --mca btl_tcp_if_include eth1 -mca plm rsh --hostfile /synced_folder/mpi-jobs/hostfile ./hello-mpi

#MPICH AND MVAPICH2
#mpirun -np $SLURM_NTASKS -iface eth1 ./hello-mpi

#OPENMPI
mpirun -np $SLURM_NTASKS ./hello-mpi

#srun --mpi=pmi2 ./hello-mpi
