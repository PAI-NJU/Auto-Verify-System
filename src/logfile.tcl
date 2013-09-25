#!/bin/sh
# log.file.tcl \
exec tclsh "$0" ${1+"$@"}
set logfile ""

#create and open logfile
#filename: the file to be opened
proc openLog {filename} {
	global logfile
	set logfile [open $filename a+]
}

#write writeLog to logfile
#writeLog: the string to be writeLoged
proc writeLog {writeLog} {
	global logfile	
	puts $logfile $writeLog
}

#close logfile
proc closeLog {} {
	global logfile
	close $logfile
}

#writeLog how many tests are pass and how many tests are failure
proc recordTestResult {testCases writeLog_file} {
	global passNum 
	global failureNum
	global timeDir
    global testFile
	set filename ./TestResults/$timeDir/$writeLog_file	
	openLog $filename
	
	writeLog "TOTAL TEST:\t$testCases"
	writeLog "PASS CASES NUM:\t$passNum"
	writeLog "FAILURE CASES NUM:\t$failureNum"
	writeLog "\t"
    writeLog "\t"
	writeLog "Item\tName\tResult"
    set len [llength $testFile]
    for {set i 0} {$i < $len} { incr i} {
        set subcase [lindex $testFile $i] 
        set subcasename [lindex $subcase 0]
        set subcaseret [lindex $subcase 1]
        if {$subcaseret == 0} {
            writeLog "[expr $i+1]\t$subcasename\tPass"
        } else {
            writeLog "[expr $i+1]\t$subcasename\tFail"
        }
    }
    closeLog 
}
