package require tdom

#test cases root
set root "" 

#Load configuration information from configuration file
#return value: the root-node of the XML file
proc initXml {configFileName} {
	set root ""
	if {[catch {set configFile [open $configFileName r]} errMsg]} {
		puts "Failed to open the file for reading: $errMsg"
		return
	} else {
		set content [read $configFile]
		if {[catch {set doc [dom parse $content]} errMsg]} {
			puts "Invalid XML file"
			exit 1
		}
		set root [$doc documentElement]
	}
	return $root
}

#Parse SubNode Text information
#inside method
proc parseTextInfo {root infoName} {
	set info [$root selectNodes $infoName/text()]
	set info [$info data]
	return $info
}

#parse Node Text information
#inside method
proc parseNodeInfo { root } {
	set info [$root selectNodes text()]
	set info [$info data]
	return $info
}

#Judge whether the test cases XML file has been loaded
proc rootIsSet {} {
	global root
	if {$root == ""} {
		puts "XML has not been initialized"
		exit 1
	}
}
