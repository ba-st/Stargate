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
		'baseUrlOptional'
	],
	#category : #'Stargate-REST-API-Model'
}

{ #category : #'private - transformations' }
RESTfulWebService >> decode: theRepresentation at: aKey from: sourceMediaType within: aContext [

	^ [ [ (mappingRuleSet ruleToDecode: sourceMediaType to: aKey)
		applyOn: theRepresentation
		within: aContext ]
		on: KeyNotFound , DecodingFailed
		do: [ :signal | 
			HTTPClientError
				signalBadRequest: ('Expected key <1s> was not found' expandMacrosWith: signal key) ] ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - accessing' }
RESTfulWebService >> defaultPagination [

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

	^ [ | resourceCollection encodedResourceCollection response paginationLinks |

	resourceCollection := self evaluateQuery: aQueryEvaluationBlock accordingTo: (aContext objectUnder: #pagination ifNone: [ self defaultPagination ]).
	paginationLinks := aContext objectUnder: #paginationLinks ifNone: [ #() ].

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
		on: ConflictingObjectFound
		do: [ :error | HTTPClientError signalConflict: error messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| mediaType resource |

	mediaType := self targetMediaTypeFrom: anHttpRequest.

	^ [ 
		resource := self evaluateQuery: aQueryEvaluationBlock.
		aContext holdAsHypermediaControls: (self mediaControlsFor: resource).
		ZnResponse ok: (self encode: resource at: aKey to: mediaType within: aContext) ]
		on: ConflictingObjectFound
		do: [ :error | HTTPClientError signalConflict: error messageText ]
]

{ #category : #initialization }
RESTfulWebService >> initialize [

	super initialize.
	mappingRuleSet := self specification mappingRuleSet.
	baseUrlOptional := Optional unused.
]

{ #category : #'private - accessing' }
RESTfulWebService >> locationOf: resource [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
RESTfulWebService >> mediaControlsFor: result [

	^ {'self' -> (self locationOf: result)}
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

	"This is not quite right because the accept header can include several media types including a priority.
	I'm just extracting the current behavior but this needs to be fixed"

	^ [ anHttpRequest accept asZnMimeType ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> withCreatedResourceDo: aBlock decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| decodedRepresentation newResource |

	decodedRepresentation := self
		decode: anHttpRequest contents
		at: aKey
		from: anHttpRequest contentType
		within: aContext.

	newResource := [ aBlock value: decodedRepresentation ]
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError signalConflict: signal messageText ].

	^ ZnResponse created: (self locationOf: newResource)
]
