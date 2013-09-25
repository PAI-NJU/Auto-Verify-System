#!/bin/sh
# adaptorXML.tcl 
source src/configXML.tcl

set adaptorRoot ""

#initAdaptor
proc initAdaptor {platform} {
	global adaptorRoot
	set adaptorFileName "./adaptorTable/$platform/testTable.xml"
	set adaptorRoot [initXml $adaptorFileName]
}

#Return the information of the adaptor table
#protocolName: the name of the protocol you want to adapt to
#return value: a dictionary that contains all commands of the protocol in the adaptor table
proc getAdaptorInfo {protocolName} {
	global adaptorRoot
	set adaptorInfo ""
	foreach protocol [$adaptorRoot childNodes] {
		set origin [parseTextInfo $protocol origin]
		if {$origin == $protocolName} {
			set commandsNode [$protocol selectNodes commands]
			foreach command [$commandsNode childNodes] {
				set flag [$command getAttribute flag]
				set command [$command selectNodes text()]
				set command [$command data]
				dict append adaptorInfo $flag $command
			}
			break
		}
	}
	return $adaptorInfo
}