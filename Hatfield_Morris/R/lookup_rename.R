# run selected realizations only

source("./dainput/parameter.sh")
rm(list=ls())
args=(commandArgs(TRUE))

if(length(args)==0){
    print("no arguments supplied, use default value")
    opts = 2
}else{
    for(i in 1:length(args)){
        eval(parse(text=args[[i]]))
    }
}

print("opts = ",opts)

allreaz=c(15 , 45 , 46  ,47 , 48 , 49,  50 , 51,  52,  53 , 54 , 65,  66,  67,  68 , 69 , 70, 100 ,
101 ,102, 140, 175 ,176 ,177, 178, 179 ,180, 199, 200, 201, 203, 252, 260, 261, 262, 263, 264, 265, 266, 277, 278, 279, 280, 287, 288, 289, 308, 309, 310, 311, 312, 313, 314, 315, 349)

#allreaz=c(15,45,46)

if (opts == 1)
{
  	system("mv pflotran_mc pflotran_mc_temp")
	system("mkdir pflotran_mc")
    	for (ii in length(allreaz):1)
	{
    		system(paste("mv pflotran_mc_temp/", allreaz[ii], " pflotran_mc0/",ii,sep=''))      
	}
	system("rm -r pflotran_mc_temp")
}else{
	for (ii in length(allreaz):1)
	{
    		system(paste("mv pflotran_mc/", ii, " pflotran_mc0/",allreaz[ii],sep=''))      
    		system(paste("mv pflotran_mc0/", allreaz[ii], " pflotran_mc0b/",allreaz[ii],sep=''))      
		
	}
}
