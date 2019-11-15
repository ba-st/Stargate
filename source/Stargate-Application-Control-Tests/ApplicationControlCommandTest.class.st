"
An ApplicationControlCommandTest is a test class for testing the behavior of ApplicationControlCommand
"
Class {
	#name : #ApplicationControlCommandTest,
	#superclass : #TestCase,
	#category : #'Stargate-Application-Control-Tests'
}

{ #category : #tests }
ApplicationControlCommandTest >> testAccessing [

	| command |

	command := ApplicationControlCommand named: 'shutdown' executing: [ Exit signalSuccess ].

	self
		assert: command methodName equals: 'shutdown';
		assert: command parameterCount equals: 0
]
