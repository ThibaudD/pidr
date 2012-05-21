#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'rest-client'


session = RestClient.get("http://127.0.0.1:4567/connect?username=tdetandt&frontend=nancy")
session = JSON.parse session
puts "username #{session['username']}"
puts session['number']

oar = RestClient.get("http://127.0.0.1:4567/reserve?nodes=3&walltime=1&s=#{session['number']}")
oar = JSON.parse oar
puts oar['nodes']

command = RestClient.get("http://127.0.0.1:4567/lauch?command=hostname&s=#{session['number']}")
command = JSON.parse command
puts command['result_array']
