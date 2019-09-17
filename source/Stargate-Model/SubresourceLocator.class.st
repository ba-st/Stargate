"
I'm responsible for locating specific subresource instances and generating location urls from them
"
Class {
	#name : #SubresourceLocator,
	#superclass : #ResourceLocatorBehavior,
	#instVars : [
		'endpoint',
		'identifierLookupAction',
		'locationResolverBinding',
		'resourceLocator',
		'exceptionHandler'
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
SubresourceLocator >> baseUrl [

	^ resourceLocator baseUrl
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

{ #category : #private }
SubresourceLocator >> exceptionHandler [

	^ exceptionHandler
]

{ #category : #accessing }
SubresourceLocator >> handleExceptionsWith: anExceptionHandler [

	exceptionHandler := anExceptionHandler
]

{ #category : #private }
SubresourceLocator >> identifierLookupAction [

	^ identifierLookupAction
]

{ #category : #initialization }
SubresourceLocator >> initializeHandling: aStringOrSymbol
	resolvingLocationWith: aLocationResolverBinding
	andIdentifierBy: aBlock
	locatingParentResourceWith: aResourceLocator [

	resourceLocator := aResourceLocator.
	endpoint := '/<1s>' expandMacrosWith: aStringOrSymbol asString.
	locationResolverBinding := aLocationResolverBinding.
	identifierLookupAction := aBlock.
	exceptionHandler := RESTfulRequestExceptionHandler new
]

{ #category : #querying }
SubresourceLocator >> locationOf: resource within: requestContext [

	^ ( resourceLocator locationOf: requestContext parentResource within: requestContext )
		/ endpoint asUrl
		/ ( locationResolverBinding content cull: resource cull: requestContext ) asString asUrl
]
