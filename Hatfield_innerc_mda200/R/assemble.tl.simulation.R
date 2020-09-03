### for DA hydrogeophysics / difference relative to baseline

rm(list = ls())
#library(rhdf5)
#library(RCurl) #for merage list

args=(commandArgs(TRUE))
if(length(args)==0){
  print("no arguments supplied, use default value")
  iter=1}else{
    for(i in 1:length(args)){
      eval(parse(text=args[[i]]))
    }
  }

source("./dainput/parameter.sh")
load("results/obs.data.r")

homo.file = "data/mode2/hatfield.sig.srv"
homo = read.table(homo.file,skip=75,header=FALSE)
homo = homo[,6]

###output
simu.ensemble=array(0,c(nreaz,nobs*(ntime+1))) 
for (ireaz in 1:nreaz) {
  for (itimes in 1:(ntime+1)) {
    for (obs.file in list.files(paste("pflotran_mc/",ireaz,"/",sep=''),pattern=paste("e4d__",obs_time[itimes],sep='')))   {     
      sim.single=read.table(paste("pflotran_mc/",ireaz,"/",obs.file,sep=''),skip=1,header=FALSE)
      sim.single=sim.single[,6] 
    	if (itimes == 1) { sim.baseline = sim.single  }
      simu.ensemble[ireaz,((itimes-1)*nobs+1):(nobs*itimes)] = sim.single / sim.baseline * homo
	
	# look for bad ratios and output to file
	bad_index = which(sim.single/sim.baseline < 0.1)	
	bad_ratio = ( matrix(c(bad_index, sim.single[bad_index], sim.baseline[bad_index], sim.single[bad_index]/sim.baseline[bad_index] ), nrow=length(bad_index)) )
	write.table( bad_ratio  , file="results/bad_ratio.txt", col.names = F, row.names = F, append = F)
        bad_index = which(sim.single/sim.baseline > 50.0)
        bad_ratio = ( matrix(c(bad_index, sim.single[bad_index], sim.baseline[bad_index], sim.single[bad_index]/sim.baseline[bad_index] ), nrow=length(bad_index)) )
        write.table( bad_ratio  , file="results/bad_ratio.txt", col.names = F, row.names = F, append = T)


    }  
  }
}
simu.ensemble = simu.ensemble[ , (nobs+1):(nobs*(ntime+1)) ]
save(simu.ensemble,file=paste("results/simu.ensemble.",iter,sep=''))
