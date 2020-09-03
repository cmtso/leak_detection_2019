#!/bin/bash -l
source "dainput/parameter.sh"

rm -r shell/int0 shell/int
mkdir shell/int0 shell/int


for ireaz in $(seq 1 $nreaz)
do 
    cp "$mc_dir"/"$ireaz"/"$mc_name"-int.dat shell/int/int-"$ireaz".dat
    cp pflotran_mc0/"$ireaz"/"$mc_name"-int.dat shell/int0/int-"$ireaz".dat
done

mkdir results/export
mv -r shell/int0 results/export/.
mv -r shell/int  results/export/.

cp results/rms.txt results/export/.
cp -r results/state.vector.*.csv results/export/.

tar -czvf results/export.tar.gz results/export
