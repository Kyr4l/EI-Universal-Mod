#!/bin/bash

# ressource folders
dds=dds
mmp=mmp

totaldds=""

cd $mmp || exit

for in in *.mmp; do
    out="${in%mmp}dds"
    wine ../bin/MMPS.exe "$in"
    mv -fv "$out" ../$dds/
    echo "Processed $in -> $out"
    totaldds="$totaldds $in"
done

echo "DONE CONVERTING FILES TO MMP"
echo "Processed the folllwing file(s) : $totaldds"