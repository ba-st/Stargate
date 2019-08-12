"
I represent a RESTful handler, and provide the base support to easily create specific controllers.
I provide the standard machinery to handle REST requests, and I'm supposed to be used from a controller.
"
Class {
	#name : #RESTfulRequestHandler,
	#superclass : #Object,
	#instVars : [
		'endpoint',
		'paginationPolicy',
		'decodingRules',
		'encodingRules',
		'entityTagCalculator',
		'locationResolverOptional',
		'baseUrl',
		'acceptNegotiator'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulRequestHandler class >> endpoint: aString
	paginationPolicy: aPaginationPolicy
	decodingRules: theDecodingRules
	encodingRules: theEncodingRules
	calculateEntityTagsWith: entityTagCalculator
	andLocationWith: aLocationResolverOptional [


	^ self new
		initializeEndpoint: aString
		paginationPolicy: aPaginationPolicy
		decodingRules: theDecodingRules
		encodingRules: theEncodingRules
		calculateEntityTagsWith: entityTagCalculator
		andLocationWith: aLocationResolverOptional
]

{ #category : #private }
RESTfulRequestHandler >> assert: etag matchesEntityTagOf: entity encodedAs: mediaType within: requestContext [

	etag = ( self entityTagOf: entity encodedAs: mediaType within: requestContext )
		ifFalse: [ HTTPClientError preconditionFailed signal ]
]

{ #category : #API }
RESTfulRequestHandler >> createResourceWith: aCreationBlock thenDo: aBlock basedOn: httpRequest within: requestContext [

	^ self
		withCreatedResourceDo: [ :representation | aBlock value: ( aCreationBlock value: representation ) ]
		basedOn: httpRequest
		within: requestContext
]

{ #category : #'decoding/encoding' }
RESTfulRequestHandler >> decode: httpRequest within: requestContext [

	| decodingRule |

	decodingRule := decodingRules
		at: httpRequest contentType
		ifAbsent: [ HTTPClientError unsupportedMediaType signal: 'Decoder not found for given media type' ].

	^ [ decodingRule cull: httpRequest contents cull: requestContext ]
		on: KeyNotFound , NeoJSONParseError
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
]

{ #category : #'decoding/encoding' }
RESTfulRequestHandler >> encode: resource to: mediaType within: requestContext [

	| encodingRule |

	encodingRule := encodingRules
		at: mediaType
		ifAbsent: [ HTTPClientError unsupportedMediaType signal: 'Encoder not found for given media type' ].

	^ encodingRule encode: resource within: requestContext
]

{ #category : #private }
RESTfulRequestHandler >> encodeResource: resource to: mediaType within: requestContext [

	^ self encode: resource to: mediaType within: requestContext
]

{ #category : #private }
RESTfulRequestHandler >> encodeResourceCollection: resourceCollection to: mediaType basedOn: httpRequest within: requestContext [

	^ self encode: resourceCollection to: mediaType within: requestContext
]

{ #category : #accessing }
RESTfulRequestHandler >> endpoint [

	^ endpoint
]

{ #category : #private }
RESTfulRequestHandler >> entityTagOf: resource encodedAs: mediaType within: requestContext [

	^ ZnETag with: ( entityTagCalculator value: resource value: mediaType value: requestContext )
]

{ #category : #private }
RESTfulRequestHandler >> entityTagToMatchBasedOn: httpRequest [

	^ ( httpRequest headers
		at: #'If-Match'
		ifAbsent: [ HTTPClientError preconditionRequired signal: 'Missing If-Match header.' ] ) asETag
]

{ #category : #private }
RESTfulRequestHandler >> evaluateQuery: aQueryEvaluationBlock [

	^ [ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
	]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError notFound signal: signal messageText ]
]

{ #category : #API }
RESTfulRequestHandler >> get: aQueryEvaluationBlock asCollectionBasedOn: httpRequest within: requestContext [

	| mediaType resourceCollection encodedResourceCollection response |

	mediaType := self targetMediaTypeFrom: httpRequest.
	resourceCollection := paginationPolicy evaluateQuery: aQueryEvaluationBlock basedOn: httpRequest.
	encodedResourceCollection := self
		encodeResourceCollection: resourceCollection
		to: mediaType
		basedOn: httpRequest
		within: requestContext.
	response := ZnResponse ok: encodedResourceCollection.
	self paginationPolicy affect: response within: requestContext.
	^ response
]

{ #category : #API }
RESTfulRequestHandler >> get: aQueryEvaluationBlock basedOn: httpRequest within: requestContext [

	| mediaType resource response |

	mediaType := self targetMediaTypeFrom: httpRequest.
	resource := self evaluateQuery: aQueryEvaluationBlock.
	self
		ifNoneMatchHeaderPresentIn: httpRequest
		do: [ :etag | 
			etag = ( self entityTagOf: resource encodedAs: mediaType within: requestContext )
				ifTrue: [ ^ ZnResponse notModified
						setEntityTag: etag;
						yourself
					]
			].
	response := ZnResponse ok: ( self encodeResource: resource to: mediaType within: requestContext ).
	self
		putEntityTagOf: resource
		encodedAs: mediaType
		in: response
		within: requestContext.
	^ response
]

{ #category : #private }
RESTfulRequestHandler >> handleConflictsIn: aBlock [

	^ aBlock
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError conflict signal: signal messageText ]
]

{ #category : #private }
RESTfulRequestHandler >> ifNoneMatchHeaderPresentIn: httpRequest do: aMonadycBlock [

	httpRequest headers at: #'If-None-Match' ifPresent: [ :ifNoneMatchHeader | aMonadycBlock value: ifNoneMatchHeader asETag ]
]

{ #category : #initialization }
RESTfulRequestHandler >> initializeEndpoint: aString
	paginationPolicy: aPaginationPolicy
	decodingRules: theDecodingRules
	encodingRules: theEncodingRules
	calculateEntityTagsWith: anEntityTagCalculator
	andLocationWith: aLocationResolverOptional [


	baseUrl := '' asUrl.
	endpoint := aString.
	paginationPolicy := aPaginationPolicy cull: self.
	decodingRules := theDecodingRules.
	encodingRules := theEncodingRules.
	acceptNegotiator := RESTfulControllerAcceptNegotiator basedOn: encodingRules keys.
	entityTagCalculator := anEntityTagCalculator.
	locationResolverOptional := aLocationResolverOptional
]

{ #category : #private }
RESTfulRequestHandler >> locationOf: resource within: requestContext [

	^ locationResolverOptional
		withContentDo: [ :resolver | 
			( resolver
				value: baseUrl
				value: endpoint
				value: resource
				value: requestContext ) asUrl
			]
		ifUnused: [ self error: 'Missing location resolution policy.' ]
]

{ #category : #private }
RESTfulRequestHandler >> paginationPolicy [

	^ paginationPolicy
]

{ #category : #private }
RESTfulRequestHandler >> putEntityTagOf: resource encodedAs: mediaType in: response within: requestContext [

	response setEntityTag: ( self entityTagOf: resource encodedAs: mediaType within: requestContext )
]

{ #category : #private }
RESTfulRequestHandler >> resourceCreationPolicyBasedOn: httpRequest [

	[ httpRequest accept ]
		on: KeyNotFound
		do: [ :signal | ^ RESTfulControllerDoNotRespondCreatedEntityPolicy for: self ].

	^ RESTfulControllerRespondCreatedEntityPolicy
		for: self
		encodedAs: ( self targetMediaTypeFrom: httpRequest )
]

{ #category : #accessing }
RESTfulRequestHandler >> serverUrl: aServerUrl [

	baseUrl := aServerUrl asUrl 
]

{ #category : #private }
RESTfulRequestHandler >> targetMediaTypeFrom: httpRequest [

	^ acceptNegotiator bestRepresentationFor: httpRequest
]

{ #category : #API }
RESTfulRequestHandler >> update: findBlock with: updateBlock basedOn: httpRequest within: requestContext [

	| etag |

	etag := self entityTagToMatchBasedOn: httpRequest.

	^ self
		get: [ | resourceToUpdate updatedResource |

			resourceToUpdate := findBlock value.
			self
				assert: etag
				matchesEntityTagOf: resourceToUpdate
				encodedAs: httpRequest contentType
				within: requestContext.
				
			updatedResource := self decode: httpRequest within: requestContext.
			self handleConflictsIn: [ updateBlock value: resourceToUpdate value: updatedResource ].
			resourceToUpdate
			]
		basedOn: httpRequest
		within: requestContext
]

{ #category : #API }
RESTfulRequestHandler >> with: findBlock do: actionBlock basedOn: httpRequest within: requestContext [

	| resource |

	resource := self evaluateQuery: findBlock.
	self handleConflictsIn: [ actionBlock value: resource ].
	^ ZnResponse noContent
]

{ #category : #API }
RESTfulRequestHandler >> withCreatedResourceDo: aBlock basedOn: httpRequest within: requestContext [

	| creationPolicy decodedRepresentation newResource |

	creationPolicy := self resourceCreationPolicyBasedOn: httpRequest.
	decodedRepresentation := self decode: httpRequest within: requestContext.
	newResource := self handleConflictsIn: [ aBlock value: decodedRepresentation ].
	^ creationPolicy responseFor: newResource basedOn: httpRequest within: requestContext
]
