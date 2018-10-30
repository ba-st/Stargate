"
I represent a RESTful Web Service, and provide the base support to easily create specific services.

I provide a way to encode/decode the resources into the representations produced/consumed by the service.

I also provide standard error handling and templates for processing the differente HTTP verbs.
"
Class {
	#name : #RESTfulWebService,
	#superclass : #Object,
	#instVars : [
		'mappingRuleSet',
		'baseUrlOptional',
		'acceptNegotiator'
	],
	#category : #'Stargate-Model-Services'
}

{ #category : #'private - asserting' }
RESTfulWebService >> assert: etag matchesEntityTagOf: pet encodedAs: mediaType [

	(etag = (self entityTagOf: pet encodedAs: mediaType))
		ifFalse: [ HTTPClientError signalPreconditionFailed ]
]

{ #category : #'private - transformations' }
RESTfulWebService >> decode: theRepresentation at: aKey from: sourceMediaType within: aContext [

	^ [ [ (mappingRuleSet ruleToDecode: sourceMediaType to: aKey) applyOn: theRepresentation within: aContext ]
		on: KeyNotFound , NeoJSONParseError
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ] ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - accessing' }
RESTfulWebService >> defaultPaginationLimit [

	^ self subclassResponsibility
]

{ #category : #'private - transformations' }
RESTfulWebService >> encode: theResource at: aKey to: targetMediaType within: aContext [

	^ [ (mappingRuleSet ruleToEncode: aKey to: targetMediaType)
		applyOn: theResource
		within: aContext ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - accessing' }
RESTfulWebService >> entityTagOf: resource encodedAs: mediaType [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
RESTfulWebService >> entityTagToMatchBasedOn: anHttpRequest [

	^ (anHttpRequest headers at: #'If-Match' ifAbsent: [ HTTPClientError signalPreconditionRequired: 'Missing If-Match header.' ]) asETag
]

{ #category : #'private - querying' }
RESTfulWebService >> evaluateQuery: aQueryEvaluationBlock [

	^ [ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ] ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalNotFound: signal messageText ]
]

{ #category : #'private - querying' }
RESTfulWebService >> evaluateQuery: aQueryEvaluationBlock accordingTo: aPaginationSpec [

	^ self evaluateQuery: [ aQueryEvaluationBlock cull: aPaginationSpec ]
]

{ #category : #'private - API' }
RESTfulWebService >> get: aQueryEvaluationBlock asCollectionEncodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| mediaType |

	mediaType := self targetMediaTypeFrom: anHttpRequest.

	^ self
		handleConflictsIn: [ | resourceCollection encodedResourceCollection response paginationLinks |

			resourceCollection := self evaluateQuery: aQueryEvaluationBlock accordingTo: (self paginationFrom: anHttpRequest).
			paginationLinks := aContext paginationControls.

			aContext holdAsHypermediaControls: {('self' -> anHttpRequest absoluteUrl)} , paginationLinks.
			resourceCollection do: [ :resource | aContext holdAsHypermediaControls: (self mediaControlsFor: resource) forSubresource: resource ].

			encodedResourceCollection := self
				encode: resourceCollection
				at: aKey
				to: mediaType
				within: aContext.
			response := ZnResponse ok: encodedResourceCollection.
			paginationLinks
				do: [ :assoc | 
					response
						addLink:
							((ZnLink to: assoc value)
								rel: assoc key;
								yourself) ].
			response ]
]

{ #category : #'private - API' }
RESTfulWebService >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

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

			aContext holdAsHypermediaControls: (self mediaControlsFor: resource).
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
RESTfulWebService >> handleConflictsIn: aBlock [

	^ aBlock
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError signalConflict: signal messageText ]
]

{ #category : #'private - accessing' }
RESTfulWebService >> ifNoneMatchHeaderPresentIn: anHttpRequest do: aMonadycBlock [

	anHttpRequest headers at: #'If-None-Match' ifPresent: [ :ifNoneMatchHeader | aMonadycBlock value: ifNoneMatchHeader asETag ]
]

{ #category : #initialization }
RESTfulWebService >> initialize [

	super initialize.
	mappingRuleSet := self specification mappingRuleSet.
	baseUrlOptional := Optional unused.
	acceptNegotiator := RESTfulWebServiceAcceptNegotiator basedOn: self specification mediaTypes
]

{ #category : #'private - accessing' }
RESTfulWebService >> locationOf: resource [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
RESTfulWebService >> mediaControlsFor: result [

	^ {'self' -> (self locationOf: result)}
]

{ #category : #'private - querying' }
RESTfulWebService >> paginationFrom: anHttpRequest [

	^ PaginationSpec
		startingAt: (IsInteger parseString: (anHttpRequest at: #start ifAbsent: [ 1 ]))
		limitedTo: (IsInteger parseString: (anHttpRequest at: #limit ifAbsent: [ self defaultPaginationLimit ]))
]

{ #category : #'private - API' }
RESTfulWebService >> putEntityTagOf: resource encodedAs: mediaType in: response [

	response setEntityTag: (self entityTagOf: resource encodedAs: mediaType)
]

{ #category : #configuring }
RESTfulWebService >> serverUrl: aServerUrl [

	baseUrlOptional := Optional containing: aServerUrl asZnUrl 
]

{ #category : #specification }
RESTfulWebService >> specification [

	^ self subclassResponsibility 
]

{ #category : #'private - transformations' }
RESTfulWebService >> targetMediaTypeFrom: anHttpRequest [

	^ acceptNegotiator bestRepresentationFor: anHttpRequest
]

{ #category : #'private - API' }
RESTfulWebService >> withCreatedResourceDo: aBlock decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| decodedRepresentation newResource |

	decodedRepresentation := self
		decode: anHttpRequest contents
		at: aKey
		from: anHttpRequest contentType
		within: aContext.

	newResource := self handleConflictsIn: [ aBlock value: decodedRepresentation ].

	^ ZnResponse created: (self locationOf: newResource)
]
