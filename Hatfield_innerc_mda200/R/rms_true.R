# for DA geophysics, comparing field and true syn. data
#rm(list=ls())
source("./dainput/parameter.sh")

load('results/obs.data.r')

#rm(ert.true,true.single,true.baseline)
###read in all data for all times



### form synthetic data tar ball
ntime =length(obs_time) - 1
nobs = nrow(ert.srv)
###read in all data for all times
ert.true=array(0,c(1,nobs*(ntime+1)))

for (itimes in 1:(ntime+1)) {
  for (obs.file in list.files(paste("data/exp/",sep=''),pattern=paste("e4d__",obs_time[itimes],sep='')))   {     
    true.single=read.table(paste("data/true2/",obs.file,sep=''),skip=1,header=FALSE)
    true.single=true.single[,6] 
        if (itimes == 1) { true.baseline = true.single  }
    ert.true[((itimes-1)*nobs+1):(nobs*itimes)]=true.single / true.baseline
  } 
 }

ert.true = ert.true[(nobs+1):(nobs*(ntime+1))]

true_value = ert.true


obs_var = (obs_sd*obs_value)**2         ## ERT percentage error to calculate misfit


rms.true = (c(true_value)-c(obs_value)) * diag(1/as.vector(obs_var)) * (c(true_value)-c(obs_value))
rms.true = sum(rms.true)
rms.true = sqrt(c((rms.true))/length(obs_value))

save(true_value,file="results/true_value.r")
print(rms.true)
