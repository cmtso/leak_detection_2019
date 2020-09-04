
ne = 46482
archies = rep(c(1.0,1.35,1.35,0.019),ne)
archies = t( matrix(archies,4,ne) )

fileout = 'data/true2/archies.txt'

write.table(ne,file=fileout,sep="\t",col.names = F,row.names = F,append = F)
write.table(format(archies,digits=4),file=fileout,sep="\t",col.names = F,row.names = F,quote = F,append = T)

