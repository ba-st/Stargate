"
I represent a RESTful Web Service, and provide the base support to easily create specific services.

I provide a way to encode/decode the resources into the representations produced/consumed by the service.

I also provide standard error handling and templates for processing the differente HTTP verbs.
"
Class {
	#name : #ResourceRESTfulController,
	#superclass : #Object,
	#instVars : [
		'mappingRuleSet',
		'baseUrlOptional',
		'acceptNegotiator',
		'paginationPolicy',
		'hypermediaPolicy',
		'resourceCreationPolicy'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'private - asserting' }
ResourceRESTfulController >> assert: etag matchesEntityTagOf: entity encodedAs: mediaType within: aContext [

	etag = ( self entityTagOf: entity encodedAs: mediaType within: aContext )
		ifFalse: [ HTTPClientError preconditionFailed signal ]
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> decode: theRepresentation at: aKey from: sourceMediaType within: aContext [

	^ [ [ ( mappingRuleSet ruleToDecode: sourceMediaType to: aKey )
		applyOn: theRepresentation
		within: aContext
	]
		on: KeyNotFound , NeoJSONParseError
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
	]
		on: MappingNotFound
		do: [ :signal | HTTPClientError unsupportedMediaType signal: signal messageText ]
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> encode: theResource at: aKey to: targetMediaType within: aContext [

	^ [ (mappingRuleSet ruleToEncode: aKey to: targetMediaType)
		applyOn: theResource
		within: aContext ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError unsupportedMediaType signal: signal messageText ]
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> entityTagOf: resource encodedAs: mediaType within: aContext [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> entityTagToMatchBasedOn: anHttpRequest [

	^ ( anHttpRequest headers
		at: #'If-Match'
		ifAbsent: [ HTTPClientError preconditionRequired signal: 'Missing If-Match header.' ] ) asETag
]

{ #category : #'private - querying' }
ResourceRESTfulController >> evaluateQuery: aQueryEvaluationBlock [

	^ [ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
	]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError notFound signal: signal messageText ]
]

{ #category : #'private - API' }
ResourceRESTfulController >> get: aQueryEvaluationBlock asCollectionEncodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| mediaType |

	mediaType := self targetMediaTypeFrom: anHttpRequest.

	^ self
		handleConflictsIn: [ | resourceCollection encodedResourceCollection response |

			resourceCollection := self paginationPolicy evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest.

			self hypermediaPolicy holdCollection: resourceCollection controlsBasedOn: anHttpRequest within: aContext.

			encodedResourceCollection := self
				encode: resourceCollection
				at: aKey
				to: mediaType
				within: aContext.
			response := ZnResponse ok: encodedResourceCollection.
			self paginationPolicy affect: response within: aContext.
			response ]
]

{ #category : #'private - API' }
ResourceRESTfulController >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| mediaType resource response |

	mediaType := self targetMediaTypeFrom: anHttpRequest.

	^ self
		handleConflictsIn: [ resource := self evaluateQuery: aQueryEvaluationBlock.
			self
				ifNoneMatchHeaderPresentIn: anHttpRequest
				do: [ :etag | 
					etag = ( self entityTagOf: resource encodedAs: mediaType within: aContext )
						ifTrue: [ ^ ZnResponse notModified
								setEntityTag: etag;
								yourself
							]
					].

			self hypermediaPolicy holdResource: resource controlsWithin: aContext.
			response := ZnResponse
				ok:
					( self
						encode: resource
						at: aKey
						to: mediaType
						within: aContext ).
			self
				putEntityTagOf: resource
				encodedAs: mediaType
				in: response
				within: aContext.
			response
			]
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> handleConflictsIn: aBlock [

	^ aBlock
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError conflict signal: signal messageText ]
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> hypermediaPolicy [

	hypermediaPolicy ifNil: [ hypermediaPolicy := self provideHypermediaPolicy ].
	^ hypermediaPolicy
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> ifNoneMatchHeaderPresentIn: anHttpRequest do: aMonadycBlock [

	anHttpRequest headers at: #'If-None-Match' ifPresent: [ :ifNoneMatchHeader | aMonadycBlock value: ifNoneMatchHeader asETag ]
]

{ #category : #initialization }
ResourceRESTfulController >> initialize [

	super initialize.
	mappingRuleSet := self specification mappingRuleSet.
	baseUrlOptional := Optional unused.
	acceptNegotiator := RESTfulControllerAcceptNegotiator basedOn: self specification mediaTypes
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> locationOf: resource within: aContext [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> mediaControlsFor: result within: aContext [

	^ {( 'self' -> ( self locationOf: result within: aContext ) )}
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> paginationPolicy [

	paginationPolicy ifNil: [ paginationPolicy := self providePaginationPolicy ].
	^ paginationPolicy
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> provideHypermediaPolicy [

	^ self subclassResponsibility
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> providePaginationPolicy [

	^ self subclassResponsibility
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> provideResourceCreationPolicy [

	^ self subclassResponsibility
]

{ #category : #'private - API' }
ResourceRESTfulController >> putEntityTagOf: resource encodedAs: mediaType in: response within: aContext [

	response setEntityTag: ( self entityTagOf: resource encodedAs: mediaType within: aContext )
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> resourceCreationPolicy [

	resourceCreationPolicy ifNil: [ resourceCreationPolicy := self provideResourceCreationPolicy ].
	^ resourceCreationPolicy
]

{ #category : #configuring }
ResourceRESTfulController >> serverUrl: aServerUrl [

	baseUrlOptional := Optional containing: aServerUrl asZnUrl 
]

{ #category : #specification }
ResourceRESTfulController >> specification [

	^ self subclassResponsibility 
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> targetMediaTypeFrom: anHttpRequest [

	^ acceptNegotiator bestRepresentationFor: anHttpRequest
]

{ #category : #'private - API' }
ResourceRESTfulController >> withCreatedResourceDo: aBlock decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| decodedRepresentation newResource |

	decodedRepresentation := self
		decode: anHttpRequest contents
		at: aKey
		from: anHttpRequest contentType
		within: aContext.

	newResource := self handleConflictsIn: [ aBlock value: decodedRepresentation ].

	^ self resourceCreationPolicy
		responseFor: newResource
		decodedUsing: aKey
		basedOn: anHttpRequest
		within: aContext
]
