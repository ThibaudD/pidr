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
	$session.exec("date +'%G-%m-%d %H:%M:%S'") do |channel, stream, data|
		date = data.chomp
	end
	$session.loop
	p date
	hour = params[:hour]
	command = ""
		command= "oarsub -r '#{date}' -t allow_classic_ssh -l nodes=#{number_nodes},walltime=#{walltime}"
	p command

#		$session.exec("#{command} | grep \"Connect to OAR job\" | cut -d ' ' -f9") do |channel, stream, data|
		$session.exec("#{command} | grep \"OAR_JOB_ID\" | cut -d '=' -f2") do |channel, stream, data|
#$session.exec(command) do |channel,stream,data|
			puts stream
			$oar_job_id = data.to_i
		end
		$session.loop
		$session.exec("sleep 9")
		$session.loop
		p $oar_job_id

		stat = "oarstat -fj '#{$oar_job_id}' | grep assigned_hostnames | tr -d ' ' | cut -d '=' -f2"
		$session.exec(stat) do |channel, stream, data|
			puts "stream : #{stream}"
			$nodes =  data.chomp.split('+')
		end
		$session.loop
		puts "test"
		p $nodes
		$session.loop
		$session.group :nodes do
			$nodes.each do |node|
				$session.use node, :user => $username, :password => $password
			end
		end	
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

