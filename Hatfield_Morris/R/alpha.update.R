# for DA geophysics, automatically select alpha
#rm(list=ls())
source("./dainput/parameter.sh")

args=(commandArgs(TRUE))
if(length(args)==0){
    print("no arguments supplied, use default value")
    iter=1
    niter=4
}else{
    for(i in 1:length(args)){
        eval(parse(text=args[[i]]))
    }
}
print(paste("iter=",iter))
print(paste("niter=",niter))

load("results/obs.data.r")
load(paste("results/simu.ensemble.",iter,sep=''))
load(paste("results/state.vector.",iter-1,sep=''))

if (iter==1){
     parameterin = readLines("dainput/parameter.sh")
     niter_line = grep("finish=",parameterin)[1]
     parameterin[niter_line] = paste("finish=",formatC(0, format = "d"),sep='')
     writeLines(parameterin, "dainput/parameter.sh" )
}


obs.ensemble = array(0,c(nreaz,nobs*ntime))
obs.value = c(t(obs_value))
##obs.var = alpha*(obs_sd*obs.value)**2    #ERT percentage error
obs.var = (obs_sd*obs.value)**2    #ERT percentage error

for (iobs in 1:(nobs*ntime))
{
    obs.ensemble[,iobs] = obs.value[iobs] + c(rnorm(nreaz,0,sqrt(obs.var[iobs])))
}

## caculate alpha
alpha = 0
for (ireaz in 1:nreaz)
{
    error = ( obs.ensemble[ireaz,] - simu.ensemble[ireaz,] ) * sqrt(1/obs.var) 
    alpha = alpha + sqrt ( mean( error^2 ) )
}
alpha = alpha/nreaz

if (iter > 1) {	# check if sum_alpha > 1
	sum_alpha = sum(1/read.table('results/alpha.txt'))
	if (  ((sum_alpha + 1/alpha) > 1) | (iter==niter) ) {	# check if sum(1/alpha) > 1 or iter==niter
		alpha = 1 / (1 - sum_alpha)
		# inform break after nextin run.entire.sh or set niter = iter +1
		parameterin = readLines("dainput/parameter.sh")
		niter_line = grep("finish=",parameterin)[1]
		parameterin[niter_line] = paste("finish=",formatC(1, format = "d"),sep='')  
    		writeLines(parameterin, "dainput/parameter.sh" )   
	}
}
write.table(alpha,file="results/alpha.txt",col.names = F,row.names = F,append = T)


## updated obs.var
obs.var = alpha*(obs_sd*obs.value)**2    #ERT percentage error
for (iobs in 1:(nobs*ntime))
{
    obs.ensemble[,iobs] = obs.value[iobs] + c(rnorm(nreaz,0,sqrt(obs.var[iobs])))
}

## update step

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


save(list=ls(),file=paste("results/ies.",iter,sep=''))
save(state.vector,file=paste("results/state.vector.",iter,sep=''))
