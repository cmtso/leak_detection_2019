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



m_true <- data.frame(xloc = c(3.0), yloc = c(4.0),q = c(log10(0.408)), t0 = c(8.0),m = c(NA), n = c(NA)) # I used to set NA to 1.35
m_est <- read.csv(paste("results/state.vector.",iter,".csv",sep = ""))
m_est <- rename(m_est, c("c"="m", "m"="n")) # needs plyr package
m_prior <- read.csv(paste("results/state.vector.0.csv",sep = ""))
m_prior <- rename(m_prior, c("c"="m", "m"="n")) # needs plyr package

load("results/obs.data.r")
load(paste("results/simu.ensemble.",iter,sep=''))

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



### scatterplot matrix ###
#pdf(paste0("results/img/mmatrix_","_iter,".pdf",sep=''))
pdf("results/img/mmatrix.pdf")
panel.hist <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col = "cyan", ...)
}
pairs(rbind(m_est, m_prior, m_true ), upper.panel = NULL  ,
      cex=rep(c(1.25,1.0,2), c(nrow(m_est),nrow(m_est), 3)), 
      pch=rep(c(1,0,17), c(nrow(m_est),nrow(m_est), 3)), 
      col=rep(c(1,"darkgray",2), c(nrow(m_est),nrow(m_est), 3)),
	labels=c("xloc","yloc","log q", "t0","m","n") #, 
#	labels=c("xloc [m]","yloc [m]","log10(q [m^3/d])", "t0 [d]","m [-]","n [-]"), 
#      main="Prior, posterior, and true parameter"
      )
dev.off()

