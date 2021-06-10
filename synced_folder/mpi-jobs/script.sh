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
module load mpich/3.3.2-ofi

mpicc hello-mpi.c -o hello-mpi -Wall -Wextra
#export LD_LIBRARY_PATH=/usr/local/lib
#mpirun -np 2 -x LD_LIBRARY_PATH ./hello-mpi
#PATH=$PATH:/opt/ohpc/pub/mpi/openmpi4-gnu9/4.0.5/bin
#LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ohpc/pub/mpi/openmpi4-gnu9/4.0.5/lib
#mpirun -np 2 --mca btl_tcp_if_include eth1 -mca plm rsh --hostfile /synced_folder/mpi-jobs/hostfile ./hello-mpi

#mpirun -np 2 --debugger --mca btl_base_verbose 30 ./hello-mpi

mpirun -np $SLURM_NTASKS -iface eth1 ./hello-mpi

#echo SLURM_JOB_NODELIST=$SLURM_JOB_NODELIST
#echo SLURM_NTASKS=$SLURM_NTASKS
#echo SLURM_JOB_NUM_NODES=$SLURM_JOB_NUM_NODES

#srun --mpi=pmi2 ./hello-mpiI_MPI_OFI_PROVIDER=tcp