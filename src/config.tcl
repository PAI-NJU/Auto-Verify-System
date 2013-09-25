#!/bin/sh
#config.tcl \
exec tclsh "$0" ${1+"$@"}
source ./src/sender.tcl

proc configEquip { confcmds } {

	set loops [dict get $confcmds loops]
	if {[string compare $loops ""] !=0 } {
		configLoop $loops
	}
	
	
	set cmds [dict get $confcmds commands]
	foreach cmd $cmds {
		if {[catch {sendCmdDelay [dict get $cmd command] [dict get $cmd delay] } errorMsg]} {
			error $errorMsg
		}
	}
	set delay [dict get $confcmds delay ]
	if {[catch {sendCmdDelay "\r" $delay} errorMsg]} {
		error $errorMsg
	}
}

proc configLoop { loops } {
	foreach loop $loops { 
		set count [dict get $loop count]
		set lcommands [dict get $loop lcommands]
		for {set x 1} {$x<=$count} {incr x} {
			foreach lcommand $lcommands {
				set delay [dict get $lcommand delay]
				set step [dict get $lcommand step]
				set command [dict get $lcommand command]
				set result [checkCommand $command]
				if { $result == 1} {
					set firstStart [string first "\[" $command ]
					set firstEnd [string first "\]" $command ]
					set firstStart1 [expr $firstStart + 1]
					set firstEnd1 [expr $firstEnd - 1]
					set originIndex [string range $command $firstStart1 $firstEnd1]
					set lastStr [string range $command [expr $firstEnd + 1] [string length $command]]
					set isOnlyOne [checkCommand $lastStr]
					if { $isOnlyOne == 1 } {
						error "Error : permit only one parameter!!!!"
					} else {
						set nowIndex [expr $step * ($x - 1)]
						set originIndex [expr $originIndex - 0]
						set newIndex [expr $nowIndex + $originIndex]
						set newCommand [string replace $command $firstStart $firstEnd $newIndex]
						if {[catch {sendCmdDelay $newCommand $delay} errorMsg]} {
							error $errorMsg
						}
					}
				} else {
					if {[catch {sendCmdDelay $command $delay} errorMsg]} {
						error $errorMsg
					}
				}
			
			}
		}
	}
}

proc checkCommand { command } {
	set firstStart [string first "\[" $command ]
	set firstEnd [string first "\]" $command ]
		
	if {$firstStart != -1} {
		if { $firstEnd != -1 } {
#			
			return 1
		} else {
			return 0
		}
	} else {
		return 0
	}
}
