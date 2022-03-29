#!/bin/bash

# Set up some variables
source=$1         #e.g., SGRJ1818.0-1607
date=$2           # obsdate
obsnum=$3         #e.g., 420000
id=$4             #e.g., 0002
band=$5           #e.g., Sband
dmc=$6            #e.g., 706 pc cm-3
#numout=$7         # for total obs from chooseN.py

# Set directories
HOME=/data/GBT/Magnetars/
WORKDIR=$HOME/${source}/data/${date}/${band}/
OUTDIR=$HOME/${source}/data/${date}/${band}/out/
DATADIR=$WORKDIR/fits/

#analysis
mkdir -p $OUTDIR

cd $WORKDIR
pwd
cp /home/sms33/pulsar/ACCEL_sift.py .

ds=8
dDM=1
numdms=100
lower=50
lodm=$(expr $dmc - $lower)
#totalpoints=$(expr $numout / $ds)

echo $(date)

echo "rfifind"
rfifind -time 2.0 -o ${source}_${band} $DATADIR/vegas_*${obsnum}_*_${id}_000?.fits

echo "prepsubband"
prepsubband -downsamp $ds -numdms $numdms -dmstep $dDM -nsub 256 -lodm $lodm -mask $WORKDIR/${source}_${band}_rfifind.mask -o $OUTDIR/${source}_${band} $DATADIR/vegas_*${obsnum}_*_${id}_000?.fits

cd $OUTDIR

echo "accelsearch"
ls *.dat | xargs -n 1 accelsearch -zmax 0

echo "ACCEL sift"
python ../ACCEL_sift.py > ../cands.txt

ls *.dat
wait 60

echo "single pulse search"
single_pulse_search.py *.dat

mkdir ACCEL
mkdir singlepulse
mkdir dat
mkdir inf

mv *_ACCEL* ACCEL/
mv *.singlepulse singlepulse/
mv *.dat dat/
mv *.inf inf/

echo "done"
