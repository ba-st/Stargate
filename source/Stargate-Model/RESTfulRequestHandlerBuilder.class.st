"
I'm a builder of RESTful handlers
"
Class {
	#name : 'RESTfulRequestHandlerBuilder',
	#superclass : 'Object',
	#instVars : [
		'decodingRules',
		'encodingRules',
		'paginationPolicyFactory',
		'entityTagFactoryBinding',
		'handlerFactory',
		'resourceLocator',
		'exceptionHandler',
		'cachingDirectives',
		'allowedLanguageTags'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> addAsSupportedLanguage: aLanguageTag [

	allowedLanguageTags add: aLanguageTag asLanguageTag
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> beHypermediaDriven [

	self beHypermediaDrivenBy: [  ]
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> beHypermediaDrivenBy: aMediaControlsFactoryBlock [

	AssertionChecker
		enforce: [ resourceLocator canLookupResources ]
		because: 'Missing location resolution.'.
	handlerFactory := [ HypermediaDrivenRESTfulRequestHandler
		resourceLocator: resourceLocator
		paginationPolicy: paginationPolicyFactory
		decodingRules: decodingRules
		encodingRules: encodingRules
		calculateEntityTagsWith: entityTagFactoryBinding content
		cachingDirectives: cachingDirectives
		allowedLanguageTags: allowedLanguageTags
		drivenBy: [ :builder :resource :requestContext :resourceLocation | 
			builder addAsSelfLink: resourceLocation.
			aMediaControlsFactoryBlock
				cull: builder
				cull: resource
				cull: requestContext
				cull: resourceLocation.
			builder build
			]
		handleErrorsWith: exceptionHandler
	]
]

{ #category : 'building' }
RESTfulRequestHandlerBuilder >> build [

	^  handlerFactory value
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createEntityTagHashing: aBlockClosure [

	self
		createEntityTagWith: [ :resource :mediaType :requestContext :requestHandler | 
			| hasher |
			hasher := EntityTagHasher new.
			aBlockClosure cull: hasher cull: resource cull: requestContext.
			hasher
				include: mediaType;
				calculateHash
			]
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createEntityTagHashingEncodedResource [

	self
		createEntityTagWith: [ :resource :mediaType :requestContext :requestHandler | 
			EntityTagHasher new
				include: ( requestHandler encodeResource: resource as: mediaType within: requestContext );
				calculateHash
			]
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createEntityTagWith: aBlock [

	entityTagFactoryBinding := Binding to: aBlock
]

{ #category : 'decoding' }
RESTfulRequestHandlerBuilder >> decodeToNeoJSONObjectWhenAccepting: aMediaType [

	self whenAccepting: aMediaType decodeApplying: [ :json | NeoJSONObject fromString: json ]
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> directCachingWith: aBlock [

	cachingDirectives := CachingDirectivesBuilder new
		configureUsing: aBlock;
		build
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> handleExceptionsApplying: aBlock [

	aBlock value: exceptionHandler
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> handling: anEndpoint [

	resourceLocator := ResourceLocator handling: anEndpoint
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> handling: anEndpoint extractingIdentifierWith: aBlock [

	resourceLocator := ResourceLocator handling: anEndpoint extractingIdentifierWith: aBlock
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> handling: anEndpoint extractingIdentifierWith: aBlock locatingParentResourceWith: aResourceLocator [

	resourceLocator := SubresourceLocator
		handling: anEndpoint
		extractingIdentifierWith: aBlock
		locatingParentResourceWith: aResourceLocator
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> handling: anEndpoint locatingResourcesWith: aLocationBlock extractingIdentifierWith: aBlock [

	resourceLocator := ResourceLocator
		handling: anEndpoint
		calculatingLocationWith: aLocationBlock
		andIdentifierBy: aBlock
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> handling: anEndpoint locatingSubresourcesWith: aLocationBlock extractingIdentifierWith: aBlock locatingParentResourceWith: aResourceLocator [

	resourceLocator := SubresourceLocator
		handling: anEndpoint
		calculatingLocationWith: aLocationBlock
		andIdentifierBy: aBlock
		locatingParentResourceWith: aResourceLocator
]

{ #category : 'initialization' }
RESTfulRequestHandlerBuilder >> initialize [

	super initialize.
	decodingRules := Dictionary new.
	encodingRules := Dictionary new.
	entityTagFactoryBinding := Binding undefinedExplainedBy: 'Missing ETag calculation'.
	cachingDirectives := #().
	allowedLanguageTags := OrderedCollection new.
	paginationPolicyFactory := [ :requestHandler | RESTfulControllerDoNotPaginateCollectionsPolicy for: requestHandler ].
	exceptionHandler := RESTfulRequestExceptionHandler new.
	handlerFactory := [ RESTfulRequestHandler
		resourceLocator: resourceLocator
		paginationPolicy: paginationPolicyFactory
		decodingRules: decodingRules
		encodingRules: encodingRules
		calculateEntityTagsWith: entityTagFactoryBinding content
		cachingDirectives: cachingDirectives
		allowedLanguageTags: allowedLanguageTags
		handleErrorsWith: exceptionHandler
	]
]

{ #category : 'private' }
RESTfulRequestHandlerBuilder >> jsonFor: resource within: requestContext applying: aBlock writingResourceWith: aResourceWritingBlock [

	^ String streamContents: [ :stream | 
		  | writer |
		  writer := NeoJSONWriter on: stream.
		  aBlock value: resource value: requestContext value: writer.
		  aResourceWritingBlock value: writer
		  ]
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> paginateCollectionsWithDefaultLimit: anInteger [

	paginationPolicyFactory := [ :processor | RESTfulControllerPaginateCollectionsPolicy for: processor with: anInteger ]
]

{ #category : 'decoding' }
RESTfulRequestHandlerBuilder >> whenAccepting: aMediaType decodeApplying: aDecodingBlock [

	"aDecodingBlock will be evaluated with the request contents and optionally the request context"

	decodingRules
		at: aMediaType
		ifPresent: [ :rule | 'Decoding rule for media type already configured' expandMacrosWith: aMediaType ]
		ifAbsentPut: [ aDecodingBlock ]
]

{ #category : 'decoding' }
RESTfulRequestHandlerBuilder >> whenAccepting: aMediaType decodeFromJsonApplying: aBlock [

	self
		whenAccepting: aMediaType
		decodeApplying: [ :json | aBlock value: json value: ( NeoJSONReader on: json readStream ) ]
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeApplying: anEncodingBlock [

	encodingRules
		at: aMediaType
		ifPresent: [ self error: 'Encoding rule for media type already configured' ]
		ifAbsentPut: [ ResourceEncodingRule encoding: aMediaType using: anEncodingBlock ]
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeToJsonApplying: aBlock [

	self whenResponding: aMediaType encodeApplying: [ :resource :requestContext | 
		self
			jsonFor: resource
			within: requestContext
			applying: aBlock
			writingResourceWith: [ :writer | 
				writer for: ResourceCollection do: [ :mapping | 
					mapping
						mapInstVar: #items;
						mapAsHypermediaControls: [ :collection | 
							requestContext hypermediaControlsFor: collection items ]
					].
				writer nextPut: resource
				]
		]
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeToJsonApplying: aBlock as: schema [

	self whenResponding: aMediaType encodeApplying: [ :resource :requestContext | 
		self
			jsonFor: resource
			within: requestContext
			applying: aBlock
			writingResourceWith: [ :writer | 
				writer
					for: ResourceCollection do: [ :mapping | 
						( mapping mapInstVar: #items ) valueSchema: #ResourceCollectionItems.
						mapping mapAsHypermediaControls: [ :collection | 
								requestContext hypermediaControlsFor: collection items ]
						];
					for: #ResourceCollectionItems customDo: [ :mapping | mapping listOfElementSchema: schema ].

				[ writer nextPut: resource as: schema ]
					unless: ( resource isA: ResourceCollection )
					inWhichCase: [ writer nextPut: resource ]
				]
		]
]
