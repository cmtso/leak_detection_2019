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
#    state.vector <- c( rep(seq(20,50,length.out = 11),11), 
#                       rep(seq(-5,25,length.out = 11),each=11) )
    state.vector <- c( rep(seq(-5,55,length.out = 6),6), 
                       rep(seq(-33,-3,length.out = 6),each=6) )

    state.vector <- matrix(state.vector,nrow=2,byrow = TRUE)
    state.vector<-state.vector[,-c(1,6,31,36)] ## remove some columns    
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
     	if (state.vector[1,ireaz] <  -5)  {state.vector[1,ireaz]=state.vector0[1,ireaz]} 
     	if (state.vector[1,ireaz] >  55)  {state.vector[1,ireaz]=state.vector0[1,ireaz]}      		
        if (state.vector[2,ireaz] < -33)  {state.vector[2,ireaz]=state.vector0[2,ireaz]}      	
	if (state.vector[2,ireaz] >  -3)  {state.vector[2,ireaz]=state.vector0[2,ireaz]} 
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
#flux_line = grep("FLUX neumann",pflotranin)[1]

for (ireaz in 1:nreaz)
{
    pflotranin[loc_line+2] = paste("  ",formatC(state.vector[1,ireaz], format = "e", digits = 4), formatC(state.vector[2,ireaz], format = "e", digits = 4), "  18.1d0") 
    pflotranin[loc_line+3] = paste("  ",formatC(state.vector[1,ireaz], format = "e", digits = 4), formatC(state.vector[2,ireaz], format = "e", digits = 4), "  18.d0") 
    #pflotranin[flux_line+2] = paste("FLUX","  ",formatC(state.vector[1,ireaz], format = "e", digits = 4)) 

    ## write lines
    writeLines(pflotranin, paste(mc_dir,"/",ireaz,"/",mc_name,".in",sep=''))   
}

