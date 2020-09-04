# for DA geophysics

rm(list=ls())
#library(xts)
#library(rhdf5)
library(EnvStats)
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
    } else {
    }
    state.vector <- simulateMvMatrix(nreaz, 
                        distributions = c(flux = "norm", xloc = "unif",yloc="unif"), 
                        param.list = list(flux = list(mean=4.171e-10,sd=1.5e-10),
                                             xloc = list(min=0.0,max=1.0),
						   yloc = list(min=0.0, max=1.0)), 
                        cor.mat = diag(3),sample.method = "LHS", seed = 555)
    state.vector=t(state.vector)
    save(state.vector,file="results/state.vector.0")
} else {
    # Prepare the obs file
    load(file="results/obs.data.r")
    obs_var = (obs_sd*obs_value)**2
    obs_value = obs_true + array(c(rnorm(length(obs_true),0,sqrt(obs_var))),dim(obs_true))
    save(obs_value,obs_true,nobs,obs_time,ntime,file="results/obs.data.r")

    ## Prepre flux
    load(file=paste("results/state.vector.",iter,sep=''))
}
    
##Generate flux input
pflotranin = readLines(paste("template/",mc_name,".in",sep=''))
loc_line = grep("REGION top",pflotranin)[1]
flux_line = grep("FLUX neumann",pflotranin)[1]

for (ireaz in 1:nreaz)
{
    pflotranin[loc_line+1] = paste("COORDINATE","  ",formatC(state.vector[2,ireaz], format = "e", digits = 4), formatC(state.vector[3,ireaz], format = "e", digits = 4), "  0.d0") 
    pflotranin[flux_line+2] = paste("FLUX","  ",formatC(state.vector[1,ireaz], format = "e", digits = 4)) 

    ## write lines
    writeLines(pflotranin, paste(mc_dir,"/",ireaz,"/",mc_name,".in",sep=''))   
}

