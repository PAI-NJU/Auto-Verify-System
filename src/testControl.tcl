
source "./src/sender.tcl"
#step1:get dictionary
#step2:send test command
#step3:check if the result is true
#step4:writeLog the test result
set resultStr ""
proc testControl {testInfo testUnit_id eid} {
	global resultStr
	set resultStr ""
	global timeDir
	set name [dict get $testInfo name]
	set id [dict get $testInfo equip-id]
	set testCmds [dict get $testInfo testCommands]	
	
	set connectInfo [getConnectorInfo $id]
	set ip [dict get $connectInfo ip]
	set dev_name [dict get $connectInfo name]
	set passwd [dict get $connectInfo pwd]
	writeLog "TEST EQUIPMENT ID:$id"
	writeLog "TEST EQUIPMENT INFO:$ip  $dev_name/$passwd"
    set ret 0
    set tmp_logfile [open ./log/$timeDir/$testUnit_id/dev_$eid.log a+]	
    foreach cmdsInfo $testCmds {
	set resultStr ""
	set command [dict get $cmdsInfo command]
	set expectStrs [dict get $cmdsInfo expects]
		writeLog "\r"
        writeLog "COMMAND: $command"
        puts "##########testcommand $command ###############"
			sendTestCmd $command
	set i 0
	set flag 0
	
	foreach expectStr $expectStrs {
	set i [expr $i+1]
	set isPass [test $i $name $expectStr $resultStr]
	if {$isPass==1} {
		
	} else {
		set flag 1
		
	}
	}
	if {$flag==1} {
	writeLog "\r"
    writeLog "ACTUAL RESULT: $resultStr"
    writeLog "-----------------------------------------------------"
	incr ret  
	writeLog "TEST RESULT :FAILURE"
	} else {
		writeLog "TEST RESULT :PASS"
	}
    puts $tmp_logfile $resultStr
    }
	writeLog "\r"
	writeLog "\r"
	writeLog "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    close $tmp_logfile
    return $ret
}
 
#check if testStr contains stdStr
#resultStr: the result get from the machine
proc test {id testname expectStr resultStr} {
	
	if {[regexp $expectStr $resultStr]>0} {
		return 1
	} else {
		writeLog "FAILURED TEST POINT $id:   EXPECT RESULT: $expectStr"
		return 0
	}
}
 
 
 
 
 
 
