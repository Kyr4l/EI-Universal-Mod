#!/bin/bash

# disable WINE debug messages
export WINEDEBUG=-all

# mod folder location and naming
modout="mods-out"
modfolder="$modout"/"$(date +"%Y-%m-%d_%H-%M-%S")"
# ressources directories
inidir="ini"
regdir="reg"
ddsdir="dds"
mmpdir="mmp"
resdir="res"
rextdir="res-unpacked"
# total files
totalreg=""
totalmmp=""
totalres=""


# directory creation
echo "Creating mod directory : $modfolder"
mkdir -p "$modfolder"/config
mkdir "$modfolder"/res
mkdir "$modfolder"/maps

# ini2reg
echo ""
echo "========================"
echo "| PROCESSING INI FILES |"
echo "========================"
echo ""
echo "Converting INI files to REG..."

for iniin in "$inidir"/*.ini ; do
    regout="${iniin%ini}reg"
    wine bin/ini2reg.exe "$iniin"
    mv -fv "$regout" $regdir/
    totalreg="$totalreg $iniin"
done

echo "==============================="
echo "Processed the following files : $totalreg"
echo "==============================="
echo "Copying REG files into their respective folder..."
echo "Files detected in $regdir : $(ls $regdir | xargs)"
cp -v "$regdir"/config.reg "$modfolder" 2>/dev/null
cp -v "$regdir"/ai.reg "$modfolder"/config 2>/dev/null
cp -v "$regdir"/music.reg "$modfolder"/res 2>/dev/null
cp -v "$regdir"/streamsn.reg "$modfolder"/res 2>/dev/null
cp -v "$regdir"/smessbase.reg "$modfolder"/res 2>/dev/null
cp -v "$regdir"/autorunpro.reg "$modfolder" 2>/dev/null


# dds2mmp
echo ""
echo "========================"
echo "| PROCESSING DDS FILES |"
echo "========================"
echo ""
echo "Converting DDS files to MMP..."
cd $ddsdir || exit

for ddsin in *.dds ; do
    mmpout="${ddsin%dds}mmp"
    wine ../bin/MMPS.exe "$ddsin"
    mv -fv "$mmpout" ../$mmpdir/
    totalmmp="$totalmmp $ddsin"
done

echo "==============================="
echo "Processed the following files : $totalmmp"
echo "==============================="
cd .. || exit
echo "Moving MMP files to textures_res"
mkdir "$rextdir"/textures_res 2>/dev/null || echo "textures_res already exists, overwriting..."
mv -fv "$mmpdir"/* $rextdir/textures_res/

# eipacker
echo ""
echo "========================"
echo "| PROCESSING RES FILES |"
echo "========================"
echo ""
echo "Packing RES files..."
echo "========================"

for rextin in "$rextdir"/*_res; do
    resout="${rextin%_res}.res"
    wine bin/eipacker.exe /pack "$rextin"
    rsync -r --remove-source-files "$resout" "$resdir"/
    echo "RSync completed on $resout"
    echo "========================"
    totalres="$totalres $rextin"
done

find ./"$rextin" -depth -type d -empty -delete
echo "Empty directories deleted"

echo "Moving RES files to $modfolder/res/"
mv -fv "$resdir"/*.res "$modfolder"/res/




