#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'net/ssh'


get '/connect' do
	$username = params[:username]
	$password = params[:password]
	$frontend = params[:frontend]
	host = "access.grid5000.fr"
		
end

get '/reserve' do
	'Reserve your nodes'
	nodes = params[:nodes]
	walltime = params[:walltime]
	date = params[:date]
	hour = params[:hour]
	command = "oarsub nodes=#{nodes},walltime=#{walltime}"
	if(date=="")
		command
	Net::SSH.start(host, $username, :password => $password) do |ssh|
		ssh.via $host, :user => $username, :password => $password
		ssh.exec("oarsub nodes=#{nodes},walltime=#{walltime}")
end
