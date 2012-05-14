#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'net/ssh'
require 'net/ssh/multi'



get '/connect' do
	$username = params[:username]
	$password = params[:password]
	$frontend = params[:frontend]
	$host = "access.grid5000.fr"
	$session = Net::SSH::Multi.start(:concurrent_connections => 2)
	$session.via $host, $username
	$session.use $frontend, :user => $username, :password => $password
end

get '/reserve' do
	'Reserve your nodes'
	number_nodes = params[:nodes].to_i
	walltime = params[:walltime].to_i
	date = params[:date]
	hour = params[:hour]
	command = ""
	if(date!=nil)
		command= "oarsub -r #{date} nodes=#{number_nodes},walltime=#{walltime}"
	else
		command = "oarsub -I -l nodes=#{number_nodes},walltime=#{walltime}"
	end
		$session.exec("#{command} | grep \"OAR_JOB_ID\" | cut -d '=' -f2") do |channel, stream, data|
			$oar_job_id = data
		end
		puts $oar_job_id
		$session.exec("cat $OAR_NODE_FILE | uniq") do |channel, stream, data|
			puts "stream : #{stream}"
			$nodes =  data.split("\n")
		end
		$session.loop
		$session.group :nodes do
			$session.via $frontend, :user => $username, :password => $password
			$session.use $nodes, :user => $username, :password => $password
		end	
		$session.exec(command)
end

get '/lauch' do
	'Launch command'
	command = params[:command]
	puts command
	$session.with(:nodes).exec(command) do |channel, stream, data|
		if stream == :stdout
		then puts "Resultat : "
		     puts data		
			'#{data}'
		else puts "Error, bad command : \n #{data}"
		end
	end
	$session.loop
		
end

