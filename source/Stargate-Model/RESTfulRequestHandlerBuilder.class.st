"
I'm a builder of RESTful handlers
"
Class {
	#name : #RESTfulRequestHandlerBuilder,
	#superclass : #Object,
	#instVars : [
		'endpointBinding',
		'decodingRules',
		'encodingRules',
		'locationResolver',
		'paginationPolicyFactory',
		'entityTagFactoryBinding',
		'handlerFactory'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> beHypermediaDriven [

	^ self beHypermediaDrivenBy: [ #() ]
]

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> beHypermediaDrivenBy: aMediaControlsFactoryBlock [

	locationResolver withContentDo: [  ] ifUnused: [ self error: 'Missing location resolution.' ].
	handlerFactory := [ HypermediaDrivenRESTfulRequestHandler
		endpoint: endpointBinding content
		paginationPolicy: paginationPolicyFactory
		decodingRules: decodingRules
		encodingRules: encodingRules
		calculateEntityTagsWith: entityTagFactoryBinding content
		andLocationWith: locationResolver
		drivenBy: [ :resource :requestContext :resourceLocation | 
			OrderedCollection new
				add: 'self' -> resourceLocation;
				addAll: ( aMediaControlsFactoryBlock cull: resource cull: requestContext cull: resourceLocation );
				asArray
			]
	]
]

{ #category : #building }
RESTfulRequestHandlerBuilder >> build [

	^  handlerFactory value
]

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> calculateLocationUsing: aBlockClosure [

	locationResolver := Optional
		containing:
			[ :baseUrl :endpoint :resource :requestContext | baseUrl / endpoint asUrl / ( aBlockClosure cull: resource cull: requestContext ) asString asUrl ]
]

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> createEntityTagHashing: aBlockClosure [

	self
		createEntityTagWith: [ :resource :mediaType :requestContext | 
			| hasher |
			hasher := EntityTagHasher new.
			aBlockClosure cull: hasher cull: resource cull: requestContext.
			hasher
				include: mediaType;
				calculateHash
			]
]

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> createEntityTagWith: aBlock [

	entityTagFactoryBinding := Binding to: aBlock
]

{ #category : #decoding }
RESTfulRequestHandlerBuilder >> decodeFrom: aMediaType jsonUsing: aBlock [

	self
		decodeFrom: aMediaType
		using: [ :json | aBlock value: json value: ( NeoJSONReader on: json readStream ) ]
]

{ #category : #decoding }
RESTfulRequestHandlerBuilder >> decodeFrom: aMediaType using: aDecodingBlock [

	"aDecodingBlock will be evaluated with the request contents and optionally the request context"

	decodingRules
		at: aMediaType
		ifPresent: [ :rule | 'Decoding rule for media type already configured' expandMacrosWith: aMediaType ]
		ifAbsentPut: [ aDecodingBlock ]
]

{ #category : #decoding }
RESTfulRequestHandlerBuilder >> decodeToNeoJSONObject: aMediaType [

	self decodeFrom: aMediaType using: [ :json | NeoJSONObject fromString: json ]
]

{ #category : #encoding }
RESTfulRequestHandlerBuilder >> encodeTo: aMediaType jsonUsing: aBlock [

	self
		encodeTo: aMediaType
		using: [ :resource :requestContext | 
			String
				streamContents: [ :stream | 
					| writer |

					writer := NeoJSONWriter on: stream.
					aBlock value: resource value: requestContext value: writer.
					writer
						for: ResourceCollection
						do: [ :mapping | 
							mapping
								mapInstVar: #items;
								mapAsHypermediaControls: [ :collection | requestContext hypermediaControlsFor: collection items ]
							].
					writer nextPut: resource
					]
			]
]

{ #category : #encoding }
RESTfulRequestHandlerBuilder >> encodeTo: aMediaType using: anEncodingBlock [

	encodingRules
		at: aMediaType
		ifPresent: [ self error: 'Encoding rule for media type already configured' ]
		ifAbsentPut: [ ResourceEncodingRule encoding: aMediaType using: anEncodingBlock ]
]

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> endpoint: aStringOrSymbol [

	endpointBinding := Binding to: ( '/<1s>' expandMacrosWith: aStringOrSymbol asString )
]

{ #category : #initialization }
RESTfulRequestHandlerBuilder >> initialize [

	super initialize.
	decodingRules := Dictionary new.
	encodingRules := Dictionary new.
	endpointBinding := Binding undefinedExplainedBy: 'Missing endpoint'.
	entityTagFactoryBinding := Binding undefinedExplainedBy: 'Missing ETag calculation'.
	paginationPolicyFactory := [ :requestHandler | RESTfulControllerDoNotPaginateCollectionsPolicy for: requestHandler ].	"Location don't need to be resolved unless we're using an hypermedia policy or we intend to create new resources.
	For read-only controllers it's useless"
	locationResolver := Optional unused. 
	handlerFactory := [ RESTfulRequestHandler
		endpoint: endpointBinding content
		paginationPolicy: paginationPolicyFactory
		decodingRules: decodingRules
		encodingRules: encodingRules
		calculateEntityTagsWith: entityTagFactoryBinding content
		andLocationWith: locationResolver
	]
]

{ #category : #configuring }
RESTfulRequestHandlerBuilder >> paginateCollectionsWithDefaultLimit: anInteger [

	paginationPolicyFactory := [ :processor | RESTfulControllerPaginateCollectionsPolicy for: processor with: anInteger ]
]
