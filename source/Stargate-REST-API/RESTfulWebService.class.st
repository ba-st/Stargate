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

{ #category : #'private - transformations' }
RESTfulWebService >> encode: theResource at: aKey to: targetMediaType within: aContext [

	^ [ (mappingRuleSet ruleToEncode: aKey to: targetMediaType)
		applyOn: theResource
		within: aContext ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> evaluateQuery: aQueryEvaluationBlock [

	^ [ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ] ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalNotFound: signal messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> get: aQueryEvaluationBlock asCollectionEncodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| mediaType result |

	mediaType := self targetMediaTypeFrom: anHttpRequest.

	^ [ | encodedResult |

	result := self evaluateQuery: aQueryEvaluationBlock.
	aContext hold: {('self' -> anHttpRequest absoluteUrl printString)} under: #mediaControls.
	encodedResult := self
		encode: result
		at: aKey
		to: mediaType
		within: aContext.
	ZnResponse ok: encodedResult ]
		on: ConflictingObjectFound
		do: [ :error | HTTPClientError signalConflict: error messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| mediaType result |

	mediaType := self targetMediaTypeFrom: anHttpRequest.

	^ [ | encodedResult |

	result := self evaluateQuery: aQueryEvaluationBlock.
	aContext hold: {('self' -> (self locationOf: result))} under: #mediaControls.
	encodedResult := self
		encode: result
		at: aKey
		to: mediaType
		within: aContext.
	ZnResponse ok: encodedResult ]
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

	| resource |

	resource := self
		decode: anHttpRequest contents
		at: aKey
		from: anHttpRequest contentType
		within: aContext.

	[ aBlock value: resource ]
		on: ConflictingObjectFound
		do: [ :signal | HTTPClientError signalConflict: signal messageText ].

	^ ZnResponse created: (self locationOf: resource)
]
