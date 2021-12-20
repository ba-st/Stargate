Class {
	#name : #JRPCSelfContainedBlockHandler,
	#superclass : #JRPCMessageSendHandler,
	#instVars : [
		'argumentNames'
	],
	#category : #'Stargate-JSON-RPC'
}

{ #category : #'instance creation' }
JRPCSelfContainedBlockHandler class >> forProcedureNamed: aString withArgumentNames: argumentNames evaluating: aBlock [

	AssertionChecker enforce: [ aBlock argumentCount = argumentNames size ]
		because: 'The number of arguments must be consistent with the block to evaluate'
		raising: InstanceCreationFailed.

	^ self new initializeForProcedureNamed: aString withArgumentNames: argumentNames evaluating: aBlock
]

{ #category : #evaluation }
JRPCSelfContainedBlockHandler >> executeWithArguments: anArrayOrDictionary [

	| arguments |

	arguments := anArrayOrDictionary ifNil: [ #(  ) ] ifNotNil: [ 
		             anArrayOrDictionary isDictionary ifTrue: [ 
			             argumentNames collect: [ :argName | anArrayOrDictionary at: argName ] ]
			             ifFalse: [ anArrayOrDictionary ]
		             ].

	^ self send: self messageSelector to: self receiver with: arguments
]

{ #category : #initialization }
JRPCSelfContainedBlockHandler >> initializeForProcedureNamed: aString withArgumentNames: theArgumentNames evaluating: aBlock [

	self
		methodName: aString;
		receiver: aBlock.
	argumentNames := theArgumentNames collect: #asString
]

{ #category : #accessing }
JRPCSelfContainedBlockHandler >> messageSelector [

	^ #valueWithArguments:
]

{ #category : #accessing }
JRPCSelfContainedBlockHandler >> parametersNames [

	^ argumentNames
]

{ #category : #private }
JRPCSelfContainedBlockHandler >> send: aSelector to: aBlock with: arguments [

	^ super send: aSelector to: aBlock with: ( Array with: arguments )
]
