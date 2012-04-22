#!/bin/bash

for k in `seq 1 30`; do
	for n in 100 200 400 600 800 1000 ; do
		for w in 40 100 300 500 ; do
		taktuk -d -1 -w $w -l root -f /home/tdetandt/_machines_temp broadcast exec [ hostname ] ;
			for g in 4 10 20 40 ; do
		 		ruby ../net_ssh_multi.rb $n $g $w ;
			done
		done
	done
done
		
