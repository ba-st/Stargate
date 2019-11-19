"
I model an application control command. 
I must be configured with a command name and an action block to be executed when the command is activated.
"
Class {
	#name : #ApplicationControlCommand,
	#superclass : #Object,
	#instVars : [
		'methodName',
		'actionBlock'
	],
	#category : #'Stargate-Application-Control'
}

{ #category : #'instance creation' }
ApplicationControlCommand class >> named: aMethodName executing: aBlockClosure [

	AssertionChecker
		enforce: [ aMethodName notEmpty ]
		because: 'Cannot create an unnamed command'
		raising: InstanceCreationFailed.

	^ self new initializeNamed: aMethodName executing: aBlockClosure
]

{ #category : #configuring }
ApplicationControlCommand >> addTo: aJsonRPCRequestHandler [

	aJsonRPCRequestHandler addHandlerNamed: methodName evaluating: actionBlock
]

{ #category : #initialization }
ApplicationControlCommand >> initializeNamed: aMethodName executing: aBlockClosure [

	methodName := aMethodName.
	actionBlock := aBlockClosure
]

{ #category : #accessing }
ApplicationControlCommand >> methodName [

	^ methodName
]

{ #category : #accessing }
ApplicationControlCommand >> parameterCount [

	^ actionBlock argumentCount
]
