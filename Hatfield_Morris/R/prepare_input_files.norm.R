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
                                 distributions = c( 	c="unif", m ="unif", WT="unif", K="unif", poro="unif",
                                                     VGa="unif", VGm="unif", VGsr="unif", recharge="unif"),
                                 param.list = list(    	c = list(min=1.0, max=1.5),
                                                        m = list(min=0.5, max=2.0),
                                                        WT= list(min=-14.0, max=-9.0),
                                                        K = list(min=-15.0, max=-12.0),
                                                        poro = list(min=0.25, max=0.35),
                                                        VGa = list(min=0.0002, max=0.002),
                                                        VGm = list(min=0.4, max=0.8),
                                                        VGsr = list(min=0.01, max=0.2),
                                                        recharge = list(min=0.0, max=0.001)      ),
                                 cor.mat = diag(9),sample.method = "LHS", seed = 555)
    state.vector=t(state.vector)



    save(state.vector,file="results/state.vector.0")
} else {
    # Prepare the obs file
    load(file="results/obs.data.r")
    obs_var = (obs_sd*obs_value)**2
    obs_value = obs_true + array(c(rnorm(length(obs_true),0,sqrt(obs_var))),dim(obs_true))
    save(obs_value,obs_true,nobs,obs_time,ntime,file="results/obs.data.r")

    ## Prepre flux, double check if outside range
    load(file=paste("results/state.vector.",iter-1,sep=''))
    state.vector0 = state.vector  
    load(file=paste("results/state.vector.",iter,sep=''))
    for (ireaz in 1:nreaz)
    {
     	if (state.vector[1,ireaz] <   0)  {state.vector[1,ireaz]=state.vector0[1,ireaz]} 
     	if (state.vector[1,ireaz] >   8)  {state.vector[1,ireaz]=state.vector0[1,ireaz]}      	
    }
    save(state.vector,file=paste("results/state.vector.",iter,sep=''))
}

## write current parameter estimate to text file
write.csv(formatC(t(state.vector),format="e",digits=6), paste("results/state.vector.",iter,".csv",sep=""), row.names=FALSE,quote=FALSE)
#write.table(t(as.matrix(c(iter,apply(state.vector,1,mean),apply(state.vector,1,sd)))),file="results/summary.txt",sep="\t",col.names = F,row.names = F,append = T)
write.table(t(as.matrix(c(iter,apply(state.vector,1,mean)))),file="results/mean.summary.txt",sep="\t",col.names = F,row.names = F,append = T)
write.table(t(as.matrix(c(iter,apply(state.vector,1,sd)))),file="results/sd.summary.txt",sep="\t",col.names = F,row.names = F,append = T)

    
##Generate flux input
pflotranin = readLines(paste("template/",mc_name,".in",sep=''))
loc_line = grep("REGION injection_well",pflotranin)[1]
flux_line = grep("FLOW_CONDITION injection",pflotranin)[1]
K_line = grep("MATERIAL_PROPERTY layer3",pflotranin)[1]
cc_line = grep("CHARACTERISTIC_CURVES cc3		# VG cc3 here",pflotranin)[1]
WT_line = grep("FLOW_CONDITION initial",pflotranin)[1]
recharge_line = grep("FLOW_CONDITION recharge",pflotranin)[1]


for (ireaz in 1:nreaz)
{
    pflotranin[WT_line+5] = paste("  DATUM 0.d0 0.d0 ",formatC(state.vector[3,ireaz], format = "e", digits = 4), "	## water table 10m below surface") 

    pflotranin[K_line+2]  = paste("  POROSITY ",formatC(state.vector[5,ireaz], format = "f", digits = 4) ) 
    pflotranin[K_line+6]  = paste("    PERM_ISO ",formatC(10^state.vector[4,ireaz], format = "e", digits = 4) ) 
    pflotranin[cc_line+2] = paste("    ALPHA ",formatC(state.vector[6,ireaz], format = "e", digits = 4) ) 
    pflotranin[cc_line+3] = paste("    M ",formatC(state.vector[7,ireaz], format = "f", digits = 4) ) 
    pflotranin[cc_line+8] = paste("    M ",formatC(state.vector[7,ireaz], format = "f", digits = 4) ) 
    pflotranin[cc_line+4] = paste("    LIQUID_RESIDUAL_SATURATION ",formatC(state.vector[8,ireaz], format = "f", digits = 4) ) 
    pflotranin[cc_line+9] = paste("    LIQUID_RESIDUAL_SATURATION ",formatC(state.vector[8,ireaz], format = "f", digits = 4) ) 
    pflotranin[recharge_line+4] = paste("  FLUX ",formatC(state.vector[9,ireaz], format = "e", digits = 4), "m/day") 

    ## write lines
    writeLines(pflotranin, paste(mc_dir,"/",ireaz,"/",mc_name,".in",sep=''))   
}



nelem=scan(file = "./template/archies.txt",what = double(),n=1)
for (ireaz in 1:nreaz)
{
  archies = c(1,state.vector[1,ireaz] ,state.vector[2,ireaz] , 0.019) # homogeneous
  fname = paste(mc_dir,"/",ireaz,"/","archies.txt",sep='')
  write.table(nelem,file=fname,col.names=FALSE,row.names=FALSE,append=FALSE)
  write.table(t(replicate( nelem  , archies)) ,file=fname, sep = "\t",
              col.names=FALSE,row.names=FALSE, append = TRUE)

}

