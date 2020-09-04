# for DA geophysics

rm(list=ls())
library(xts)
library(rhdf5)
source("dainput/parameter.sh")

args=(commandArgs(TRUE))
if(length(args)==0){
    print("no arguments supplied, use default value")
    isegment=1
    iter=0
}else{
    for(i in 1:length(args)){
        eval(parse(text=args[[i]]))
    }
}
print(paste("isegment=",isegment))
print(paste("iter=",iter))

if (iter==0)
{
    ####Generate initial flux
    if (isegment==1)
    {
        flux = array(1e5,c(nreaz))   ### set prior
	      flux_xloc = array(1500,c(nreaz))   ### set prior
    } else {
        load(paste("results/",isegment-1,"/state.vector.",niter,sep=""))
        flux = state.vector[1,]
        flux_xloc = state.vector[2,]
    }
    flux_sd = 3e4    ### set prior sd
    flux = flux+c(rnorm(nreaz,0,flux_sd))
    flux_xloc_sd = 300    ### set prior sd
    flux_xloc = flux_xloc+c(rnorm(nreaz,0,flux_xloc_sd))
    
    state.vector=array(0,c(2,nreaz))  #specify number of unknown parameters 
    state.vector[1,] = flux
    state.vector[2,] = flux_xloc
    save(state.vector,file="results/state.vector.0")
    
    

} else {

    ## Prepare the obs file
    load("results/obs.data.r")
    obs_var = (obs_sd*obs_value)**2
    obs_value = obs_true + array(c(rnorm(length(obs_true),0,sqrt(obs_var))),dim(obs_true))
    save(obs_value,obs_true,nobs,obs_time,ntime,file="results/obs.data.r")

    ## Prepre flux
    load(file=paste("results/state.vector.",iter,sep=''))
    flux=state.vector[1,]
    flux_xloc=state.vector[2,]
}
    
##Generate flux input
for (ireaz in 1:nreaz)
{
    fname = paste(mc_dir,"/",ireaz,"/","inj_rate.txt",sep='')
    write.table("DATA_UNITS m^3/day",file=fname,
            col.names=FALSE,row.names=FALSE, quote = FALSE )
    write.table(cbind(0,formatC(flux[ireaz], format = "e", digits = 4)),file=fname,
            col.names=FALSE,row.names=FALSE, quote = FALSE, append = TRUE )
    
    pflotranin = readLines(paste("template/",mc_name,".in",sep=''))
    flux_xloc_line = grep("REGION injection_well",pflotranin)[1]+2
    pflotranin[flux_xloc_line] = paste("  ",formatC(flux_xloc[ireaz], format = "e", digits = 4),"1250.d0 -80.d0")
    pflotranin[flux_xloc_line+1] = paste("  ",formatC(flux_xloc[ireaz], format = "e", digits = 4),"1250.d0 -35.d0")
    writeLines(pflotranin, paste(mc_dir,"/",ireaz,"/",mc_name,".in",sep=''))   
    
    
}
