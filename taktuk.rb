#!/usr/bin/ruby

$tab_host = []
machines=File.open("../machines","r")
machines.each do |ligne|
	$tab_host << ligne.chomp
end

def proc(nb_machines,window_size,mode)
	puts("Debut")
	t = Time.now.to_f	
	
	temp = File.open("_machines_temp","w")
	nb_machines.times do |node|
		temp.write($tab_host[node] + "\n")
	end
	temp.close
	if mode == 0 then	
		system("taktuk -d -1 -w #{window_size} -l root -f /home/anagel/_machines_temp broadcast exec [ hostname ]")
	else if mode == 1 then
		system("taktuk -s -d -1 -w #{window_size} -l root -f /home/anagel/_machines_temp broadcast exec [ hostname ]")
	else if mode == 2 then
		system("taktuk -n -d -1 -w #{window_size} -l root -f /home/anagel/_machines_temp broadcast exec [ hostname ]")
	else if mode == 3 then
		system("taktuk -n -s -d -1 -w #{window_size} -l root -f /home/anagel/_machines_temp broadcast exec [ hostname ]")
	end
	t = Time.now.to_f - t
	myFile = File.open("temps_taktuk_n_#{nb_machines}_w_#{window_size}_m_#{mode}.txt","w")
	myFile.write(t.to_s + "\n")
	myFile.close
	puts("end")
end

proc(ARGV[0], ARGV[1],ARGV[2])
