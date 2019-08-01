"
I represent an abstract RESTful Controller, and provide the base support to easily create services supporting only GET methods.

I provide: 
- A way to encode the resources into the representations produced by the service.
- Helper methods to respond GET requests both for single resources and collections.
- Affordances for hypermedia controls
- Affordances for pagination
- Content Negotiation

My subclasses must provide:
- A controller specification used to gather the supported media types, and enconding rules and mappings 
- An hypermedia policy controlling the hypermedia support
- A pagination policy controlling whether or not paginate collections
- An ETag calculation methodology
"
Class {
	#name : #ReadOnlyResourceRESTfulController,
	#superclass : #Object,
	#instVars : [
		'mappingRuleSet',
		'baseUrlOptional',
		'acceptNegotiator',
		'hypermediaPolicy',
		'paginationPolicy'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #private }
ReadOnlyResourceRESTfulController >> encode: theResource at: aKey to: targetMediaType within: aContext [

	^ [ (mappingRuleSet ruleToEncode: aKey to: targetMediaType)
		applyOn: theResource
		within: aContext ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError unsupportedMediaType signal: signal messageText ]
]

{ #category : #'private - cache control' }
ReadOnlyResourceRESTfulController >> entityTagOf: resource encodedAs: mediaType within: aContext [

	self subclassResponsibility
]

{ #category : #private }
ReadOnlyResourceRESTfulController >> evaluateQuery: aQueryEvaluationBlock [

	^ [ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError badRequest signal: signal messageText ]
	]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError notFound signal: signal messageText ]
]

{ #category : #'HTTP method helpers' }
ReadOnlyResourceRESTfulController >> get: aQueryEvaluationBlock asCollectionEncodedUsing: aKey basedOn: anHttpRequest within: aContext [

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

{ #category : #'HTTP method helpers' }
ReadOnlyResourceRESTfulController >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

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

{ #category : #private }
ReadOnlyResourceRESTfulController >> handleConflictsIn: aBlock [

	^ aBlock
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError conflict signal: signal messageText ]
]

{ #category : #'private - HATEOAS' }
ReadOnlyResourceRESTfulController >> hypermediaPolicy [

	hypermediaPolicy ifNil: [ hypermediaPolicy := self provideHypermediaPolicy ].
	^ hypermediaPolicy
]

{ #category : #'private - cache control' }
ReadOnlyResourceRESTfulController >> ifNoneMatchHeaderPresentIn: anHttpRequest do: aMonadycBlock [

	anHttpRequest headers at: #'If-None-Match' ifPresent: [ :ifNoneMatchHeader | aMonadycBlock value: ifNoneMatchHeader asETag ]
]

{ #category : #initialization }
ReadOnlyResourceRESTfulController >> initialize [

	super initialize.
	mappingRuleSet := self specification mappingRuleSet.
	baseUrlOptional := Optional unused.
	acceptNegotiator := RESTfulControllerAcceptNegotiator basedOn: self specification mediaTypes
]

{ #category : #private }
ReadOnlyResourceRESTfulController >> locationOf: resource within: aContext [

	self subclassResponsibility
]

{ #category : #'private - HATEOAS' }
ReadOnlyResourceRESTfulController >> mediaControlsFor: result within: aContext [

	^ {( 'self' -> ( self locationOf: result within: aContext ) )}
]

{ #category : #'private - pagination' }
ReadOnlyResourceRESTfulController >> paginationPolicy [

	paginationPolicy ifNil: [ paginationPolicy := self providePaginationPolicy ].
	^ paginationPolicy
]

{ #category : #'private - HATEOAS' }
ReadOnlyResourceRESTfulController >> provideHypermediaPolicy [

	^ self subclassResponsibility
]

{ #category : #'private - pagination' }
ReadOnlyResourceRESTfulController >> providePaginationPolicy [

	^ self subclassResponsibility
]

{ #category : #'private - cache control' }
ReadOnlyResourceRESTfulController >> putEntityTagOf: resource encodedAs: mediaType in: response within: aContext [

	response setEntityTag: ( self entityTagOf: resource encodedAs: mediaType within: aContext )
]

{ #category : #configuring }
ReadOnlyResourceRESTfulController >> serverUrl: aServerUrl [

	baseUrlOptional := Optional containing: aServerUrl asZnUrl 
]

{ #category : #specification }
ReadOnlyResourceRESTfulController >> specification [

	^ self subclassResponsibility 
]

{ #category : #private }
ReadOnlyResourceRESTfulController >> targetMediaTypeFrom: anHttpRequest [

	^ acceptNegotiator bestRepresentationFor: anHttpRequest
]
