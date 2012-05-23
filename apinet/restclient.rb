

#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'rest-client'

session = RestClient.get("http://127.0.0.1:4567/connect?username=tdetandt&frontend=nancy")
session = JSON.parse session
RestClient.get("http://127.0.0.1:4567/reserve?nodes=3&walltime=1&s=#{session['number']}")
command = RestClient.get("http://127.0.0.1:4567/launch?command=hostname&s=#{session['number']}")
command = JSON.parse command
puts command['result_array']

















