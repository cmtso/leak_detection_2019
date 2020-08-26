#!/bin/bash -l


#SBATCH -A geophys
#SBATCH -t 06:30:00
#SBATCH -N 8
#SBATCH --switches=1
#SBATCH --exclusive
#SBATCH -J xbw_s
#SBATCH -o xbw.out
#SBATCH -e xbw.err

module load gcc/5.2.0
module load netcdf
module load R

source "dainput/parameter.sh"

###====Clear old results
rm -r results pflotran_mc pflotran_mc0 pflotran_mc2
mkdir results pflotran_mc pflotran_mc0 pflotran_mc2

###====Create folder for forecast
for ireaz in $(seq 1 $nreaz)
do 
    mkdir "$mc_dir"/"$ireaz"
done

###====Read synthetic ERT data
R CMD BATCH --slave  R/ert.true.R


###====loop over different segments
for isegment in $(seq 1 $nsegment) 
do
    ###First forecast
    iter=0
    for ireaz in $(seq 1 $nreaz)
    do 
	cp template/* "$mc_dir"/"$ireaz"/
    done
    R CMD BATCH --slave "--args isegment=$isegment iter=$iter" R/prepare_input_files.norm.R

	echo "finish creating input files"
    shell/mc.fuji.sh 
    cp -r pflotran_mc/. pflotran_mc0

   #iteration
    for iter in $(seq 1 $niter)
    do 
	export iter
	echo $iter > $iter.txt &
	#### Update state.vector
	R CMD BATCH --slave "--args iter=$iter" R/assemble.simulation.R
	R CMD BATCH --slave "--args iter=$iter alpha=$niter" R/mda.update.R


	# #####Run Forecast
	R CMD BATCH --slave "--args isegment=$isegment iter=$iter" R/prepare_input_files.norm.R
    	shell/mc.fuji.sh 
       cp -r pflotran_mc/. pflotran_mc2
    done
    
    #for ireaz in $(seq 1 $nreaz)
    #do
#	cp $mc_dir"/"$ireaz"/"$mc_name"-restart.chk"  $mc_dir"/"$ireaz"/restart.chk" 
#    done
    
#    mkdir "results/"$isegment
#    find results/ -maxdepth 1 -type f -exec mv {} "results/"$isegment \; 
    shell/pack.results.sh 

done




