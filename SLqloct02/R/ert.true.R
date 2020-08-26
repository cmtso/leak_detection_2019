rm(list=ls())
#library(xts)
#library(RCurl) #for merage list

source("dainput/parameter.sh")
### R CMD BATCH --slave  R/thermal.data.R

list2.file = "data/true2/list_file.txt"
obs_time = read.table(list2.file,skip=1,header=FALSE)
obs_time = obs_time[,1]
srv.file = "data/true2/sellafield.srv"
ert.srv = read.table(srv.file,skip=163,header=FALSE)
ert.srv = ert.srv[,2:5]

### form synthetic data tar ball
ntime =length(obs_time)
nobs = nrow(ert.srv)
obs.list = rep("Obs_",nobs)
for (iobs in 1:nobs)
{obs.list[iobs] = paste(obs.list[iobs],as.character(iobs),sep='') }
###read in all data for all times
ert.true=array(0,c(1,nobs*ntime))

for (itimes in 1:ntime) {
  for (obs.file in list.files(paste("data/true2/",sep=''),pattern=paste("e4d__",obs_time[itimes],sep='')))   {     
    true.single=read.table(paste("data/true2/",obs.file,sep=''),skip=1,header=FALSE)
    true.single=true.single[,6] 
    ert.true[((itimes-1)*nobs+1):(nobs*itimes)]=true.single
  }  }
obs_true = ert.true

obs.var = (obs_sd*obs_true)**2    #ERT percentage error
obs_value = obs_true + array(c(rnorm(length(obs_true),0,sqrt(obs.var))),dim(obs_true)) ## make noisy data from ert.true
save(obs_value,obs_true,obs_time,ntime,nobs,file="results/obs.data.r")




