Class {
	#name : #AbstractResourceLocator,
	#superclass : #Object,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #testing }
AbstractResourceLocator class >> isAbstract [

	^ self = AbstractResourceLocator
]

{ #category : #accessing }
AbstractResourceLocator >> baseUrl [

	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractResourceLocator >> baseUrl: aServerUrl [

	self subclassResponsibility
]

{ #category : #testing }
AbstractResourceLocator >> canLookupResources [

	self subclassResponsibility
]

{ #category : #accessing }
AbstractResourceLocator >> endpoint [

	^ self subclassResponsibility
]

{ #category : #private }
AbstractResourceLocator >> exceptionHandler [

	^ self subclassResponsibility
]

{ #category : #accessing }
AbstractResourceLocator >> handleExceptionsWith: anExceptionHandler [

	self subclassResponsibility
]

{ #category : #private }
AbstractResourceLocator >> identifierLookupAction [

	^ self subclassResponsibility
]

{ #category : #querying }
AbstractResourceLocator >> locationOf: resource within: requestContext [

	self subclassResponsibility
]

{ #category : #querying }
AbstractResourceLocator >> lookupResourceIdentifiedBy: httpRequest evaluating: aQueryBlock [

	^ self exceptionHandler
		handleNotFoundAndMissingParametersDuring: [ 
			| identifier |
			identifier := self identifierLookupAction cull: httpRequest.
			aQueryBlock cull: identifier
			]
]
