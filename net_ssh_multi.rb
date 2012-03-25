#!/usr/bin/ruby
require 'rubygems'
$: << "#{ENV['HOME']}/.gem/ruby/1.8/gems/net-ssh-multi-1.1/lib"
$: << "#{ENV['HOME']}/.gem/ruby/1.8/gems/net-ssh-gateway-1.1.0/lib"
$: << "#{ENV['HOME']}/.gem/ruby/1.8/gems/net-ssh-2.3.0/lib"

require 'net/ssh'
require 'net/ssh/multi'
#system("cat $OAR_FILE_NODES | uniq | tee machines")
$tab_host = []

machine = File.open("machines",'r')
machine.each do |ligne|
        $tab_host << ligne.chomp
end

$resultat = File.open("_temps_net_ssh","a")

def connect(i)
	tdeb = Time.now
	Net::SSH::Multi.start(:concurrent_connections =>80) do |session|
		
		nbGateway = 10
		session.via $tab_host[0].to_s, 'root', :paranoid => Net::SSH::Verifiers::Null.new
		for k in nbGateway..i/nbGateway do
			session.use $tab_host[k].to_s, :user => "root", :paranoid => Net::SSH::Verifiers::Null.new, :via => nil
		end
		
		for j in 2..nbGateway do
			session.via $tab_host[j-1].to_s, 'root', :paranoid => Net::SSH::Verifiers::Null.new
			for k in i/nbGateway+1..i*j/nbGateway do
				session.use $tab_host[k].to_s, :user => "root", :paranoid => Net::SSH::Verifiers::Null.new, :via => nil
			end
		end
		session.exec "hostname"
	end
	tfin = Time.now
	tdiff = tfin -tdeb
	puts(tdiff.to_s)
	$resultat.write(tdiff.to_s+"\n")
end

connect(1000)
$resultat.close

