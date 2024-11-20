#!/bin/bash

#rm old* temp* geo* g16* diagnostics dynfollowfile Echeck debug.log numFreq.txt traj isomernumber modesread runpointnumber

progdyndir=~/Software/Progdyn-main
freqfile=~/Liu/APT/FgaPT2/QCT-MD/12822-TS1-freqHP.log

$progdyndir/randgen > temp811

awk '/        1         2         3         4/,/Harmonic frequencies/ {print}' $freqfile > temp401
awk '/Frequencies --/ {print $3;print $4;print $5;print $6;print $7}' temp401 > tempfreqs
awk '/Reduced masses/ {print $4;print $5;print $6;print $7;print $8}' temp401 > tempredmass
awk '/Force constants/ {print $4;print $5;print $6;print $7;print $8}' temp401 > tempfrc
awk '/0/ && ((length($1) < 2) && ($1 < 4)) {print}' temp401 > tempmodes
awk '/has atomic number/ {print}' $freqfile > tempmasses
awk '/Standard orientation:/,/tional const/ {if (($3=="0") || (substr($3,1,2)==10)) print}' $freqfile > tempstangeos
awk '/Input orientation:/,/Stoichiometry/ {if (($3=="0") || (substr($3,1,2)==10)) print}' $freqfile > tempinputgeos
grep -c [0-9] tempfreqs > numFreq.txt
awk -f newproggenHP $freqfile > geoPlusVel

echo "1 ----trajectory isomer number----" > isomernumber

echo 1 > runpointnumber
awk -f $progdyndir/prog1stpoint isomernumber > g16_1.tmp.gjf
bash edit_g16.sh g16_1.tmp.gjf g16_1.gjf
g16 g16_1.gjf
cat isomernumber >> geoRecord
cat geoPlusVel >> geoRecord
awk -f $progdyndir/proganal g16_1.log >> dynfollowfile

echo 2 > runpointnumber
awk -f $progdyndir/prog2ndpoint g16_1.log > g16_2.tmp.gjf
bash edit_g16.sh g16_2.tmp.gjf g16_2.gjf
g16 g16_2.gjf
awk -f $progdyndir/proganal g16_2.log >> dynfollowfile
awk '/Input orientation/,/Distance matrix/ {print};/Matrix orientation/,/Stoichiometry/ {print}' g16_1.log | awk '{if (($2>.5) && ($2<100)) print}' > older
awk '/Input orientation/,/Distance matrix/ {print};/Matrix orientation/,/Stoichiometry/ {print}' g16_2.log | awk '{if (($2>.5) && ($2<100)) print}' > old

echo 3 > runpointnumber
awk -f $progdyndir/progdynb g16_2.log > g16_3.tmp.gjf
bash edit_g16.sh g16_3.tmp.gjf g16_3.gjf

for i in {3..100}
do
	j=$(echo "$i-1" | bc)
	k=$(echo "$i+1" | bc)
	g16 g16_$i.gjf
	id=$(grep -c "Normal termination" g16_$i.log)
	if [ $id -ne 1 ]
	then
		echo "ERROR" >> dynfollowfile
		exit 0
	fi
	awk -f $progdyndir/proganal g16_$i.log >> dynfollowfile
	awk '/Input orientation/,/Distance matrix/ {print};/Matrix orientation/,/Stoichiometry/ {print}' g16_$j.log | awk '{if (($2>.5) && ($2<100)) print}' > older
	awk '/Input orientation/,/Distance matrix/ {print};/Matrix orientation/,/Stoichiometry/ {print}' g16_$i.log | awk '{if (($2>.5) && ($2<100)) print}' > old
	cp runpointnumber temp533
	awk 'BEGIN {getline;i=$1+1;print i}' temp533 > runpointnumber
	awk -f $progdyndir/progdynb g16_$i.log > g16_$k.tmp.gjf
	bash edit_g16.sh g16_$k.tmp.gjf g16_$k.gjf
done

