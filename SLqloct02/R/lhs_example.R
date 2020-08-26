library(EnvStats)
mat.LHS <- simulateMvMatrix(1000, 
                            distributions = c(N.10.2 = "norm", LN.10.1 = "lnormAlt"), 
                            param.list = list(N.10.2  = list(mean=10, sd=2), 
                                              LN.10.1 = list(mean=10, cv=1)), 
                            cor.mat = matrix(c(1, .8, .8, 1), 2, 2), 
                            sample.method = "LHS", seed = 280)
## default values and ranges
# Lognormal:                      default       range
#                           mean    0          (−∞, ∞)
#                           sdlog   1           (0, ∞) 
# Lognormal (Alternative):        default       range
#                           mean exp(1/2)       (0, ∞) 
#                           cv   sqrt(exp(1)-1) (0, ∞) 


round(cor(mat.LHS, method = "spearman"), 2) 
#        N.10.2 LN.10.1
#N.10.2    1.00    0.79
#LN.10.1   0.79    1.00

#dev.new()
plot(mat.LHS, xlab = "Observations from N(10, 2)", 
     ylab = "Observations from LN(mean=10, cv=1)", 
     main = paste("Lognormal vs. Normal Deviates with Rank Correlation 0.8",
                  "(Latin Hypercube Sampling)", sep = ""))

####################################################
mat.LHS <- simulateMvMatrix(nreaz, 
                            distributions = c(flux = "norm", flux_xloc = "norm",K1 = "lnormAlt"), 
                            param.list = list(flux= list(mean=1e5, sd=3e4), flux_xloc = list(mean=1500, sd=300),
                                              K1 = list(mean=10, cv=1) ), 
                            cor.mat = diag(3), sample.method = "LHS", seed = 288)

#dev.new()
plot(mat.LHS, xlab = "flux", ylab = "flux_xloc", 
     main = paste("","(Latin Hypercube Sampling)", sep = ""))

x = c(3,2)
plot(mat.LHS[,x], xlab = "flux", ylab = "flux_xloc", 
     main = paste("","(Latin Hypercube Sampling)", sep = ""))

library(scatterplot3d)
df.LHS = as.data.frame(mat.LHS,colnames(list(c("flux","flux_xloc","K1"))))
attach(df.LHS) 
s3d <-scatterplot3d(flux,flux_xloc,K1, pch=16, highlight.3d=TRUE,
                    type="h", main="3D Scatterplot of Latin hypercube samples")

