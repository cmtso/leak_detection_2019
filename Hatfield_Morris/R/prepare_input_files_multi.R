# for DA geophysics

rm(list=ls())
library(xts)
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
      # state.vector <- simulateMvMatrix(nreaz,
      #                   distributions = c(flux = "unif", flux_xloc = "unif", K4="lnorm" , K3="lnorm"),
      #                   param.list = list(flux= list(min=5e4, max=2e5), flux_xloc = list(min=-1500, max=-500),
      #                                     K4= list(meanlog=log(3e-11), sdlog=0.5), K3 = list(meanlog=log(4.5e-12), sdlog=0.5)),
      #                   cor.mat = diag(4),sample.method = "LHS", seed = 208)
      # state.df = as.data.frame(state.vector, colnames(list(c("flux","flux_xloc","K4","K3"))))
      # state.vector = t(state.vector)

      state.vector = runif(nreaz)*2e5
    } else {
      # needs modifying??
        load(paste("results/",isegment-1,"/state.vector.",niter,sep=""))
        flux = state.vector[1,]
        flux_xloc = state.vector[2,]
    }
    save(state.vector,file="results/state.vector.0")
    
} else {

    ## Prepare the obs file
    load("results/obs.data.r")
    obs_var = (obs_sd*obs_value)**2
    obs_value = obs_true + array(c(rnorm(length(obs_true),0,sqrt(obs_var))),dim(obs_true))
    save(obs_value,obs_true,nobs,obs_time,ntime,file="results/obs.data.r")

    ## Prepre flux
    load(file=paste("results/state.vector.",iter,sep=''))
    #state.df = as.data.frame(t(state.vector), colnames(list(c("flux","flux_xloc","K4","K3"))))
    flux=state.vector
    }
    
##Generate flux input
pflotranin = readLines(paste("template/",mc_name,".in",sep=''))
flux_line = grep("FLOW_CONDITION injection",pflotranin)[1]
flux_xloc_line = grep("REGION injection_well",pflotranin)[1]+2
K4_line = grep("MATERIAL_PROPERTY soil4",pflotranin)[1]
K3_line = grep("MATERIAL_PROPERTY soil3",pflotranin)[1]

for (ireaz in 1:nreaz)
{
  pflotranin[flux_line+4] = paste("RATE ",formatC(state.vector[ireaz], format = "e", digits = 5)," m^3/day ")    
  
  # #flux
    # pflotranin[flux_line+4] = paste("RATE ",formatC(state.df$flux[ireaz], format = "e", digits = 5)," m^3/day ")    
    # #flux_loc
    # pflotranin[flux_xloc_line] = paste("  ",formatC(state.df$flux_xloc[ireaz], format = "e", digits = 4),"0.5d0 -40.d0")
    # pflotranin[flux_xloc_line+1] = paste("  ",formatC(state.df$flux_xloc[ireaz], format = "e", digits = 4),"0.5d0 -10.d0")
    # #K4
    # pflotranin[K4_line+6] = paste("  PERM_X",formatC(state.df$K4[ireaz], format = "e", digits = 4))
    # pflotranin[K4_line+7] = paste("  PERM_Y",formatC(state.df$K4[ireaz], format = "e", digits = 4))
    # pflotranin[K4_line+8] = paste("  PERM_Z",formatC(state.df$K4[ireaz]/10, format = "e", digits = 4))# assume Kanis = 10
    # #K3
    # pflotranin[K3_line+6] = paste("  PERM_X",formatC(state.df$K3[ireaz], format = "e", digits = 4))
    # pflotranin[K3_line+7] = paste("  PERM_Y",formatC(state.df$K3[ireaz], format = "e", digits = 4))
    # pflotranin[K3_line+8] = paste("  PERM_Z",formatC(state.df$K3[ireaz]/10, format = "e", digits = 4))# assume Kanis = 10
    # # write
    writeLines(pflotranin, paste(mc_dir,"/",ireaz,"/",mc_name,".in",sep=''))   
}
