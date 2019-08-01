"
I represent a RESTful Controller, and provide the base support to easily create specific services.

I provide a way to encode/decode the resources into the representations produced/consumed by the service.
I also provide standard error handling and templates for processing the different HTTP verbs.

In addition to my superclass responsibilities, I will provide:
- A way to decode the representations consumed by the service into the resource
- Resource creation affordances
- Affordances for optimistic concurrency control, by using ETags

My subclasses must provide:
- A resource creation policy controlling the if resource creation must respond with a representation or not
"
Class {
	#name : #ResourceRESTfulController,
	#superclass : #ReadOnlyResourceRESTfulController,
	#instVars : [
		'resourceCreationPolicy'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'private - concurrency control' }
ResourceRESTfulController >> assert: etag matchesEntityTagOf: entity encodedAs: mediaType within: aContext [

	etag = ( self entityTagOf: entity encodedAs: mediaType within: aContext )
		ifFalse: [ HTTPClientError preconditionFailed signal ]
]

{ #category : #private }
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

{ #category : #'private - concurrency control' }
ResourceRESTfulController >> entityTagToMatchBasedOn: anHttpRequest [

	^ ( anHttpRequest headers
		at: #'If-Match'
		ifAbsent: [ HTTPClientError preconditionRequired signal: 'Missing If-Match header.' ] ) asETag
]

{ #category : #private }
ResourceRESTfulController >> provideResourceCreationPolicy [

	^ self subclassResponsibility
]

{ #category : #private }
ResourceRESTfulController >> resourceCreationPolicy [

	resourceCreationPolicy ifNil: [ resourceCreationPolicy := self provideResourceCreationPolicy ].
	^ resourceCreationPolicy
]

{ #category : #'HTTP method helpers' }
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
