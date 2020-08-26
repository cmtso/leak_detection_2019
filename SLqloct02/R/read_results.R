source('/home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics1d/q+k/dainput/parameter.sh')
niter=alpha
misfitALL = array(0,c(1,niter))
state.mean = array(0,c(1,niter))
state.var = array(0,c(1,niter))

load("/home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics1d/q+k/results/1/simu.ensemble.1")
for (iter in 1:niter)
{
load(paste("/home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics1d/q+k/results/1/misfit.",iter,sep=""))
misfitALL[iter] =misfit/length(simu.ensemble)
}
iter = 1:niter
plot(iter,misfitALL,"b")
title("convergence behaviour")

# plot parameter update
load('/home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics1d/q+k/results/1/state.vector.0')
m0 = state.vector
load('/home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics1d/q+k/results/1/state.vector.3')
m4 = state.vector
load('/home/tsom/Documents/DA_Michael/da_hydrogeophysics/da_hydrogeophysics1d/q+k/results/1/state.vector.6')
m10 = state.vector
# 


par(mfrow=c(1,2))
p0 <- hist(log10(m0[2,]))                     # centered at 4
p1 <- hist(log10(m4[2,]))
p2 <- hist(log10(m10[2,]))                     # centered at 6
plot( p0, col=rgb(0,0,1,1/4), xlab=NULL,main=NULL)  # first histogram
plot( p1, col=rgb(1,0,0,3/4), xlab=NULL,main=NULL, add=T,lty="blank")  # second
plot( p2, col=rgb(0,1,0,3/4), xlab=NULL,main=NULL, add=T,lty="blank")  # second
title(main = 'Histogram of parameter estimate', sub = NULL, xlab = 'Flux at inflow', ylab = NULL,
      line = NA, outer = FALSE)
legend(-2e-7,9, legend=c("prior", "iter=1","iter=5"),col=c("blue","red", "green"),
       lty=1, cex=0.8)

text(7e-7,4,"prior")
text(4.7e-7,4,"iter=1")
text(2.5e-7,4,"iter=5")
