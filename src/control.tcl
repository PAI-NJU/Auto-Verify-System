package require Expect
source ./src/configXML.tcl
source ./src/testXML.tcl
source ./src/testControl.tcl
source ./src/logfile.tcl
source ./src/equipXML.tcl
source ./src/config.tcl
global expect_out buffer
set buffer ""
set expect_out(buffer) ""
set results ""
global spawnId
set spawnId ""
#the configuration information of route
global configinfo()  

#set up connection with machine
proc connect {  username password } {
	global expect_out buffer
	global spawnId
	
	if [catch {set spawn_id $spawnId} err] {   
	       puts "ERROR !! set spawn_id fail"  
	       return 0
	   }
	   
	   if [catch {exp_pid -i $spawn_id} err] {      
	       puts "ERROR !! set spawn_id fail"  
	       return 0
	   }
	   
	set timeout 60
	if { $username != ""} {
		send   "$username\r"
	}
	if { $password != ""} {
		send   "$password\r"
	}
	send  "enable\r"
	if { $password != ""} {
        send   "$password\r"
	}
	expect -i $spawn_id "#"
	append buffer $expect_out(buffer)
    set buffer ""
}

#backup 
proc backupinfo { id } {
	global spawnId
	global expect_out buffer
	global configinfo
	set configinfo($id) ""
	if [catch {set spawn_id $spawnId} err] {   
		       puts "ERROR !! set spawn_id fail"   
		       return 0
		   }
		   
		   if [catch {exp_pid -i $spawn_id} err] {      
		       puts "ERROR !! set spawn_id fail"  
		       return 0
		   }
	send "copy running-config startup-config\r"
	send "\r"
	send "\r"
	after 1000
	set timeinitExpectout 60
	expect { 
			timeout { 
				puts "timeout"
                exp_close -i $spawn_id 
				exit 			
			}
			"#"	{
				
				append configinfo($id) $expect_out(buffer)			
			}
			"More"  {
				   
				    append configinfo($id) $expect_out(buffer)
				    send   " "
				    exp_continue
				  }
			"more"  {
						   
						    append configinfo($id) $expect_out(buffer)
						    send   " "
						    exp_continue
						  }
		}
}

proc recoverinfo { id } {
	global spawnId
	global expect_out buffer
	global configinfo
	
	if [catch {set spawn_id $spawnId} err] {   
			       puts "ERROR !! set spawn_id fail"   
			       return 0
			   }
			   
			   if [catch {exp_pid -i $spawn_id} err] {      
			       puts "ERROR !! set spawn_id fail"  
			       return 0
			   }
		   
	send "copy startup-config running-config\r"
	send "\r"
	send "\r"
	send "\r"
	set timeout 60
	expect { 
			timeout { 
				puts "timeout"
                exp_close -i $spawn_id 
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
	
	send "exit\r"
}

proc clearInfo { } {
	global spawnId
	global expect_out buffer
	if [catch {set spawn_id $spawnId} err] {   
		       puts "ERROR !! set spawn_id fail"   
		       return 0
		   }
		   
	if [catch {exp_pid -i $spawn_id} err] {      
		puts "ERROR !! set spawn_id fail"  
		return 0
	}
	
	
	set confile [open ./global/config.txt r]
	while {[gets $confile cmd]} {
        if {[string first "#" $cmd] >= 0} {
			continue
		}
		send "$cmd\r"
	    after 200	
	}
    close $confile
	return 0
}

proc findClearId {clearList id} {
    set len [llength $clearList]
    
    if {$len == 0} {
        return 1
    }

    for {set i 0} {$i < $len} {incr i} {
        if {$id == [lindex $clearList $i]} {
            return 0
        }
    }
    return 1

}

proc verify { testCase_path  testUnit_id } {
	global expect_out buffer
	global spawnId
	global root
	global testFile 
	global timeDir
    global passNum
    global failureNum
    global resultStr
	set buffer ""
	set expect_out(buffer) ""
	set results ""
	set results $buffer
	set root [initXml $testCase_path]
    set ret 0 

	file mkdir ./log/$timeDir/$testUnit_id

	set testCaseNum [getTestCasesNumber]
    set clear 0
    set clearList ""
    

	for { set caseCount 0 } { $caseCount < $testCaseNum } { incr caseCount } {
		set ids [getTestEquipIds $caseCount]
        set index 0
		foreach id $ids {
			set connectInfo [getConnectorInfo $id]
			set ip [dict get $connectInfo ip]
			set name [dict get $connectInfo name]
			set passwd [dict get $connectInfo pwd]
			spawn telnet $ip
		    set spawnId $spawn_id
			connect  $name $passwd
            incr index
		    #backupinfo $id
			#This will be removed until 10.1 support copy startup-config running-config
            if {$clear == 0} {
                if {[findClearId $clearList $id]} { 
			        clearInfo
                    lappend clearList $id
                }
            }
			set confCmds [getConfCmds $index $caseCount]  
			configEquip  $confCmds
		
			set results $buffer
			set buffer ""
			openLog ./log/$timeDir/$testUnit_id/dev_$id.log
			writeLog $results
			closeLog
			exp_close -i $spawnId
		}
        incr clear
	
		set count [getTestNumber $caseCount]
		set filename "./TestResults/$timeDir/$testUnit_id\.log"	
		openLog $filename
		for {set i 0} {$i < $count} {incr i} {
		    
			set commands [getTestCommands $i $caseCount]
			set eid [dict get $commands equip-id]
			set connectInfo [getConnectorInfo $eid]
			set ip [dict get $connectInfo ip]
			set name [dict get $connectInfo name]
			set passwd [dict get $connectInfo pwd]
			spawn telnet $ip
			set spawnId $spawn_id
			connect $name $passwd
			if {[testControl $commands $testUnit_id $eid] == 1} {
                incr ret
            }
			set buffer ""
			exp_close -i $spawnId
		}
        closeLog
	}

    if {$ret == 0} {
        incr passNum
    } else {
        incr failureNum
    }
    lappend testFile [list $testCase_path $ret]
    	
#	set ids [getTestEquipIds ]
#	foreach id $ids {
#			set connectInfo [getConnectorInfo $id]
#			set ip [dict get $connectInfo ip]
#			set name [dict get $connectInfo name]
#			set passwd [dict get $connectInfo pwd]
#			spawn telnet $ip
#			set spawnId $spawn_id
#			connect  $name $passwd
#		#recoverinfo $id
#		exp_close -i $spawnId
#		}
	
	
	
}


