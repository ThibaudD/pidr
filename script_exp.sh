#!/bin/bash

for k in `seq 1 30`; do
	for n in 100 200 400 600 800 1000 ; do
		for w in 40 100 300 500 ; do
			for m in 0 1 2 3 ; do
				ruby taktuk.rb $n $w $m ;
			done	
			for g in 4 10 20 40 ; do
		 		ruby net_ssh_multi.rb $n $g $w ;
			done
		done
	done
done
		
