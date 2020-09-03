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
#    state.vector <- simulateMvMatrix(nreaz,
#                        distributions = c( xloc = "normTrunc",yloc="normTrunc",q="normTrunc",t0="normTrunc"),
#                        param.list = list(    xloc = list(mean=3.0, sd=0.25, min=-5.0,max=15.0),
#                                               yloc = list(mean=4.0,sd=0.25,min=-5.0, max=15.0),
#                                               q = list(mean=0.408,sd=0.025,min=0.0, max=5.0),
#                                               t0 = list(mean=8.0,sd=0.25,min=0.0, max=20.0)),
#                        cor.mat = diag(4),sample.method = "LHS", seed = 555)
         state.vector <- simulateMvMatrix(nreaz,
                        distributions = c( xloc = "emp",yloc="unif",q="unif",t0="unif", c="unif" , m ="unif"),
                        param.list = list(     xloc = list(obs=1:nreaz, discrete=T),
                                               yloc = list(min=4.0,max=4.0),
                                                q = list(min=-2.0, max=1.0),
                                               t0 = list(min=0.0, max=20.0),
                                                c = list(min=0.5, max=2.5),
                                                m = list(min=0.5, max=2.5)      ),
                        cor.mat = diag(6),sample.method = "LHS", seed = 555)

    state.vector=t(state.vector)
    idx2 = state.vector[1,] # use this to keep LHS sample for (xloc,yloc)
    print(idx2)

# lay grid in ERT area	
	grid <- c( rep(seq(0,8,length.out = 13),15),
          rep(seq(0,10,length.out = 15),each=13) )
	grid <- matrix(grid,nrow=2,byrow = TRUE)
	# plot(grid[1,],grid[2,])
	# lines(c(3,0),c(0,4))
	# lines(c(0,3),c(4,10))
	# lines(c(3,8),c(10,4))
	# lines(c(8,3),c(4,0))

	dist <- (grid[1,]-3.5)^2 + (grid[2,]-4.5)^2 # centre is (4,5)
	idx <- sort(dist, index.return=TRUE)$ix <= 64
	idx = (dist < 10)
	# plot(grid[1,idx],grid[2,idx])
	# lines(c(3,0),c(0,4))
	# lines(c(0,3),c(4,10))
	# lines(c(3,8),c(10,4))
	# lines(c(8,3),c(4,0))
	# count(idx)
	grid=grid[,idx]
	grid=grid[,-c(44)]

	state.vector[1:2,] = grid[,idx2]

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
        if (state.vector[2,ireaz] <   0)  {state.vector[2,ireaz]=state.vector0[2,ireaz]}      	
	if (state.vector[2,ireaz] >  10)  {state.vector[2,ireaz]=state.vector0[2,ireaz]} 
	if (state.vector[3,ireaz] < -2 )  {state.vector[3,ireaz]=state.vector0[3,ireaz]} 
	if (state.vector[3,ireaz] >  1)  {state.vector[3,ireaz]=state.vector0[3,ireaz]} 
	if (state.vector[4,ireaz] <  0 )  {state.vector[4,ireaz]=state.vector0[4,ireaz]} 
	if (state.vector[4,ireaz] >  20)  {state.vector[4,ireaz]=state.vector0[4,ireaz]} 
        if (state.vector[5,ireaz] <  0 )  {state.vector[5,ireaz]=state.vector0[5,ireaz]}
        if (state.vector[5,ireaz] >  3 )  {state.vector[5,ireaz]=state.vector0[5,ireaz]}
        if (state.vector[6,ireaz] <  0 )  {state.vector[6,ireaz]=state.vector0[6,ireaz]}
        if (state.vector[6,ireaz] >  3 )  {state.vector[6,ireaz]=state.vector0[6,ireaz]}

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

for (ireaz in 1:nreaz)
{
    pflotranin[loc_line+2] = paste("  ",formatC(state.vector[1,ireaz], format = "e", digits = 4), formatC(state.vector[2,ireaz], format = "e", digits = 4), "  -3.5d0") 
    pflotranin[loc_line+3] = paste("  ",formatC(state.vector[1,ireaz], format = "e", digits = 4), formatC(state.vector[2,ireaz], format = "e", digits = 4), "  -3.0d0") 
    pflotranin[flux_line+9] = paste(formatC(state.vector[4,ireaz], format = "e", digits = 5),"  ", formatC(10^state.vector[3,ireaz], format = "e", digits = 5))    
    pflotranin[flux_line+10] = paste(formatC(state.vector[4,ireaz]+3.0, format = "e", digits = 5),"  ", formatC( 0.0, format = "e", digits = 5))    
    ## write lines
    writeLines(pflotranin, paste(mc_dir,"/",ireaz,"/",mc_name,".in",sep=''))   
}



nelem=scan(file = "./template/archies.txt",what = double(),n=1)
for (ireaz in 1:nreaz)
{
  archies = c(1,state.vector[5,ireaz] ,state.vector[6,ireaz] , 0.019) # homogeneous
  fname = paste(mc_dir,"/",ireaz,"/","archies.txt",sep='')
  write.table(nelem,file=fname,col.names=FALSE,row.names=FALSE,append=FALSE)
  write.table(t(replicate( nelem  , archies)) ,file=fname, sep = "\t",
              col.names=FALSE,row.names=FALSE, append = TRUE)

}

