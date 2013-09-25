#!/bin/sh
# equipXML.tcl 
source ./src/xmlInit.tcl

set confFile "./global/equipment.xml"

set equip_root [initXml $confFile]

#Get the connection information about the equipments
#id: the id of the connection information which you want to get
#return value: a dictionary, include equip-id、platform、ip、name、pwd
proc getConnectorInfo {id} {
	global equip_root
	rootIsSet
	if {[catch { set equips [$equip_root selectNodes /equipments/equipment] } errMsg]} {
		puts "No equipment node"
		error "No equipment node"
	}
	set equip ""
	set info ""
	foreach equip $equips {
		if {[catch { set equipId [parseTextInfo $equip equip-id] } errMsg]} {
			puts "No equip-id node"
			error "No equip-id node"
		}
		if {$equipId == $id} {
			if {[catch { set connectorInfo [$equip selectNodes connector-info] } errMsg]} {
				puts "No connector-info node"
				error "No connector-info node"
			}
			set ip [parseTextInfo $connectorInfo ip]
			
			if {[catch {set tname [$connectorInfo selectNodes name]} errMsg]} {
			   set tname ""
			}
			if {[catch {set tpwd [$connectorInfo selectNodes pwd]} errMsg]} {
			   set tpwd ""
			}
			if {$tname == ""} {
				set name ""
			} else {
				set name [parseNodeInfo $tname]
			}
			if {$tpwd == ""} {
				set pwd ""
			} else {
				set pwd [parseNodeInfo $tpwd]
			}

			dict append info equip-id $equipId
			dict append info ip $ip
			dict append info name $name
			dict append info pwd $pwd
			
			break
		}
	}
	return $info
}


#Get the number of the equipments which need to be connected
#testCaseIndex: the index of TestCase in TestCases
#return value: the number of the equipments which need to be connected
proc getEquipNumber { testCaseIndex } {
	global root
	rootIsSet
	if {[catch { set testCase [$root selectNodes /testCases/testCase] } errMsg]} {
		puts "No testCase node"
		error "No testCase node"
	}
	set testCase [lindex $testCase $testCaseIndex]
	if {[catch { set equipments [$testCase selectNodes equipments] } errMsg]} {
		puts "No equipments node"
		error "No equipments node"
	}
	set count 0
	foreach child [$equipments childNodes] {
		incr count
	}
	return $count
}


#Get the ids of equipments
#testCaseIndex: the index of TestCase in TestCases
#return value: a list consists of ids
proc getTestEquipIds { testCaseIndex } {
	global root
	rootIsSet
	if {[catch { set testCase [$root selectNodes /testCases/testCase] } errMsg]} {
		puts "No testCase node"
		error "No testCase node"
	}
	set testCase [lindex $testCase $testCaseIndex]
	if {[catch { set equips [$testCase selectNodes equipments/equipment] } errMsg]} {
		puts "No equipment node"
		error "No equipment node"
	}
	set ids {}
	foreach equip $equips {
		set equipId [parseTextInfo $equip equip-id]
		lappend ids $equipId
	}
	return $ids
}
