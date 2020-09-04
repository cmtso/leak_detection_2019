#!/bin/bash -l

#SBATCH -A geophys
#SBATCH -t 00:15:00
#SBATCH -N 1
#SBATCH --switches=1
#SBATCH --exclusive
#SBATCH -J xbw_s
#SBATCH -o xbw.out
#SBATCH -e xbw.err


mc_name="hatfield"

export PETSC_DIR=~/petsc && PETSC_ARCH=arch-linux2-c-debug && PFLOTRAN_DIR=~/pflotran-dev   ### constance

$PETSC_DIR/$PETSC_ARCH/bin/mpirun -n 24 $PFLOTRAN_DIR/src/pflotran/pflotran -pflotranin $mc_name".in" -screen_ouput off -num_slaves 5 ;

#srun -n 256  ~/pflotran-cori -pflotranin sellafield-171122.in -num_slaves 160
#
#not working
#srun -n 448  ~/pflotran-cori -pflotranin sellafield-171122.in -num_slaves 320

####SBATCH --qos premium

