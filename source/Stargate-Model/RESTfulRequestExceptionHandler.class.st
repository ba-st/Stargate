"
I'm an exception handler to be used while handling a RESTful HTTP request
"
Class {
	#name : #RESTfulRequestExceptionHandler,
	#superclass : #Object,
	#instVars : [
		'exceptionsToHandle'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #configuring }
RESTfulRequestExceptionHandler >> addAsConflictError: anExceptionSelector [

	exceptionsToHandle at: #conflict put: ( exceptionsToHandle at: #conflict ) , anExceptionSelector
]

{ #category : #configuring }
RESTfulRequestExceptionHandler >> addAsDecodingError: anExceptionSelector [

	exceptionsToHandle
		at: #decodingFailed
		put: ( exceptionsToHandle at: #decodingFailed ) , anExceptionSelector
]

{ #category : #configuring }
RESTfulRequestExceptionHandler >> addAsMissingQueryParameterError: anExceptionSelector [

	exceptionsToHandle
		at: #missingQueryParameters
		put: ( exceptionsToHandle at: #missingQueryParameters ) , anExceptionSelector
]

{ #category : #configuring }
RESTfulRequestExceptionHandler >> addAsNotFoundError: anExceptionSelector [

	exceptionsToHandle at: #notFound put: ( exceptionsToHandle at: #notFound ) , anExceptionSelector
]

{ #category : #configuring }
RESTfulRequestExceptionHandler >> addAsUnprocessableEntityError: anExceptionSelector [

	exceptionsToHandle at: #unprocessableEntity put: ( exceptionsToHandle at: #unprocessableEntity ) , anExceptionSelector
]

{ #category : #handling }
RESTfulRequestExceptionHandler >> handleConflictsDuring: aBlock [

	^ aBlock
		on: ( exceptionsToHandle at: #conflict )
		do: [ :signal | HTTPClientError conflict signal: signal messageText ]
]

{ #category : #handling }
RESTfulRequestExceptionHandler >> handleDecodingFailedDuring: aBlock [

	^ [ 
	  aBlock
		  on: ( exceptionsToHandle at: #decodingFailed )
		  do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
	  ]
		  on: ( exceptionsToHandle at: #unprocessableEntity )
		  do: [ :signal | HTTPClientError unprocessableEntity signal: signal messageText ]
]

{ #category : #handling }
RESTfulRequestExceptionHandler >> handleMissingQueryParametersDuring: aBlock [

	^ aBlock
		on: ( exceptionsToHandle at: #missingQueryParameters )
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
]

{ #category : #handling }
RESTfulRequestExceptionHandler >> handleNotFoundAndMissingParametersDuring: aBlock [

	^ self handleNotFoundDuring: [ self handleMissingQueryParametersDuring: aBlock ]
]

{ #category : #handling }
RESTfulRequestExceptionHandler >> handleNotFoundDuring: aBlock [

	^ aBlock
		on: ( exceptionsToHandle at: #notFound )
		do: [ :signal | HTTPClientError notFound signal: signal messageText ]
]

{ #category : #initialization }
RESTfulRequestExceptionHandler >> initialize [

	super initialize.
	exceptionsToHandle := SmallDictionary new.
	exceptionsToHandle
		at: #conflict put: ConflictingObjectFound;
		at: #notFound put: ObjectNotFound;
		at: #decodingFailed put: KeyNotFound , NeoJSONParseError;
		at: #missingQueryParameters put: TeaNoSuchParam;
		at: #unprocessableEntity put: InstanceCreationFailed
]
