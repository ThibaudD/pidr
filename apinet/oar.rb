#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'net/ssh'
require 'net/ssh/multi'

class OAR
	attr_accessor :session, :nb_nodes, :walltime, :date, :command, :job_id, :nodes, :name
	
	def initialize(session,nb_nodes,walltime,year,day,month,hour,minute,second)
		@session = session
		@nb_nodes = nb_nodes
		@walltime = walltime
		@date = "#{year}-#{day}-#{month} #{hour}:#{minute}:#{second}"
		@command = "oarsub -r '#{@date}' -t allow_classic_ssh -l nodes=#{nb_nodes},walltime=#{walltime}"
	end
	
	def initialize(session,nb_nodes,walltime)
		@session = session
		@nb_nodes = nb_nodes
		@walltime = walltime	

		@session.with(:frontend).exec("date +'%G-%m-%d %H:%M:%S'") do |channel, stream, data|
                	@date = data.chomp
       		 end
        	@session.loop
		@command= "oarsub -r '#{@date}' -t allow_classic_ssh -l nodes=#{nb_nodes},walltime=#{walltime}"
	end
	
	def sub
		 @session.with(:frontend).exec("#{@command} | grep \"OAR_JOB_ID\" | cut -d '=' -f2") do |channel, stream, data|	
			@job_id = data.to_i
			channel.wait
			p @job_id
		end
		@session.loop
                @session.loop
		stat = "oarstat -fj '#{@job_id}' | grep assigned_hostnames | tr -d ' ' | cut -d '=' -f2"
                @session.with(:frontend).exec(stat) do |channel, stream, data|
                        puts "stream : #{stream}"
                        @nodes =  data.chomp.split('+')
			p @nodes
                end
                @session.loop
	end

	def getNodes
		return @nodes
	end
	
	def getJobID
		return @job_id
	end
	
	def getNbNodes
		return @nb_nodes
	end
	
	def getWalltime
		return @walltime
	end
	
	def getDate
		return @date
	end
end
