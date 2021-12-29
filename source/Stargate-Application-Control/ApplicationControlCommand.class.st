"
I model an application control command. 
I must be configured with a command name and an action block to be executed when the command is activated.
"
Class {
	#name : #ApplicationControlCommand,
	#superclass : #Object,
	#instVars : [
		'methodName',
		'actionBlock',
		'parameterNames'
	],
	#category : #'Stargate-Application-Control'
}

{ #category : #'instance creation' }
ApplicationControlCommand class >> named: aMethodName executing: aBlockClosure [

	^ self named: aMethodName withArgumentNames: #(  ) executing: aBlockClosure
]

{ #category : #'instance creation' }
ApplicationControlCommand class >> named: aMethodName withArgumentNames: argumentNames executing: aBlockClosure [

	AssertionCheckerBuilder new
		raising: InstanceCreationFailed;
		checking: [ :asserter | 
			asserter
				enforce: [ aMethodName notEmpty ] because: 'Cannot create an unnamed command';
				enforce: [ argumentNames size = aBlockClosure argumentCount ]
				because: 'The number of parameter names doesn''t match the block arity'
			];
		buildAndCheck.


	^ self new initializeNamed: aMethodName withArgumentNames: argumentNames executing: aBlockClosure
]

{ #category : #configuring }
ApplicationControlCommand >> addTo: aJsonRPCRequestHandler [

	aJsonRPCRequestHandler addHandlerNamed: methodName
		withArgumentNames: parameterNames
		evaluating: actionBlock
]

{ #category : #initialization }
ApplicationControlCommand >> initializeNamed: aMethodName withArgumentNames: theArgumentNames executing: aBlockClosure [

	methodName := aMethodName.
	parameterNames := theArgumentNames.
	actionBlock := aBlockClosure
]

{ #category : #accessing }
ApplicationControlCommand >> methodName [

	^ methodName
]

{ #category : #accessing }
ApplicationControlCommand >> parameterCount [

	^ parameterNames size
]

{ #category : #accessing }
ApplicationControlCommand >> parameterNames [

	^ parameterNames
]
