#!/bin/ruby

def average(tab)
	sum = 0
	for t in tab do
		sum = sum + t
	end
	average = sum / tab.length
end	

def ecart_type(tab)
	var = 0
	average = average(tab)
	for t in tab do
		var = var + (t - average)**2
	end	
	ecart_type = Math.sqrt(var/tab.length)
end

def confidence_interval(tab)
	tmp = ecart_type(tab)/Math.sqrt(tab.length)
	interval1 = average(tab) - 1.96*tmp
	interval2 = average(tab) + 1.96*tmp
	tab = [interval1,interval2]
end

files = IO.popen("ls test")
files = files.readlines

for file in files do
	o_file = File.open("test/#{file[0..file.length-2]}")
	tab = []
	res = 0
	o_file.each_line{ |line|
			tab << line.to_f
			}
	interval = confidence_interval(tab)

	file_name = file.chop.gsub(/_n_[0123456789]*/,'')
	index = file.chop.index('_n_')
	num_nodes = ""
	num__ = 0
	while( num__ <= 2 ) do
		if file[index..index]=="_"
		then	num__ = num__ + 1
		else
			num_nodes = "#{num_nodes}#{file[index..index]}"
		end
		index = index + 1
	end
	num_nodes = num_nodes[1..num_nodes.chop.length]
	puts num_nodes
	
	new_file = File.open("test2/#{file_name}",'a') do |f|
		f.puts("#{num_nodes} #{average(tab)} #{interval[0]} #{interval[1]}")
	end
	
	p average(tab)
	p confidence_interval(tab)
end
