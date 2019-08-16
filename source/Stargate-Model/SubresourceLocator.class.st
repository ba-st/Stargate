Class {
	#name : #SubresourceLocator,
	#superclass : #ResourceLocatorBehavior,
	#instVars : [
		'endpoint',
		'identifierLookupAction',
		'locationResolverBinding',
		'resourceLocator'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
SubresourceLocator class >> handling: aStringOrSymbol
	calculatingLocationWith: aLocationResolver
	andIdentifierBy: aBlock
	locatingParentResourceWith: aResourceLocator [

	^ self
		handling: aStringOrSymbol
		resolvingLocationWith: ( Binding to: aLocationResolver )
		andIdentifierBy: aBlock
		locatingParentResourceWith: aResourceLocator
]

{ #category : #'instance creation' }
SubresourceLocator class >> handling: aStringOrSymbol extractingIdentifierWith: aBlock locatingParentResourceWith: aResourceLocator [

	^ self
		handling: aStringOrSymbol
		resolvingLocationWith: ( Binding undefinedExplainedBy: 'Missing location resolution policy.' )
		andIdentifierBy: aBlock
		locatingParentResourceWith: aResourceLocator
]

{ #category : #private }
SubresourceLocator class >> handling: aStringOrSymbol
	resolvingLocationWith: aLocationResolverBinding
	andIdentifierBy: aBlock
	locatingParentResourceWith: aResourceLocator [

	^ self new
		initializeHandling: aStringOrSymbol
		resolvingLocationWith: aLocationResolverBinding
		andIdentifierBy: aBlock
		locatingParentResourceWith: aResourceLocator
]

{ #category : #accessing }
SubresourceLocator >> baseUrl: aServerUrl [

	resourceLocator baseUrl: aServerUrl
]

{ #category : #testing }
SubresourceLocator >> canLookupResources [

	^ locationResolverBinding isDefined
]

{ #category : #accessing }
SubresourceLocator >> endpoint [

	^ endpoint
]

{ #category : #accessing }
SubresourceLocator >> handleExceptionsWith: anExceptionHandler [

	resourceLocator handleExceptionsWith: anExceptionHandler
]

{ #category : #initialization }
SubresourceLocator >> initializeHandling: aStringOrSymbol
	resolvingLocationWith: aLocationResolverBinding
	andIdentifierBy: aBlock
	locatingParentResourceWith: aResourceLocator [

	resourceLocator := aResourceLocator.
	endpoint := '/<1s>' expandMacrosWith: aStringOrSymbol asString.
	locationResolverBinding := aLocationResolverBinding.
	identifierLookupAction := aBlock
]

{ #category : #querying }
SubresourceLocator >> locationOf: resource within: requestContext [

	^ ( resourceLocator locationOf: requestContext parentResource within: requestContext )
		/ endpoint asUrl
		/ ( locationResolverBinding content cull: resource cull: requestContext ) asString asUrl
]

{ #category : #querying }
SubresourceLocator >> lookupResouceIdentifiedBy: httpRequest evaluating: aQueryBlock [

	^ resourceLocator exceptionHandler
		handleNotFoundAndMissingParametersDuring: [ 
			| identifier |
			identifier := identifierLookupAction cull: httpRequest.
			aQueryBlock cull: identifier
			]
]
