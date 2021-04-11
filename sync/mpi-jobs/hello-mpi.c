#include "mpi.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
	int myid, npes;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &npes);
	MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	printf("I am the %d proccess of %d\n", myid, npes);
	MPI_Finalize();

	return 0;
}

