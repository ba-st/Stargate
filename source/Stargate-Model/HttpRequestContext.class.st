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
HttpRequestContext >> addPaginationControl: aControl [

	| controls |

	controls := self objectUnder: #paginationLinks ifNone: [ self hold: OrderedCollection new under: #paginationLinks ].
	controls add: aControl
]

{ #category : #accessing }
HttpRequestContext >> hold: anObject under: aConcept [

	knownObjects at: aConcept put: anObject.
	^ anObject
]

{ #category : #hypermedia }
HttpRequestContext >> holdAsHypermediaControls: aControlCollection [

	self hold: aControlCollection under: #hypermediaControls
]

{ #category : #hypermedia }
HttpRequestContext >> holdAsHypermediaControls: aControlCollection forSubresource: aResource [

	| subResourcesHypermediaControls |

	subResourcesHypermediaControls := self objectUnder: #subResourceHypermediaControls ifNone: [ self hold: IdentityDictionary new under: #subResourceHypermediaControls ].
	subResourcesHypermediaControls at: aResource put: aControlCollection
]

{ #category : #hypermedia }
HttpRequestContext >> hypermediaControls [

	^ self objectUnder: #hypermediaControls ifNone: [ #() ]
]

{ #category : #hypermedia }
HttpRequestContext >> hypermediaControlsFor: aResource [

	| hypermediaControls |

	hypermediaControls := self objectUnder: #subResourceHypermediaControls ifNone: [ ^ #() ].
	^ hypermediaControls at: aResource ifAbsent: [ #() ]
]

{ #category : #initialization }
HttpRequestContext >> initialize [

	super initialize.
	knownObjects := IdentityDictionary new
]

{ #category : #accessing }
HttpRequestContext >> objectUnder: aConcept [

	^ self objectUnder: aConcept ifNone: [ NotFound signal: ('Missing <1s> in the request context' expandMacrosWith: aConcept asString) ]
]

{ #category : #accessing }
HttpRequestContext >> objectUnder: aConcept ifNone: aBlock [

	^ knownObjects at: aConcept ifAbsent: aBlock
]

{ #category : #pagination }
HttpRequestContext >> paginationControls [

	^ (self objectUnder: #paginationLinks ifNone: [ #() ]) asArray
]
