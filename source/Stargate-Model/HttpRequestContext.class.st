"
I'm a context that gets created each time an Http Request is proceesed. I can carry contextual information to be easily used further in the processing pipeline.
I also provide some facilities to manage Hypermedia Controls.
"
Class {
	#name : #HttpRequestContext,
	#superclass : #Object,
	#instVars : [
		'knownObjects'
	],
	#category : #'Stargate-Model-Routing'
}

{ #category : #pagination }
HttpRequestContext >> addPaginationLink: aUrl relatedTo: aRelationType [

	| controls |

	controls := self
		objectUnder: #paginationLinks
		ifNone: [ self hold: OrderedCollection new under: #paginationLinks ].
	controls
		addAll:
			( MediaControlsBuilder new
				addLink: aUrl relatedTo: aRelationType;
				build )
]

{ #category : #accessing }
HttpRequestContext >> hold: anObject under: aConcept [

	knownObjects at: aConcept put: anObject.
	^ anObject
]

{ #category : #hypermedia }
HttpRequestContext >> holdAsHypermediaControls: aControlCollection for: resource [

	| resourcesHypermediaControls |

	resourcesHypermediaControls := self
		objectUnder: #resourceHypermediaControls
		ifNone: [ self hold: IdentityDictionary new under: #resourceHypermediaControls ].
	resourcesHypermediaControls at: resource put: aControlCollection
]

{ #category : #hypermedia }
HttpRequestContext >> hypermediaControlsFor: resource [

	| hypermediaControls |

	hypermediaControls := self objectUnder: #resourceHypermediaControls ifNone: [ ^ #() ].
	^ hypermediaControls at: resource ifAbsent: [ #() ]
]

{ #category : #authorization }
HttpRequestContext >> includesPermission: aPermission [

	^ ( self objectUnder: #permissions ifNone: [ #() ] ) includes: aPermission
]

{ #category : #initialization }
HttpRequestContext >> initialize [

	super initialize.
	knownObjects := IdentityDictionary new
]

{ #category : #accessing }
HttpRequestContext >> objectUnder: aConcept [

	^ self
		objectUnder: aConcept
		ifNone: [ NotFound signal: ( 'Missing <1s> in the request context' expandMacrosWith: aConcept asString ) ]
]

{ #category : #accessing }
HttpRequestContext >> objectUnder: aConcept ifNone: aBlock [

	^ knownObjects at: aConcept ifAbsent: aBlock
]

{ #category : #pagination }
HttpRequestContext >> paginationControls [

	^ (self objectUnder: #paginationLinks ifNone: [ #() ]) asArray
]

{ #category : #accessing }
HttpRequestContext >> parentResource [

	^ self objectUnder: #parentResource
]

{ #category : #accessing }
HttpRequestContext >> parentResource: anIdentifier [

	self hold: anIdentifier under: #parentResource
]

{ #category : #authorization }
HttpRequestContext >> permissions: aPermissionCollection [

	self hold: aPermissionCollection under: #permissions
]

{ #category : #accessing }
HttpRequestContext >> targetLanguageTag [

	^ self objectUnder: #targetLanguageTag
]

{ #category : #accessing }
HttpRequestContext >> targetLanguageTag: aLanguageTag [

	^ self hold: aLanguageTag under: #targetLanguageTag
]

{ #category : #accessing }
HttpRequestContext >> targetMediaType [

	^ self objectUnder: #targetMediaType
]

{ #category : #accessing }
HttpRequestContext >> targetMediaType: aMediaType [

	^ self hold: aMediaType under: #targetMediaType
]

{ #category : #accessing }
HttpRequestContext >> withTargetLanguageTagDo: aBlock [

	knownObjects at: #targetLanguageTag ifPresent: aBlock
]
