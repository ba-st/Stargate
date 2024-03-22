Class {
	#name : 'StargateApplicationStackTraceDumperTest',
	#superclass : 'TestCase',
	#category : 'Stargate-API-Skeleton-Tests',
	#package : 'Stargate-API-Skeleton-Tests'
}

{ #category : 'accessing' }
StargateApplicationStackTraceDumperTest class >> defaultTimeLimit [

	^5 minute
]

{ #category : 'running' }
StargateApplicationStackTraceDumperTest >> setUp [

	super setUp.
	StargateApplication logsDirectory ensureCreateDirectory
]

{ #category : 'tests - application' }
StargateApplicationStackTraceDumperTest >> testStackTraceDumper [

	| dumper result |

	dumper := PetStoreApplication new stackTraceDumper.

	result := [ 1 / 0 ] on: ZeroDivide
		          do: [ :zeroDivide | 
			          dumper dumpStackTraceFor: zeroDivide.
			          zeroDivide return: 5
			          ].
	self assert: result equals: 5
]
