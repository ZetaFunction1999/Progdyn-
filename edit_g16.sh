#!/bin/bash

Multiwfn $1 <<EOF
100
2
2
tmp.xyz
0
q
EOF

sed "1,2 d" tmp.xyz | awk '{print " " $1}' > tmp.ele
sed "1,2 d" tmp.xyz | sed "s/^[A-Z] //g" > tmp.coor

grep -v "tcheck" $1 | head | sed "s/#.*/#P oniom(M062X\/6-31g(d) empiricaldispersion=gd3:external='gau_xtb.sh') force scf=nosym geom=printinputorient/g" > $2
paste tmp.ele frozen.info tmp.coor oniom.info -d "" >> $2
echo -e "\n\n" >> $2

rm tmp.ele tmp.coor tmp.xyz

