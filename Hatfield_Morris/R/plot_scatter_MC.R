library(plyr)
source("dainput/parameter.sh")
dir.create(file.path("results", "img"), showWarnings = FALSE)

args=(commandArgs(TRUE))
if(length(args)==0){
  print("no arguments supplied, use default value")
  iter=0
}else{
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  }
}
print(paste("iter=",iter))

# Function that returns Root Mean Squared Error
rmse <- function(error)
{
  sqrt(mean(error^2))
}



#m_true <- data.frame(xloc = c(3.0), yloc = c(4.0),q = c(0.408), t0 = c(8.0),m = c(1.35), n = c(1.35))
#m_est <- read.csv(paste("results/state.vector.",iter,".csv",sep = ""))
#m_est <- rename(m_est, c("c"="m", "m"="n")) # needs plyr package
#m_prior <- read.csv(paste("results/state.vector.0.csv",sep = ""))
#m_prior <- rename(m_prior, c("c"="m", "m"="n")) # needs plyr package

load("results/obs.data.r")
load(paste("results/simu.ensemble.",iter,sep=''))
load(paste("results/state.vector.",iter-1,sep=''))


# pdf("results/img/scatterplot.pdf") 
# for (ireaz in 1:nreaz)
# {
#   x <- obs_true
#   y <- simu.ensemble[ireaz,] 
#   plot(x,y, main=sprintf("Scatterplot Hatfield field data: ireaz = %d",ireaz),
#        xlab=expression(paste("observed V/I ( ", Omega, " )")),
#        ylab=expression(paste("simulated V/I ( ", Omega, " )")),
#        col=rgb(0,100,0,50,maxColorValue=255), pch=16,)
#   abline(1,1, col="red", lwd=3, lty=2) #"Scatterplot Hatfield field data"
#   for (jj in 1:length(m_est))
#   {
#     text(grconvertX(0.75,"npc"), grconvertY(0.6-jj*0.05, "npc"),variable.names(m_true)[jj])
#     text(grconvertX(0.90,"npc"), grconvertY(0.6-jj*0.05, "npc"),format( m_est[ireaz,jj],digits = 6))
#   }
#   text(grconvertX(0.75,"npc"), grconvertY(0.15, "npc"),"rms")
#   text(grconvertX(0.90,"npc"), grconvertY(0.15, "npc"),format(rmse((x-y)/(0.05*x)),digits = 6)
#   )
#   ## try to print this on plot: m_est[32,]
#   #    xloc     yloc          q       t0        c         m
#   #    1 -5.485083 2.046549 0.02517651 14.62974 1.637182 0.8897985
# }
# dev.off()

fit_summary <- array(0,c(nreaz,5))


for (ireaz in 1:nreaz)
{
  x <- t(obs_true)
  y <- simu.ensemble[ireaz,] 
  # print(paste("ireaz=",ireaz))
  if ( sum(simu.ensemble[ireaz,] == 0) < 10 ) {   # not zero entries
  	corr1 = lm(formula = x ~ y)
  	corr2 = lm(formula = log10(abs(x)) ~ log10(abs(y)) )
  	fit_summary[ireaz ,] = c(corr1$coefficients, rmse((x-y)/(0.05*x)) ,corr2$coefficients)
  }
  else {
	fit_summary[ireaz ,3] = rmse((x-y)/(0.05*x))
  }
}
colnames(fit_summary) <- c('a1','b1','rmse','a2','b2')
print(paste("state.vector=",dim(state.vector) ))
print(paste("fit_summary=",dim(fit_summary) ))
write.csv(formatC(cbind( t(state.vector),fit_summary ),format="f",digits=4), paste("results/MCreport.csv"), row.names=FALSE,quote=FALSE)














