#!/usr/bin/ruby

require 'rubygems'
require 'net/ssh'
require 'net/ssh/multi'

$host = "access.grid5000.fr"

class Session
	attr_accessor :username, :password, :frontend, :window_size, :session
	
	def initialize(username,password,frontend)
		@username = username
		@password = password
		@frontend = frontend
	end	
	
	def connect(window_size)
		@window_size = window_size.to_i
		@session = Net::SSH::Multi.start(:concurrent_connections => @window_size)
		@session.via($host, @username) 	
		@session.group :frontend do
			@session.use @frontend, :user => @username, :password => @password
		end
	end 
	
	def getSession
		return @session
	end
	
	def getFrontend
		return @frontend
	end
	
	def getUsername
		return @username
	end
	
	def getPassword
		return @password
	end
	
	def getWindowSize
		return @window_size
	end
end
