"
I represent a RESTful Web Service, and provide the base support to easily create specific services.

I provide a way to encode/decode the resources into the representations produced/consumed by the service.
I also provide standard error handling and templates for processing the differente HTTP verbs.
"
Class {
	#name : #RESTfulWebService,
	#superclass : #Object,
	#instVars : [
		'mappingRuleSet'
	],
	#category : #'Stargate-REST-API-Model'
}

{ #category : #'private - transformations' }
RESTfulWebService >> decode: theRepresentation at: aKey from: sourceMediaType within: aContext [

	^ (mappingRuleSet ruleToDecode: sourceMediaType to: aKey)
		applyOn: theRepresentation
		within: aContext
]

{ #category : #'private - transformations' }
RESTfulWebService >> encode: theResource at: aKey to: targetMediaType within: aContext [

	^ [ (mappingRuleSet ruleToEncode: aKey to: targetMediaType) applyOn: theResource within: aContext ]
		on: MappingNotFound
		do: [ :signal | HTTPClientError signalUnsupportedMediaType: signal messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> evaluateQuery: aQueryEvaluationBlock [

	^ [ aQueryEvaluationBlock value ]
		on: TeaNoSuchParam
		do: [ :signal | HTTPClientError signalBadRequest: signal messageText ]
]

{ #category : #'private - API' }
RESTfulWebService >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: httpRequest within: context [

	| mediaType result |

	mediaType := self targetMediaTypeFrom: httpRequest.

	^ [ | encodedResult |

	result := self evaluateQuery: aQueryEvaluationBlock.
	encodedResult := self
		encode: result
		at: aKey
		to: mediaType
		within: context .
	ZnResponse ok: (ZnEntity with: encodedResult ofType: mediaType) ]
		on: ConflictingObjectFound
		do: [ :error | HTTPClientError signalConflict: error messageText ]
]

{ #category : #initialization }
RESTfulWebService >> initialize [

	super initialize.
	mappingRuleSet := (ReflectiveMappingRuleSetBuilder for: self specification) build
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
