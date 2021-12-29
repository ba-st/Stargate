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
		assert: command parameterCount equals: 0;
		assert: command parameterNames isEmpty
]

{ #category : #tests }
ApplicationControlCommandTest >> testCannotCreateUnnamed [

	self should: [ ApplicationControlCommand named: '' executing: [ self fail ] ]
		raise: InstanceCreationFailed
		withMessageText: 'Cannot create an unnamed command'
]

{ #category : #tests }
ApplicationControlCommandTest >> testCannotCreateWhenArgumentCountIsMismatched [

	self
		should: [ ApplicationControlCommand named: 'echo' executing: [ :message | self fail ] ]
		raise: InstanceCreationFailed
		withMessageText: 'The number of parameter names doesn''t match the block arity';
		should: [ 
			ApplicationControlCommand named: 'echo' withArgumentNames: #( message ) executing: [ self fail ] ]
		raise: InstanceCreationFailed
		withMessageText: 'The number of parameter names doesn''t match the block arity';
		should: [ 
			ApplicationControlCommand named: 'echo'
				withArgumentNames: #( message async )
				executing: [ :message | self fail ]
			]
		raise: InstanceCreationFailed withMessageText:
			'The number of parameter names doesn''t match the block arity'
]
