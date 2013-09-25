#proc sendCmd {cmd} {

global spawnId

#send command to the machine
#cmd:the command sent to the machine
proc sendCmd { cmd} {
	global spawnId
	global results
	global expect_out buffer
#	set send_slow {10 .01}
	if [catch {set spawn_id $spawnId} err] {   
	       puts "ERROR !! set spawn_id fail"   
	       return 0
	   }
	   
	   if [catch {exp_pid -i $spawn_id} err] {      
	       puts "ERROR !! set spawn_id fail"  
	       return 0
	   }
	
	set timeout 60
	send  "$cmd\r"
	expect { 
		timeout { 
			puts "timeout" 
			exit 			
		}
		"#"	{
			
			append buffer $expect_out(buffer)			
		}
		"More"  {
			    append buffer $expect_out(buffer)
			    send   " "
			    exp_continue
			  }
		"more"  {
					   
					    append buffer $expect_out(buffer)
					    send   " "
					    exp_continue
					  }
	}
}
#send command to the machine
#cmd:the command sent to the machine
proc sendCmdDelay { cmd delay} {
    global spawnId
	global results
	global expect_out buffer
	if [catch {set spawn_id $spawnId} err] {   
	       puts "ERROR !! set spawn_id fail"   
	       return 0
	   }
	   
	   if [catch {exp_pid -i $spawn_id} err] {      
	       puts "ERROR !! set spawn_id fail"  
	       return 0
	   }
	
	set timeout 60
	send  "$cmd\r"
    after [expr $delay*1000]
	expect { 
		timeout { 
			puts "timeout" 
			exit 			
		}
		"\#"	{
			
			append buffer $expect_out(buffer)	
		}
		"More"  {
			    append buffer $expect_out(buffer)
			    send   " "
			    exp_continue
			  }
		"more"  {
					   
					    append buffer $expect_out(buffer)
					    send   " "
					    exp_continue
					  }
		"%"{
		append buffer $expect_out(buffer)
		}
	}
	send "   \n"
	expect "\#"
	append buffer $expect_out(buffer)
}
proc sendTestCmd { cmd} {
	global spawnId
	global resultStr
	global expect_out buffer
	if [catch {set spawn_id $spawnId} err] {   
	       puts "ERROR !! set spawn_id fail"   
	       return 0
	   }
	   
	   if [catch {exp_pid -i $spawn_id} err] {      
	       puts "ERROR !! set spawn_id fail"  
	       return 0
	   }
	
	set timeout 60
	send  "$cmd\r"
	
	expect  { 
		timeout { 
			puts "timeout!!!!" 
			exit 			
		}
		"\#"	{
			
			append resultStr $expect_out(buffer)			
		}
		"More"  {
			    append resultStr $expect_out(buffer)
			    send   " "
			    exp_continue
			  }
		"more"  {
					   
					    append resultStr $expect_out(buffer)
					    send   " "
					    exp_continue
					  }
		"%"     {
			append resultStr $expect_out(buffer)	
		}
	}
	
	send "   \n"
	expect "\#"
	append resultStr "$expect_out(buffer)"
}
