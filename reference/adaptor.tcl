#!/usr/bin/env tclsh

#初始化cisco命令表

source ./src/sender.tcl

global records
set records {}

proc inittable { platform} {
	global records
	set fid [open ./adaptorTable/$platform/table.txt]
	set content [read $fid]
	close $fid
	set records [split $content "\n"]
}

proc translate {mycmd mylist} {
	global records
	foreach rec $records {
		set vl [string length $rec]
		if { $vl!=0 } {		
			set fields [split $rec "="]	
			if {[string compare $mycmd [lindex $fields 0]]==0} {
				set myrep [lindex $fields 1]
				set llen [llength $mylist];
				for {set x 0} {$x<$llen} {incr x} {
					regsub {<-val->} $myrep [lindex $mylist $x] myrep
				}
				return $myrep
			}
		}
	}
}

proc protocolConf {infList} {
	foreach protocol $infList {
		set commands [dict get $protocol commands]	
		foreach command $commands {
			set fields [split $command " "]
			set commandData {}
			set cmdType [lindex $fields 0]
			set llen [llength $fields]
			for {set x 1} {$x<$llen} {incr x} {
				lappend commandData [lindex $fields $x]
			}
			set cmd [translate $cmdType $commandData]
			sendCmd $cmd
			
		}
		sendCmd [translate exit {}]
	}
}

proc initPort {infList} {
#	puts $infList
	set loopback [dict get $infList loopback]
	set portConfList [dict get $infList ports-conf]
	set llen [llength $portConfList]
#循环配置每个port
	for {set x 0} {$x<$llen} {incr x} {
		set portConf [lindex  $portConfList $x]
		set portTypeList {}
		set portInfList {}
		set portType [dict get $portConf port-number]
		lappend portTypeList $portType
		lappend portInfList [dict get $portConf port-ip]
		lappend portInfList [dict get $portConf port-mask]
		set clock_rate [dict get $portConf clock-rate]
#以下用于发送命令	
#顺序如下：
#int f0/0
#ip address
#no shutdown
#exit
		if {[string compare $loopback "" ] != 0} {
			set loopbackId {}
			lappend loopbackId $loopback
			lappend loopbackId "255.255.255.0"
			sendCmd [translate intLoopback {}]
			sendCmd [translate setintip $loopbackId]
		}
		sendCmd [translate interface $portType]
		sendCmd [translate setintip $portInfList]
		if {[string compare $clock_rate "" ] != 0} {
			sendCmd [translate setclockrate $clock_rate]
		}
		sendCmd [translate setintend {}]
		sendCmd [translate exit {}]
	}	
}

proc ParserController {infList} {
	sendCmd [translate privilegedmode {}]
	set protocolInf [dict get $infList protocolInfo]
	set portInfo [dict get $infList portInfo]
	initPort $portInfo
	protocolConf $protocolInf

}

