Class {
	#name : #JsonRPCController,
	#superclass : #Object,
	#instVars : [
		'requestHandler',
		'procedureDefinitions'
	],
	#category : #'Stargate-JSON-RPC'
}

{ #category : #'instance creation' }
JsonRPCController class >> configuredBy: configurationAction [

	| options |

	options := Dictionary new.
	configurationAction cull: options.
	^ self with: options
]

{ #category : #'instance creation' }
JsonRPCController class >> with: options [

	^self new initializeWith: options
]

{ #category : #configuring }
JsonRPCController >> configureAvailableProcedures [

	procedureDefinitions do: [ :definition | definition value: requestHandler ]
]

{ #category : #accessing }
JsonRPCController >> endpoint [

	^ self requestHandler endpoint
]

{ #category : #initialization }
JsonRPCController >> initializeWith: options [

	procedureDefinitions := options at: #procedureDefinitions.
	requestHandler := JsonRPCRequestHandler handling: ( options at: #endpoint ).
	options at: #debugMode ifPresent: [ :boolean | requestHandler debugMode: boolean ].
	options at: #errorHandlers
		ifPresent: [ :handlers | 
		handlers do: [ :errorHandler | requestHandler addErrorHandler: errorHandler ] ]
]

{ #category : #accessing }
JsonRPCController >> requestHandler [

	^ requestHandler
]

{ #category : #accessing }
JsonRPCController >> routes [

	^ Array with: ( RouteSpecification handling: #POST
			    at: self endpoint
			    evaluating: [ :httpRequest :requestContext | 
			    requestHandler process: httpRequest within: requestContext ] )
]

{ #category : #configuring }
JsonRPCController >> serverUrl: aServerUrl [

	requestHandler serverUrl: aServerUrl.
	self configureAvailableProcedures
]
