"
I represent a RESTful handler, and provide the base support to easily create specific controllers.
I provide the standard machinery to handle REST requests, and I'm supposed to be used from a controller.
"
Class {
	#name : #RESTfulRequestHandlerBehavior,
	#superclass : #Object,
	#instVars : [
		'paginationPolicy',
		'decodingRules',
		'encodingRules',
		'entityTagCalculator',
		'acceptNegotiator',
		'resourceLocator'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #private }
RESTfulRequestHandlerBehavior >> assert: etag matchesEntityTagOf: entity encodedAs: mediaType within: requestContext [

	etag = ( self entityTagOf: entity encodedAs: mediaType within: requestContext )
		ifFalse: [ HTTPClientError preconditionFailed signal ]
]

{ #category : #'decoding/encoding' }
RESTfulRequestHandlerBehavior >> decode: httpRequest within: requestContext [

	| decodingRule |

	decodingRule := decodingRules
		at: httpRequest contentType
		ifAbsent: [ HTTPClientError unsupportedMediaType signal: 'Decoder not found for given media type' ].

	^ self exceptionHandler
		handleDecodingFailedDuring: [ decodingRule cull: httpRequest contents cull: requestContext ]
]

{ #category : #'decoding/encoding' }
RESTfulRequestHandlerBehavior >> encode: resource to: mediaType within: requestContext [

	| encodingRule |

	encodingRule := encodingRules
		at: mediaType
		ifAbsent: [ HTTPClientError unsupportedMediaType signal: 'Encoder not found for given media type' ].

	^ encodingRule encode: resource within: requestContext
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> encodeResource: resource to: mediaType within: requestContext [

	^ self encode: resource to: mediaType within: requestContext
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> encodeResourceCollection: resourceCollection to: mediaType basedOn: httpRequest within: requestContext [

	^ self encode: resourceCollection to: mediaType within: requestContext
]

{ #category : #accessing }
RESTfulRequestHandlerBehavior >> endpoint [

	^ resourceLocator endpoint
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> entityTagOf: resource encodedAs: mediaType within: requestContext [

	^ ZnETag with: ( entityTagCalculator value: resource value: mediaType value: requestContext )
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> entityTagToMatchBasedOn: httpRequest [

	^ ( httpRequest headers
		at: #'If-Match'
		ifAbsent: [ HTTPClientError preconditionRequired signal: 'Missing If-Match header.' ] ) asETag
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> evaluateCollectionQuery: aQueryEvaluationBlock [

	^ self exceptionHandler handleMissingQueryParametersDuring: aQueryEvaluationBlock
]

{ #category : #accessing }
RESTfulRequestHandlerBehavior >> exceptionHandler [

	^ resourceLocator exceptionHandler
]

{ #category : #API }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: aQueryEvaluationBlock [

	| mediaType resource response |

	mediaType := self targetMediaTypeFrom: httpRequest.
	resource := resourceLocator
		lookupResourceIdentifiedBy: httpRequest
		evaluating: aQueryEvaluationBlock.
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

{ #category : #API }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: aQueryEvaluationBlock thenDo: actionBlock [

	| resource |

	resource := resourceLocator
		lookupResourceIdentifiedBy: httpRequest
		evaluating: aQueryEvaluationBlock.
	self exceptionHandler handleConflictsDuring: [ actionBlock value: resource ].
	^ ZnResponse noContent
]

{ #category : #API }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: findBlock thenUpdateWith: updateBlock [

	| etag |

	etag := self entityTagToMatchBasedOn: httpRequest.

	^ self
		from: httpRequest
		within: requestContext
		get: [ :id | 
			| resourceToUpdate updatedResource |

			resourceToUpdate := findBlock cull: id.
			self
				assert: etag
				matchesEntityTagOf: resourceToUpdate
				encodedAs: httpRequest contentType
				within: requestContext.

			updatedResource := self decode: httpRequest within: requestContext.
			self exceptionHandler
				handleConflictsDuring: [ updateBlock value: resourceToUpdate value: updatedResource ]
			]
]

{ #category : #API }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext getCollection: aQueryEvaluationBlock [

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

{ #category : #private }
RESTfulRequestHandlerBehavior >> ifNoneMatchHeaderPresentIn: httpRequest do: aMonadycBlock [

	httpRequest headers at: #'If-None-Match' ifPresent: [ :ifNoneMatchHeader | aMonadycBlock value: ifNoneMatchHeader asETag ]
]

{ #category : #initialization }
RESTfulRequestHandlerBehavior >> initializeResourceLocator: aResouceLocator
	paginationPolicy: aPaginationPolicy
	decodingRules: theDecodingRules
	encodingRules: theEncodingRules
	calculateEntityTagsWith: anEntityTagCalculator
	handleErrorsWith: anExceptionHandler [


	resourceLocator := aResouceLocator.
	resourceLocator handleExceptionsWith: anExceptionHandler.
	paginationPolicy := aPaginationPolicy cull: self.
	decodingRules := theDecodingRules.
	encodingRules := theEncodingRules.
	acceptNegotiator := RESTfulControllerAcceptNegotiator basedOn: encodingRules keys.
	entityTagCalculator := anEntityTagCalculator
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> locationOf: resource within: requestContext [

	^ resourceLocator locationOf: resource within: requestContext
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> paginationPolicy [

	^ paginationPolicy
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> putEntityTagOf: resource encodedAs: mediaType in: response within: requestContext [

	response setEntityTag: ( self entityTagOf: resource encodedAs: mediaType within: requestContext )
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> resourceCreationPolicyBasedOn: httpRequest [

	[ httpRequest accept ]
		on: KeyNotFound
		do: [ :signal | ^ RESTfulControllerDoNotRespondCreatedEntityPolicy for: self ].

	^ RESTfulControllerRespondCreatedEntityPolicy
		for: self
		encodedAs: ( self targetMediaTypeFrom: httpRequest )
]

{ #category : #accessing }
RESTfulRequestHandlerBehavior >> resourceLocator [

	^ resourceLocator
]

{ #category : #accessing }
RESTfulRequestHandlerBehavior >> serverUrl: aServerUrl [

	resourceLocator baseUrl: aServerUrl
]

{ #category : #private }
RESTfulRequestHandlerBehavior >> targetMediaTypeFrom: httpRequest [

	^ acceptNegotiator bestRepresentationFor: httpRequest
]

{ #category : #API }
RESTfulRequestHandlerBehavior >> withRepresentationIn: httpRequest within: requestContext createResourceWith: aCreationBlock thenDo: aBlock [

	^ self
		withResourceCreatedFrom: httpRequest
		within: requestContext
		do: [ :representation | 
			aBlock
				value: ( self exceptionHandler handleDecodingFailedDuring: [ aCreationBlock value: representation ] )
			]
]

{ #category : #API }
RESTfulRequestHandlerBehavior >> withResourceCreatedFrom: httpRequest within: requestContext do: aBlock [

	| creationPolicy decodedRepresentation newResource |

	creationPolicy := self resourceCreationPolicyBasedOn: httpRequest.
	decodedRepresentation := self decode: httpRequest within: requestContext.
	newResource := self exceptionHandler handleConflictsDuring: [ aBlock value: decodedRepresentation ].
	^ creationPolicy responseFor: newResource basedOn: httpRequest within: requestContext
]
