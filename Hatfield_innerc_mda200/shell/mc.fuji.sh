#!/bin/bash -l
source "dainput/parameter.sh"

export PETSC_DIR=~/petsc && PETSC_ARCH=/arch-linux2-c-debug && PFLOTRAN_DIR=~/pflotran-dev

part=16
npart=$((($nreaz+$part-1)/$part))


cd $mc_dir
rm *.txt

for ipart in $(seq 1 $npart)
do
	p1=$(( ($ipart-1)*$part+1   ))
	if [ $ipart == $npart ]
	then
	  p2=$nreaz
	else  
	  p2=$(( $ipart*$part ))
	fi

	for ireaz in $(seq $p1 $p2)
	do 
    		(cd $ireaz ; 
		$PETSC_DIR/$PETSC_ARCH/bin/mpirun -n 24 $PFLOTRAN_DIR/src/pflotran/pflotran -num_slaves 5 -pflotranin $mc_name".in" -screen_ouput off ; 
		cd ../ ;
		echo $ireaz > $ireaz.txt) &
  	done
    	
	while [ $(ls -ltr *.txt | wc -l) -lt $p2 ]
    	do
        	sleep 0.01
    	done
done


while [ ! -f $nreaz.txt ]
do
    sleep 1
done

cd ../
