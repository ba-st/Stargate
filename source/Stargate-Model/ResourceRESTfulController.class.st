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
		'hypermediaPolicy'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'private - asserting' }
ResourceRESTfulController >> assert: etag matchesEntityTagOf: entity encodedAs: mediaType [

	(etag = (self entityTagOf: entity encodedAs: mediaType))
		ifFalse: [ HTTPClientError signalPreconditionFailed ]
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> decode: theRepresentation at: aKey from: sourceMediaType within: aContext [

	^ [ [ (mappingRuleSet ruleToDecode: sourceMediaType to: aKey) applyOn: theRepresentation within: aContext ]
		on: KeyNotFound , NeoJSONParseError
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ] ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> encode: theResource at: aKey to: targetMediaType within: aContext [

	^ [ (mappingRuleSet ruleToEncode: aKey to: targetMediaType)
		applyOn: theResource
		within: aContext ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> entityTagOf: resource encodedAs: mediaType [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> entityTagToMatchBasedOn: anHttpRequest [

	^ (anHttpRequest headers at: #'If-Match' ifAbsent: [ HTTPClientError signalPreconditionRequired: 'Missing If-Match header.' ]) asETag
]

{ #category : #'private - querying' }
ResourceRESTfulController >> evaluateQuery: aQueryEvaluationBlock [

	^ [ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ] ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalNotFound: signal messageText ]
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
					etag = (self entityTagOf: resource encodedAs: mediaType)
						ifTrue: [ ^ ZnResponse notModified
								setEntityTag: etag;
								yourself ] ].

			self hypermediaPolicy holdResource: resource controlsWithin: aContext.
			response := ZnResponse
				ok:
					(self
						encode: resource
						at: aKey
						to: mediaType
						within: aContext).
			self putEntityTagOf: resource encodedAs: mediaType in: response.
			response ]
]

{ #category : #'private - transformations' }
ResourceRESTfulController >> handleConflictsIn: aBlock [

	^ aBlock
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError signalConflict: signal messageText ]
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
ResourceRESTfulController >> locationOf: resource [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
ResourceRESTfulController >> mediaControlsFor: result [

	^ {'self' -> (self locationOf: result)}
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

{ #category : #'private - API' }
ResourceRESTfulController >> putEntityTagOf: resource encodedAs: mediaType in: response [

	response setEntityTag: (self entityTagOf: resource encodedAs: mediaType)
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

	^ ZnResponse created: (self locationOf: newResource)
]
