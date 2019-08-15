Class {
	#name : #ResourceLocator,
	#superclass : #Object,
	#instVars : [
		'baseUrl',
		'endpoint',
		'identifierLookupAction',
		'locationResolverBinding'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
ResourceLocator class >> handling: aStringOrSymbol calculatingLocationWith: aLocationResolver andIdentifierBy: aBlock [

	^ self
		handling: aStringOrSymbol
		resolvingLocationWith: ( Binding to: aLocationResolver )
		andIdentifierBy: aBlock
]

{ #category : #'instance creation' }
ResourceLocator class >> handling: aStringOrSymbol extractingIdentifierWith: aBlock [

	^ self
		handling: aStringOrSymbol
		resolvingLocationWith: ( Binding undefinedExplainedBy: 'Missing location resolution policy.' )
		andIdentifierBy: aBlock
]

{ #category : #private }
ResourceLocator class >> handling: aStringOrSymbol resolvingLocationWith: aLocationResolverBinding andIdentifierBy: aBlock [

	^ self new
		initializeHandling: aStringOrSymbol
		resolvingLocationWith: aLocationResolverBinding
		andIdentifierBy: aBlock
]

{ #category : #accessing }
ResourceLocator >> baseUrl: aServerUrl [

	baseUrl := aServerUrl asUrl
]

{ #category : #testing }
ResourceLocator >> canLookupResources [

	^ locationResolverBinding isDefined
]

{ #category : #accessing }
ResourceLocator >> endpoint [

	^ endpoint
]

{ #category : #initialization }
ResourceLocator >> initializeHandling: aStringOrSymbol resolvingLocationWith: aLocationResolverBinding andIdentifierBy: aBlock [

	baseUrl := '' asUrl.
	endpoint := '/<1s>' expandMacrosWith: aStringOrSymbol asString.
	locationResolverBinding := aLocationResolverBinding.
	identifierLookupAction := aBlock
]

{ #category : #querying }
ResourceLocator >> locationOf: resource within: requestContext [

	^ baseUrl / endpoint asUrl
		/ ( locationResolverBinding content cull: resource cull: requestContext ) asString asUrl
]

{ #category : #querying }
ResourceLocator >> lookupResouceIdentifiedBy: httpRequest evaluating: aQueryBlock [

	^ [ [ 
			| identifier |
			identifier := identifierLookupAction cull: httpRequest.
			aQueryBlock cull: identifier
		]
			on: TeaNoSuchParam
			do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
		]
			on: ObjectNotFound
			do: [ :signal | HTTPClientError notFound signal: signal messageText ]
]
