"
I'm a builder of RESTful handlers
"
Class {
	#name : 'RESTfulRequestHandlerBuilder',
	#superclass : 'Object',
	#instVars : [
		'decodingRules',
		'resourceEncodingRules',
		'collectionEncodingRules',
		'paginationPolicyFactory',
		'collectionValidationPolicyFactory',
		'entityTagFactoryBinding',
		'resourceLocator',
		'exceptionHandler',
		'cachingDirectives',
		'allowedLanguageTags',
		'requestHandlerClass',
		'requestHandlerFactory'
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
    enforce: [ resourceLocator canLookupResources ] because: 'Missing location resolution.';
    enforce: [ resourceEncodingRules isEmpty and: [ collectionEncodingRules isEmpty ] ]
    because: 'Encoding rules needs to be configured after hypermedia'.
  requestHandlerClass := HypermediaDrivenRESTfulRequestHandler.
  requestHandlerFactory := [
                             requestHandlerClass
                               resourceLocator: resourceLocator
                               paginationPolicy: paginationPolicyFactory
                               collectionValidationPolicy: collectionValidationPolicyFactory
                               decodingRules: decodingRules
                               resourceEncodingRules: resourceEncodingRules
                               collectionEncodingRules: collectionEncodingRules
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

	^  requestHandlerFactory value
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createCollectionEntityTagHashing: aBlockClosure [

  self createCollectionEntityTagWith: ( self entityTagCalculatorHashing: aBlockClosure )
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createCollectionEntityTagWith: aBlock [

  collectionValidationPolicyFactory := [ :requestHandler |
                                         RESTfulControllerCalculateCollectionEntityTagsPolicy
                                           for: requestHandler
                                           calculatingWith: aBlock ]
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createEntityTagHashing: aBlockClosure [

  self createEntityTagWith: ( self entityTagCalculatorHashing: aBlockClosure )
]

{ #category : 'configuring' }
RESTfulRequestHandlerBuilder >> createEntityTagHashingEncodedCollection [

  collectionValidationPolicyFactory := [ :requestHandler |
                                         RESTfulControllerHashEncodedCollectionsPolicy for:
                                           requestHandler ]
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

{ #category : 'private' }
RESTfulRequestHandlerBuilder >> entityTagCalculatorHashing: aBlockClosure [
  "When a language was negotiated, the representation is in the current locale: the negotiated language"

  ^ [ :resource :mediaType :requestContext :requestHandler |
      | hasher |
      hasher := EntityTagHasher new.
      aBlockClosure cull: hasher cull: resource cull: requestContext.
      hasher include: mediaType.
      requestContext hasTargetLanguageTag then: [ hasher include: CurrentLocale value ].
      hasher calculateHash
    ]
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
  resourceEncodingRules := Dictionary new.
  collectionEncodingRules := Dictionary new.
  entityTagFactoryBinding := Binding undefinedExplainedBy: 'Missing ETag calculation'.
  cachingDirectives := #(  ).
  allowedLanguageTags := OrderedCollection new.
  paginationPolicyFactory := [ :requestHandler |
                               RESTfulControllerDoNotPaginateCollectionsPolicy for: requestHandler ].
  collectionValidationPolicyFactory := [ :requestHandler |
                                         RESTfulControllerDoNotValidateCollectionsPolicy for:
                                           requestHandler ].
  exceptionHandler := RESTfulRequestExceptionHandler new.
  requestHandlerClass := RESTfulRequestHandler.
  requestHandlerFactory := [
                             requestHandlerClass
                               resourceLocator: resourceLocator
                               paginationPolicy: paginationPolicyFactory
                               collectionValidationPolicy: collectionValidationPolicyFactory
                               decodingRules: decodingRules
                               resourceEncodingRules: resourceEncodingRules
                               collectionEncodingRules: collectionEncodingRules
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

{ #category : 'private' }
RESTfulRequestHandlerBuilder >> toJsonApplying: aBlock [

  ^ [ :resource :requestContext |
      self
        jsonFor: resource
        within: requestContext
        applying: aBlock
        writingResourceWith: [ :writer |
          requestHandlerClass encode: resource toJsonUsing: writer within: requestContext ]
    ]
]

{ #category : 'private' }
RESTfulRequestHandlerBuilder >> toJsonApplying: aBlock as: schema [

  ^ [ :resource :requestContext |
      self
        jsonFor: resource
        within: requestContext
        applying: aBlock
        writingResourceWith: [ :writer |
            requestHandlerClass
              encode: resource
              toJsonUsing: writer
              as: schema
              within: requestContext
          ]
    ]
]

{ #category : 'decoding' }
RESTfulRequestHandlerBuilder >> whenAccepting: aMediaType decodeApplying: aDecodingBlock [
  "aDecodingBlock will be evaluated with the request contents and optionally the request context"

  AssertionChecker
    refuse: [ decodingRules includesKey: aMediaType ]
    because: 'Decoding rule for media type already configured'.
  decodingRules at: aMediaType put: aDecodingBlock
]

{ #category : 'decoding' }
RESTfulRequestHandlerBuilder >> whenAccepting: aMediaType decodeFromJsonApplying: aBlock [

	self
		whenAccepting: aMediaType
		decodeApplying: [ :json | aBlock value: json value: ( NeoJSONReader on: json readStream ) ]
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeApplying: anEncodingBlock [

  self
    whenResponding: aMediaType
    encodeApplying: anEncodingBlock
    into: { resourceEncodingRules . collectionEncodingRules }
]

{ #category : 'private' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeApplying: anEncodingBlock into: theEncodingRuleSets [

  | encodingRule |
  theEncodingRuleSets do: [ :encodingRules |
      AssertionChecker
        refuse: [ encodingRules includesKey: aMediaType ]
        because: 'Encoding rule for media type already configured'
    ].
  encodingRule := ResourceEncodingRule encoding: aMediaType using: anEncodingBlock.
  theEncodingRuleSets do: [ :encodingRules | encodingRules at: aMediaType put: encodingRule ]
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeCollectionApplying: anEncodingBlock [

  self whenResponding: aMediaType encodeApplying: anEncodingBlock into: { collectionEncodingRules }
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeCollectionToJsonApplying: aBlock [

  self whenResponding: aMediaType encodeCollectionApplying: ( self toJsonApplying: aBlock )
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeCollectionToJsonApplying: aBlock as: schema [

  self
    whenResponding: aMediaType
    encodeCollectionApplying: ( self toJsonApplying: aBlock as: schema )
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeResourceApplying: anEncodingBlock [

  self whenResponding: aMediaType encodeApplying: anEncodingBlock into: { resourceEncodingRules }
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeResourceToJsonApplying: aBlock [

  self whenResponding: aMediaType encodeResourceApplying: ( self toJsonApplying: aBlock )
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeResourceToJsonApplying: aBlock as: schema [

  self whenResponding: aMediaType encodeResourceApplying: ( self toJsonApplying: aBlock as: schema )
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeToJsonApplying: aBlock [

  self whenResponding: aMediaType encodeApplying: ( self toJsonApplying: aBlock )
]

{ #category : 'encoding' }
RESTfulRequestHandlerBuilder >> whenResponding: aMediaType encodeToJsonApplying: aBlock as: schema [

  self whenResponding: aMediaType encodeApplying: ( self toJsonApplying: aBlock as: schema )
]
