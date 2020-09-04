source("dainput/parameter.sh")

misfitALL = array(0,c(1,niter))
for (iter in 1:length(list.files("results",pattern="misfit") ) )
{
  load(paste("results/misfit.",iter,sep=""))
  misfitALL[iter] =misfit
}
save(misfitALL,file="results/misfitALL")
