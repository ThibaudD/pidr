#!/bin/ruby

def average(array)
	sum = 0
	for t in array do
		sum = sum + t
	end
	average = sum / array.length
end	

def ecart_type(tab)
	var = 0
	average = average(tab)
	for t in tab do
		var = var + (t - average)**2
	end	
	ecart_type = Math.sqrt(var/tab.length)
end

def confidence_interval(array)
	tmp = ecart_type(array)/Math.sqrt(array.length)
	interval1 = average(array) - 1.96*tmp
	interval2 = average(array) + 1.96*tmp
	array = [interval1,interval2]
end

folder = ARGV[0]
if folder[folder.length-1..folder.length-1]=='/'
then folder = folder[0..folder.length-2]
end

files_ls = IO.popen("ls #{folder}/*.txt")
files_ls = files_ls.readlines
node_tab = []

files_ls.each do |file|
	file_name = file.chop.gsub(/_n_[0123456789]*/,'')
        index = file.chop.index('_n_')
        num_nodes = ""
        num__ = 0
        while( num__ <= 2 ) do
                if file[index..index]=="_"
                then    num__ = num__ + 1
                else
                        num_nodes = "#{num_nodes}#{file[index..index]}"
                end
                index = index + 1
        end
        num_nodes = num_nodes[1..num_nodes.chop.length].to_i
	if node_tab.count(num_nodes) == 0
	then node_tab << num_nodes
	end
end

node_tab.sort!
new_folder =""
node_tab.each do |num|
	files = IO.popen("ls #{folder}/*_n_#{num}_*")
	files = files.readlines
	for file in files do
		o_file = File.open("#{file[0..file.length-2]}")
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
		file_name = file_name[5..file_name.length-1]	
		new_folder = "#{folder}_result"
		Dir.mkdir(new_folder) unless File.directory?(new_folder)
		new_file = File.open("#{new_folder}/#{file_name}",'a') do |f|
			f.puts("#{num_nodes} #{average(tab)} #{interval[0]} #{interval[1]}")
		end
	end
end

puts "your results are in \"#{new_folder}\""
