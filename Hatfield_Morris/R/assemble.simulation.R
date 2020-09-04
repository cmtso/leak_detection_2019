### for DA hydrogeophysics

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
###output
simu.ensemble=array(0,c(nreaz,nobs*ntime))
for (ireaz in 1:nreaz) {
  for (itimes in 1:ntime) {
    for (obs.file in list.files(paste("pflotran_mc/",ireaz,"/",sep=''),pattern=paste("e4d__",obs_time[itimes],sep='')))   {     
      sim.single=read.table(paste("pflotran_mc/",ireaz,"/",obs.file,sep=''),skip=1,header=FALSE)
      sim.single=sim.single[,6] 
      simu.ensemble[ireaz,((itimes-1)*nobs+1):(nobs*itimes)]=sim.single
    }  
  }
}
save(simu.ensemble,file=paste("results/simu.ensemble.",iter,sep=''))


nodata = rowSums(simu.ensemble) # or faster use colSums(t(simu.ensemble)) 
nodata = which(nodata == 0)
print("Realizations with no data:")
print(nodata)
