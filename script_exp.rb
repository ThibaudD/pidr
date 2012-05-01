#!/usr/bin/ruby

30.times {
	[100,200,400,600,800,1000].each do |n|
		[40,100,300,500].each do |w|
			[0,1,2,3].each do |m|
				system("ruby taktuk.rb #{n} #{w} #{m}")
			end
			[4,10,20,40].each do |g|		
		 		system("ruby net_ssh_multi.rb #{n} #{g} #{w}")
			end
		end
	end
}	
