library("sensitivity")
source("dainput/parameter.sh")

#https://www.osti.gov/servlets/purl/1274412   LBNL GSA and data worth manual for TOUGH2
# 
# CAN SET OBJECTIVE FUNCTION TO WEIGHTED rmse MISFIT TO HATFIELD DATA as in Herman(2015)

#https://rdrr.io/rforge/sensitivity/man/morris.html
#https://cran.r-project.org/web/packages/sensitivity/sensitivity.pdf
#https://waterprogramming.wordpress.com/2013/09/23/method-of-morris-elementary-effects-using-salib/
#https://www.hydrol-earth-syst-sci.net/17/2893/2013/hess-17-2893-2013.pdf

# check if it actually ran (need to modify to make sure all times are run from E4D)
# load('simu.ensemble.1')
# a = which (rowSums(simu.ensemble) == 0)

# sa <- morris(model = morris.fun, factors = 20, levels = 4, r = 4)
# print(sa)
# plot(sa)

morris2.factors = 13
morris2.r =25   # number of paths, Hermans (2013) HESS said 20 was good
iter=0
x <- morris(model = NULL, factors = morris2.factors, r = morris2.r,
            design = list(type = "oat", levels = 5, grid.jump = 3))
#tell(x,y)
# mu <- apply(x$ee, 2, mean)
# mu.star <- apply(x$ee, 2, function(x) mean(abs(x)))
# sigma <- apply(x$ee, 2, sd)

param.list = list(     xloc = list(min=0.0,max=8.0),
                       yloc = list(min=0.0,max=10.0),
                       q = list(min=-2.0, max=1.0), # log
                       t0 = list(min=0.0, max=20.0),
                	  c = list(min=1.0, max=1.5),
                       m = list(min=0.5, max=2.0),
                       WT= list(min=-14.0, max=-9.0),
                       K = list(min=-15.0, max=-12.0),
                       poro = list(min=0.25, max=0.35),
                       VGa = list(min=0.0002, max=0.002),
                       VGm = list(min=0.4, max=0.8),
                       VGsr = list(min=0.01, max=0.2),
                       recharge = list(min=0.0, max=0.001)  ) # up to 1 mm/day


stopifnot((morris2.factors+1)*morris2.r == nreaz)
stopifnot( morris2.factors == length(param.list))

state.vector = array(0,dim = dim(x$X))
for (ireaz in 1:nreaz)
{
  for (jj in 1:morris2.factors)
  {
    state.vector[ireaz,jj] = param.list[[jj]]$min + (param.list[[jj]]$max - param.list[[jj]]$min) * x$X[ireaz,jj]
  }
}
state.vector = t(state.vector)
rownames(state.vector) <- c("xloc","yloc","q","t0","c","m","WT","K","poro","VGa","VGm","VGSr","recharge")

save(morris,x,file=paste("results/morris",sep=''))
## write current parameter estimate to text file
write.csv(formatC(t(state.vector),format="e",digits=6), paste("results/state.vector.",iter,".csv",sep=""), row.names=FALSE,quote=FALSE)
save(state.vector,file=paste("results/state.vector.",iter,sep=''))

##Generate flux input
pflotranin = readLines(paste("template/",mc_name,".in",sep=''))
loc_line = grep("REGION injection_well",pflotranin)[1]
flux_line = grep("FLOW_CONDITION injection",pflotranin)[1]
K_line = grep("MATERIAL_PROPERTY layer3",pflotranin)[1]
cc_line = grep("CHARACTERISTIC_CURVES cc3",pflotranin)[2]
WT_line = grep("FLOW_CONDITION initial",pflotranin)[1]
recharge_line = grep("FLOW_CONDITION recharge",pflotranin)[1]
time_line = grep("FINAL_TIME",pflotranin)[1]


for (ireaz in 1:nreaz)
{
  pflotranin[loc_line+2] = paste("  ",formatC(state.vector[1,ireaz], format = "e", digits = 4), formatC(state.vector[2,ireaz], format = "e", digits = 4), "  -3.5d0") 
  pflotranin[loc_line+3] = paste("  ",formatC(state.vector[1,ireaz], format = "e", digits = 4), formatC(state.vector[2,ireaz], format = "e", digits = 4), "  -3.0d0") 
  pflotranin[flux_line+9] = paste(formatC(state.vector[4,ireaz], format = "e", digits = 5),"  ", formatC(10^state.vector[3,ireaz], format = "e", digits = 5))    
  pflotranin[flux_line+10] = paste(formatC(state.vector[4,ireaz]+3.0, format = "e", digits = 5),"  ", formatC( 0.0, format = "e", digits = 5))    
  # pflotranin[time_line+3] = paste("  MAXIMUM_TIMESTEP_SIZE 1.d-2 d at ",formatC( floor( (state.vector[4,ireaz] )/0.1)*0.1, digits = 3, format="e")," d")    
  # pflotranin[time_line+4] = paste("  MAXIMUM_TIMESTEP_SIZE 0.1 y at ", formatC(ceiling((state.vector[4,ireaz]+3.0 )/0.1)*0.1, digits = 3, format="e")," d")  
  pflotranin[time_line+3] = paste("  MAXIMUM_TIMESTEP_SIZE 1.d-10 d at ",formatC( state.vector[4,ireaz]     , digits = 3, format="e")," d")    
  pflotranin[time_line+4] = paste("  MAXIMUM_TIMESTEP_SIZE 1.d-2 d at ", formatC(  state.vector[4,ireaz]+1e-10 , digits = 12,format="e")," d")    
  pflotranin[time_line+5] = paste("  MAXIMUM_TIMESTEP_SIZE 1.0 d at ", formatC(  state.vector[4,ireaz]+3.0 , digits = 3, format="e")," d")    
  pflotranin[time_line+6] = paste("END")    

  pflotranin[WT_line+5] = paste("  DATUM 0.d0 0.d0 ",formatC(state.vector[7,ireaz], format = "e", digits = 4), "      ## water table 10m below surface") 
  pflotranin[K_line+2]  = paste("  POROSITY ",formatC(state.vector[9,ireaz], format = "f", digits = 4) ) 
  pflotranin[K_line+6]  = paste("    PERM_ISO ",formatC(10^state.vector[8,ireaz], format = "e", digits = 4) ) 
  pflotranin[cc_line+2] = paste("    ALPHA ",formatC(state.vector[10,ireaz], format = "e", digits = 4) ) 
  pflotranin[cc_line+3] = paste("    M ",formatC(state.vector[11,ireaz], format = "f", digits = 4) ) 
  pflotranin[cc_line+8] = paste("    M ",formatC(state.vector[11,ireaz], format = "f", digits = 4) ) 
  pflotranin[cc_line+4] = paste("    LIQUID_RESIDUAL_SATURATION ",formatC(state.vector[12,ireaz], format = "f", digits = 4) ) 
  pflotranin[cc_line+9] = paste("    LIQUID_RESIDUAL_SATURATION ",formatC(state.vector[12,ireaz], format = "f", digits = 4) ) 
  pflotranin[recharge_line+4] = paste("  FLUX ",formatC(state.vector[13,ireaz], format = "e", digits = 4), "m/day") 

  
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
                       
