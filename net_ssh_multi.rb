#!/usr/bin/ruby
require 'rubygems'
$: << "#{ENV['HOME']}/.gem/ruby/1.8/gems/net-ssh-multi-1.1/lib"
$: << "#{ENV['HOME']}/.gem/ruby/1.8/gems/net-ssh-gateway-1.1.0/lib"
$: << "#{ENV['HOME']}/.gem/ruby/1.8/gems/net-ssh-2.3.0/lib"

require 'net/ssh'
require 'net/ssh/multi'

if ARGV.length != 3
	puts "usage : net_ssh_multi.rb nombre_noeuds nombre_gateway nombre_connexion"
	Process.exit
end

$tab_host = []
machine = File.open("../machines",'r')
machine.each do |ligne|
        $tab_host << ligne.chomp
end

nb_machines = ARGV[0]
nb_gateways = ARGV[1]
window_size = ARGV[2]
nom = "temps_net_ssh_multi_n_#{nb_machines}_g_#{nb_gateways}_w_#{window_size}.txt"
$resultat = File.open(nom,"a")

def connect(i,gateway,window)
	tdeb = Time.now
	Net::SSH::Multi.start(:concurrent_connections =>window) do |session|
		
		nbGateway = gateway
		if nbGateway != 0 
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
		else
			for k in 0..i do
				session.use $tab_host[k].to_s, :user => "root", :paranoid => Net::SSH::Verifiers::Null.new
			end
		end
		
		session.exec "hostname"
	end
	tfin = Time.now
	tdiff = tfin -tdeb
	puts(tdiff.to_s)
	$resultat.write(tdiff.to_s+"\n")
end

connect(nb_machines.to_i, nb_gateways.to_i,window_size.to_i)
$resultat.close

