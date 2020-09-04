# for DA geophysics
#rm(list=ls())
source("./dainput/parameter.sh")

args=(commandArgs(TRUE))
if(length(args)==0){
    print("no arguments supplied, use default value")
    iter=1
    alpha=4
}else{
    for(i in 1:length(args)){
        eval(parse(text=args[[i]]))
    }
}
print(paste("iter=",iter))
print(paste("alpha=",alpha))

load("results/obs.data.r")
load(paste("results/simu.ensemble.",iter,sep=''))
load(paste("results/state.vector.",iter-1,sep=''))

obs.ensemble = array(0,c(nreaz,nobs*ntime))
obs.value = c(t(obs_value))
obs.var = alpha*(obs_sd*obs.value)**2    #ERT percentage error

for (iobs in 1:(nobs*ntime))
{
    obs.ensemble[,iobs] = obs.value[iobs] + c(rnorm(nreaz,0,sqrt(obs.var[iobs])))
}

cov.state_simu = cov(t(state.vector),simu.ensemble)
cov.simu = cov(simu.ensemble,simu.ensemble)
inv.cov.simuADDobs = solve(cov.simu+diag(obs.var))
kalman.gain = cov.state_simu %*% inv.cov.simuADDobs
state.vector = state.vector+t((obs.ensemble-simu.ensemble) %*% t(kalman.gain))

obs_var = (obs_sd*obs_value)**2         ## ERT percentage error to calculate misfit
rms.single = array(0,c(1,nreaz))
for (ireaz in 1:nreaz)
{
    rms.single[ireaz] = (simu.ensemble[ireaz,]-c(obs_value)) %*% diag(1/as.vector(obs_var)) %*% (simu.ensemble[ireaz,]-c(obs_value))

}

rms_iter = sqrt(c(mean(rms.single))/length(obs_value))
write.table(rms_iter,file="results/rms.txt",col.names = F,row.names = F,append = T)
#write.table(as.matrix(t(c(rms_iter,sqrt(rms.single/length(obs_value))))),file="results/rms.txt",col.names = F,row.names = F,append = T)


save(list=ls(),file=paste("results/ies.",iter,sep=''))
save(state.vector,file=paste("results/state.vector.",iter,sep=''))
