#!/usr/bin/env tclsh

source ./src/adaptorXML.tcl

proc translateTest {mydict} {
	set extensive [dict get $mydict protocol]
	set commands [dict get $mydict commands]
	set dicts [getAdaptorInfo $extensive]
	set dictKey [dict keys $dicts]
	set commandList {}
	foreach key $dictKey {
		    set myrep [dict get $dicts $key]
		foreach command $commands {
			set myList [split $command " "]
			set llen [llength $myList]
			set flag [lindex $myList 0]
			if {[string compare $key $flag]==0} {
				for {set x 1} {$x<$llen} {incr x} {
					regsub val $myrep [lindex $myList $x] myrep			
				}
			}
		}
		lappend commandList $myrep
	}
	return $commandList

}

proc initTest {testStr} {
	
	dict append myDict protocol $testStr
	dict append myDict commands " "
	return [translateTest $myDict]	
}
