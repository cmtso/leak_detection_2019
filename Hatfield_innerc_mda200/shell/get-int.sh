#!/bin/bash -l
source "dainput/parameter.sh"

rm -r shell/int0 shell/int
mkdir shell/int0 shell/int


for ireaz in $(seq 1 $nreaz)
do 
    cp pflotran_mc2/"$ireaz"/"$mc_name"-int.dat shell/int/int-"$ireaz".dat
    cp pflotran_mc0/"$ireaz"/"$mc_name"-int.dat shell/int0/int-"$ireaz".dat
done

tar -czvf shell/int.tar.gz shell/int
tar -czvf shell/int0.tar.gz shell/int0
