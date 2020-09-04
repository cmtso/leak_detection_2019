# difference of resistivity from baseline
rm(list=ls())
#library(xts)
#library(RCurl) #for merage list

source("dainput/parameter.sh")
### R CMD BATCH --slave  R/thermal.data.R

homo.file = "data/mode2/hatfield.sig.srv"
homo = read.table(homo.file,skip=75,header=FALSE)
homo = homo[,6]

list2.file = "template/list_file.txt"			## first one is baseline
obs_time = read.table(list2.file,skip=1,header=FALSE)
obs_time = obs_time[,1]
srv.file = "template/hatfield.srv"
ert.srv = read.table(srv.file,skip=75,header=FALSE)
ert.srv = ert.srv[,2:5]

### form synthetic data tar ball
ntime =length(obs_time) - 1
nobs = nrow(ert.srv)
###read in all data for all times
ert.true=array(0,c(1,nobs*(ntime+1)))

for (itimes in 1:(ntime+1)) {
  for (obs.file in list.files(paste("data/exp/",sep=''),pattern=paste("e4d__",obs_time[itimes],sep='')))   {     
    true.single=read.table(paste("data/exp/",obs.file,sep=''),skip=1,header=FALSE)
    true.single=true.single[,6] 
  	if (itimes == 1) { true.baseline = true.single  }
    ert.true[((itimes-1)*nobs+1):(nobs*itimes)]=true.single / true.baseline * homo
  } 
 }

ert.true = ert.true[(nobs+1):(nobs*(ntime+1))]
obs_true = ert.true


obs.var = (obs_sd*obs_true)**2    #ERT percentage error
obs_value = obs_true + array(c(rnorm(length(obs_true),0,sqrt(obs.var))),length(obs_true)) ## make noisy data from ert.true
save(obs_value,obs_true,obs_time,ntime,nobs,file="results/obs.data.r")




