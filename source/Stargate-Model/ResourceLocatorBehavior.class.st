Class {
	#name : 'ResourceLocatorBehavior',
	#superclass : 'Object',
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'accessing' }
ResourceLocatorBehavior >> baseUrl [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
ResourceLocatorBehavior >> baseUrl: aServerUrl [

	self subclassResponsibility
]

{ #category : 'testing' }
ResourceLocatorBehavior >> canLookupResources [

	self subclassResponsibility
]

{ #category : 'accessing' }
ResourceLocatorBehavior >> endpoint [

	^ self subclassResponsibility
]

{ #category : 'private' }
ResourceLocatorBehavior >> exceptionHandler [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
ResourceLocatorBehavior >> handleExceptionsWith: anExceptionHandler [

	self subclassResponsibility
]

{ #category : 'private' }
ResourceLocatorBehavior >> identifierLookupAction [

	^ self subclassResponsibility
]

{ #category : 'querying' }
ResourceLocatorBehavior >> locationOf: resource within: requestContext [

	self subclassResponsibility
]

{ #category : 'querying' }
ResourceLocatorBehavior >> lookupResourceIdentifiedBy: httpRequest evaluating: aQueryBlock [

	^ self exceptionHandler
		handleNotFoundAndMissingParametersDuring: [ 
			| identifier |
			identifier := self identifierLookupAction cull: httpRequest.
			aQueryBlock cull: identifier
			]
]
