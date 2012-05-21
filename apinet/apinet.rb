#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'net/ssh'
require 'net/ssh/multi'
require 'json'
require 'oar'
require 'session'

$session_array = []
$oar_array = []

get '/connect' do
	username = params[:username]
	password = params[:password]
	password="3751Gr!d"
	frontend = params[:frontend]

	session = Session.new(username,password,frontend)
	session.connect(10)

	$session_array << session
	session_number = $session_array.length-1
	session_hash = {'number' => session_number,'frontend' => frontend, 'username' => session.getUsername, 'password' => session.getPassword, 'window_size' => session.getWindowSize}

	"#{session_hash.to_json}"
end

get '/reserve' do
	nb_nodes = params[:nodes].to_i
	walltime = params[:walltime].to_i
	year = params[:y]
	day = params[:d]
	month = params[:m]
	hour = params[:H]
	minute = params[:M]
	second = params[:S]
	session_number = params[:s].to_i

	session = $session_array[session_number]

	if year==nil&&month==nil&&day==nil then
		oar = OAR.new(session.getSession,nb_nodes,walltime)
	else
		oar = OAR.new(session.getSession,nb_nodes,walltime,year,day,month,hour,minute,second)
	end

	oar.sub
	session.getSession.group :nodes do
		oar.getNodes.each do |node|
			session.getSession.use node, :user => session.getUsername, :password => session.getPassword
		end
	end	
	$oar_array << oar

	oar_hash = {'id' => oar.job_id, 'date' => oar.date, 'nb_nodes' => oar.nb_nodes, 'walltime' => oar.walltime, 'nodes' => oar.nodes}
	
	"#{oar_hash.to_json}"
end

get '/lauch' do
	command = params[:command]
	session_number = params[:s].to_i
	result = ""
	result_array = []

	session = $session_array[session_number]
	puts command
	i = 1
	session.getSession.with(:nodes).exec(command) do |channel, stream, data|
		if stream == :stdout
		then puts "Resultat : "
		     puts data
		     result_array << data	
		     result = "#{result}#node #{i}:\n#{data}\n"		
		else result =  "Error, bad command : \n #{data}"
		     puts result
		end
		i = i+1
	end
	session.getSession.loop
	
	command_hash = {'command' => command, 'result_array' => result, 'result' => result}	
	"#{command_hash.to_json}"
		
end
