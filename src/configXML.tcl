package require tdom

source ./src/xmlInit.tcl

#Get the number of testCases
#return value: the number of testCases
proc getTestCasesNumber {} {
	global root
	rootIsSet
	if {[catch { set testCases [$root selectNodes /testCases] } errMsg]} {
		puts "No testCases node"
		error "No testCases node"
	}
	set count 0
	foreach testCase [$testCases childNodes] {
		incr count
	}
    puts "##### getTestCasesNumber $count #####"
	return $count
}

#Get the protocol information about the equipment you want to config 
#id: the index of the equipment
#testCaseIndex: the index of TestCase in TestCases
#return value: a list consists of dictionaries which include protocol configuration information 
#these dictionaries have two keys:
#protocol: the name of the protocol
#commands: a list consists of all configuration commands
proc getConfCmds {id testCaseIndex} {
	global root
	rootIsSet
    set index 0

	set confInfos ""
	if {[catch { set testCase [$root selectNodes /testCases/testCase] } errMsg]} {
		puts "No testCase node"
		error "No testCase node"
	}
	set testCase [lindex $testCase $testCaseIndex]
	if {[catch { set equips [$testCase selectNodes equipments/equipment] } errMsg]} {
		puts "No equipment node"
		error "No equipment node"
	}
	
	foreach equip $equips {
		if {[catch { set equipId [parseTextInfo $equip equip-id] } errMsg]} {
			puts "No equip-id node"
			error "No equip-id node"
		}
        incr index
		if {$index == $id} {
			set gdelay 0
			
			if {[catch {set gdelay [$equip selectNodes delay]} errMsg]} {
			   set gdelay 0

			}
			if {$gdelay == 0 || $gdelay == ""} {
			
				set sdelay 0
			} else {
				if {[catch { set sdelay [parseNodeInfo $gdelay] } errMsg]} {
					set sdelay 0
				}
			}
			
			set loops {}
			   foreach loopNode [$equip selectNodes loop] {
				   set lcommands {}
				   set count 0
				   if {[catch {set count [$loopNode getAttribute count]} errMsg]} {
						set count 0
					}
				   foreach commandNode [$loopNode childNodes] {
					   set lcmd {}
				   set delay 0
				   set step 0
				   if {[catch {set delay [$commandNode getAttribute delay]} errMsg]} {
					set delay 0
				      }
				   if {[catch {set step [$commandNode getAttribute step]} errMsg]} {
					set step 0
				      }
				   set loop [parseNodeInfo $commandNode]
					   dict append lcmd delay $delay
					   dict append lcmd step $step
					   dict append lcmd command $loop
					   lappend lcommands $lcmd
				   }
				   dict append loopd count $count
				   dict append loopd lcommands $lcommands
				   lappend loops $loopd
			   }
			
			
				if {[catch { set commandsNode [$equip selectNodes conf-commands] } errMsg]} {
					puts "No conf-commands node"
					error "No conf-commands node"
				}
				set commands {}
			        
				if {[catch {$commandsNode childNodes} errMsg]} {
					puts "Equipment $id lacks protocol commands"
					exit 1
				}
				foreach commandNode [$commandsNode childNodes] {
					set delay 0
					set dcmd ""
					if {[catch {set delay [$commandNode getAttribute delay]} errMsg]} {
							set delay 0
						}
					
					set command [parseNodeInfo $commandNode]
	
					dict append dcmd delay $delay 
					dict append dcmd command $command
					
					lappend commands $dcmd
				}
			       dict append conf_commands loops $loops
			       dict append conf_commands commands $commands
			       dict append conf_commands delay $sdelay
					return $conf_commands
			}
		}
}
