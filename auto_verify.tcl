#!/bin/sh
# auto_verify.tcl 

source ./src/control.tcl
source ./src/systemXML.tcl
source ./src/testControl.tcl
source ./src/logfile.tcl
#get all test units from system.xml
set testUnitDict [getTestUnits]

set result ""

set rootpath [pwd]

set nowpath ""

set testCases 0

set passNum 0
set failureNum 0

set testFile ""

set systemTime [clock seconds]
set timeDir [clock format $systemTime -format "%y_%m_%d_%H_%M"]
# main entrance
proc start {} {
    puts "Starting the test ......"
	global testUnitDict
	global result
	global rootpath
	global testCases
	global timeDir
	foreach unit $testUnitDict {
		set testId [dict get $unit id]
		set timeDir $testId/$timeDir
		file mkdir ./TestResults/$timeDir
		set path [dict get $unit test-path]
		#set fullpath "./$path"
		FindFile $path $result $testId 0
		cd $rootpath
		
	}	
	set systemTime [clock seconds]
	set testResultPath TotalResult.xls
	
	recordTestResult $testCases $testResultPath
}

proc FindFile { myDir result testId isRecurse} {
	if { $isRecurse == 1} {
	set li [split $myDir "/"] 
	set length [llength $li] 
	set nowDir [lindex $li [expr $length - 1]]
	} else {
	
		set nowDir $myDir
	}
	set li ""
	set length ""
	global testCases
	global rootpath
	global nowpath
	
	if {[file isdirectory $nowDir]} {
		cd $nowDir
		
 	#go through files or directories under myDir
 	#if is a directory, recurse 
 	#if is a file, start auto verify
 	foreach myfile [glob -nocomplain *] {
		
 		#if myDir is empty, do nothing
 		if {[string equal $myfile ""]} {
			puts "Directory is empty!"
 			return
 		}
 		set fullfile [file join $myDir $myfile]
 		if {[file isdirectory $myfile]} {
			FindFile $fullfile $result $testId 1
 		} else {
			 if { [regexp { *.xml$} $myfile] } {
			 puts "start verify"
			 set nowpath [pwd]
			 cd $rootpath
			verify $fullfile "$myfile"
			 cd $nowpath
			 }
 		}	
	}
		
	} else {
		set li [split $myDir "/"] 
		set length [llength $li] 
		set myfile [lindex $li [expr $length - 1]]
		if { [regexp { *.xml$} $myfile] } {			
			set nowpath [pwd]
			cd $rootpath
			verify $myDir "$myfile"
			cd $nowpath
		}
	}
	if { $isRecurse == 1 } {
	cd ..
	}
	incr testCases
}

start
