#!/bin/sh
# systemXML.tcl 
source ./src/xmlInit.tcl

set confFile "./global/system.xml"

set systemRoot [initXml $confFile]


#Return information of all Test-Unit
#return value: a list which each element in it is a dictionary consists of information about Test-Unit
#The keys in the dictionary are:
#id
#test-path
proc getTestUnits {} {
	global systemRoot
	if {[catch { set testUnitsNode [$systemRoot selectNodes /system/Test-Units] } errMsg]} {
		puts "No Test-Units node"
		error "No Test-Units node"
	}
	set units {}
	foreach testUnitNode [$testUnitsNode childNodes] {
		set unit ""
		if {[catch { set id [parseTextInfo $testUnitNode id] } errMsg]} {
			puts "No id node"
			error "No id node"	
		}
		if {[catch { set testPath [parseTextInfo $testUnitNode test-path] } errMsg]} {
			puts "No testPath node"
			error "No testPath node"
		}
		dict append unit id $id
		dict append unit test-path $testPath
		lappend units $unit
	}
	return $units
}
