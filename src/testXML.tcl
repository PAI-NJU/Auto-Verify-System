#This part is used for test. Before you use methods in this part, please load config.tcl first
package require tdom
source src/xmlInit.tcl

#Get the number of tests
#return value: the number of tests
proc getTestNumber { testCaseIndex } {
	global root
	rootIsSet
	if {[catch { set tests [$root selectNodes /testCases/testCase/tests] } errMsg]} {
		puts "No tests node"
		error "No /testCases/testCase/tests node"
	}
	set tests [lindex $tests $testCaseIndex]
	set count 0
	if {[catch {$tests childNodes} errMsg]} {
		puts "lacks tests tag"
		exit 1
	}
	foreach child [$tests childNodes] {
		
		incr count
	}
	return $count
}

#Get the test commands of the testcase
#return value: a dictionary that has three keys:
#equip-id: the id of the equipment you want to test
#commands: a list consists of all test commands
#expects: the expect results
proc getTestCommands {index testCaseIndex} {
	global root
	rootIsSet
	if {[catch { set tests [$root selectNodes /testCases/testCase/tests] } errMsg]} {
		puts "No tests node"
		error "No /testCases/testCase/tests node"
	}
	set tests [lindex $tests $testCaseIndex]
	if {[catch { set tests [$tests selectNodes test] } errMsg]} {
		puts "No test node"
		error "No test node"
	}
	set test [lindex $tests $index]
	if {[catch {set name [$test getAttribute name]} errMsg]} {
			set name ""
		}
	dict append testInfo name $name
	if {[catch {set equip_id [parseTextInfo $test equip-id]} errMsg]} {
		puts "Tests lacks equip-id information"
		exit 1
	}
	dict append testInfo equip-id $equip_id
	set testCommands {}
	
	foreach testNode [$test selectNodes test-command] {
		if {[catch { set expectsNode [$testNode selectNodes expects] } errMsg]} {
			puts "No expects node"
			error "No expects node"
		}
		set expects {}
		set testCommand {}
		if {[catch {$expectsNode childNodes} errMsg]} {
			puts "Test $index lacks test/expects tag"
			exit 1
		}
		foreach expectNode [$expectsNode childNodes] {
			set expect [parseNodeInfo $expectNode]
			lappend expects $expect
		}
		dict append testCommand expects $expects
	
		if {[catch { set commandNode [$testNode selectNodes command] } errMsg]} {
			puts "No command node"
			error "No command node"
		}
		set command [parseNodeInfo $commandNode]
	
		dict append testCommand command $command
		lappend testCommands $testCommand
	}
	dict append testInfo testCommands $testCommands
	return $testInfo
}
