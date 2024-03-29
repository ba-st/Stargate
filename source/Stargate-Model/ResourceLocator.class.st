"
I'm responsible for locating specific resource instances and generating location urls from them
"
Class {
	#name : 'ResourceLocator',
	#superclass : 'ResourceLocatorBehavior',
	#instVars : [
		'baseUrl',
		'endpoint',
		'identifierLookupAction',
		'locationResolverBinding',
		'exceptionHandler'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
ResourceLocator class >> handling: aStringOrSymbol [

	^ self handling: aStringOrSymbol extractingIdentifierWith: [ :httpRequest | '' ]
]

{ #category : 'instance creation' }
ResourceLocator class >> handling: aStringOrSymbol calculatingLocationWith: aLocationResolver andIdentifierBy: aBlock [

	^ self
		handling: aStringOrSymbol
		resolvingLocationWith: ( Binding to: aLocationResolver )
		andIdentifierBy: aBlock
]

{ #category : 'instance creation' }
ResourceLocator class >> handling: aStringOrSymbol extractingIdentifierWith: aBlock [

	^ self
		handling: aStringOrSymbol
		resolvingLocationWith: ( Binding undefinedExplainedBy: 'Missing location resolution policy.' )
		andIdentifierBy: aBlock
]

{ #category : 'private' }
ResourceLocator class >> handling: aStringOrSymbol resolvingLocationWith: aLocationResolverBinding andIdentifierBy: aBlock [

	^ self new
		initializeHandling: aStringOrSymbol
		resolvingLocationWith: aLocationResolverBinding
		andIdentifierBy: aBlock
]

{ #category : 'accessing' }
ResourceLocator >> baseUrl [

	^ baseUrl
]

{ #category : 'accessing' }
ResourceLocator >> baseUrl: aServerUrl [

	baseUrl := aServerUrl asUrl
]

{ #category : 'testing' }
ResourceLocator >> canLookupResources [

	^ locationResolverBinding isDefined
]

{ #category : 'accessing' }
ResourceLocator >> endpoint [

	^ endpoint
]

{ #category : 'private' }
ResourceLocator >> exceptionHandler [

	^ exceptionHandler
]

{ #category : 'accessing' }
ResourceLocator >> handleExceptionsWith: anExceptionHandler [

	exceptionHandler := anExceptionHandler
]

{ #category : 'private' }
ResourceLocator >> identifierLookupAction [

	^ identifierLookupAction
]

{ #category : 'initialization' }
ResourceLocator >> initializeHandling: aStringOrSymbol resolvingLocationWith: aLocationResolverBinding andIdentifierBy: aBlock [

	baseUrl := '' asUrl.
	endpoint := '/<1s>' expandMacrosWith: aStringOrSymbol asString.
	locationResolverBinding := aLocationResolverBinding.
	identifierLookupAction := aBlock.
	exceptionHandler := RESTfulRequestExceptionHandler new
]

{ #category : 'querying' }
ResourceLocator >> locationOf: resource within: requestContext [

	^ self baseUrl / endpoint asUrl
		/ ( locationResolverBinding content cull: resource cull: requestContext ) asString asUrl
]
