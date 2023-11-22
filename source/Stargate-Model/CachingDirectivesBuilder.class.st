"
I'm a builder of caching headers, translating a Smalltalk expression inside a block into a command that adds a cache-control header (and the expires header) to the response before being sent.
"
Class {
	#name : 'CachingDirectivesBuilder',
	#superclass : 'Object',
	#instVars : [
		'directives',
		'currentCondition'
	],
	#category : 'Stargate-Model-Caching',
	#package : 'Stargate-Model',
	#tag : 'Caching'
}

{ #category : 'private' }
CachingDirectivesBuilder >> addCacheControlNamed: aName [

	| condition |

	condition := currentCondition.
	directives
		add:
			[ :response :context :resource | ( condition cull: response cull: resource ) then: [ response addCachingDirective: aName ] ]
]

{ #category : 'private' }
CachingDirectivesBuilder >> addCacheControlNamed: aName withString: aString [

	self addCacheControlNamed: ( '<1s>="<2s>"' expandMacrosWith: aName with: aString )
]

{ #category : 'private' }
CachingDirectivesBuilder >> addCacheControlNamed: aName withToken: aValue [

	self addCacheControlNamed: ( '<1s>=<2p>' expandMacrosWith: aName with: aValue )
]

{ #category : 'private' }
CachingDirectivesBuilder >> alwaysApplyDirectives [

	currentCondition := [ :response | true ]
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> beAvailableFor: aDuration [

	^ self
		bePublic;
		beStaleAfter: aDuration;
		expireIn: aDuration
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> beImmutable [

	self addCacheControlNamed: 'immutable'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> bePrivate [

	self addCacheControlNamed: 'private'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> bePrivateRestrictedTo: aFieldNameCollection [

	| fieldsString |

	fieldsString := self fieldStringFor: aFieldNameCollection.
	self addCacheControlNamed: 'private' withString: fieldsString
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> bePublic [

	self addCacheControlNamed: 'public'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> beStaleAfter: aDuration [

	self addCacheControlNamed: 'Max-Age' withToken: aDuration asSeconds
]

{ #category : 'building' }
CachingDirectivesBuilder >> build [

	^ directives
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> configureUsing: aBlock [

	aBlock cull: self
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> doNotCache [

	self addCacheControlNamed: 'no-cache'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> doNotCacheRestrictedTo: aFieldNameCollection [

	| fieldsString |

	fieldsString := self fieldStringFor: aFieldNameCollection.
	self addCacheControlNamed: 'no-cache' withString: fieldsString
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> doNotExpire [

	^ self
		beImmutable;
		beAvailableFor: 365000000 seconds
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> doNotStore [

	self addCacheControlNamed: 'no-store'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> doNotTransform [

	self addCacheControlNamed: 'no-transform'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> expireIn: aDuration [

	| condition |

	condition := currentCondition.
	directives
		add: [ :response :context :resource | 
			( condition cull: response cull: resource )
				then: [ response headers at: 'Expires' put: ( ZnUtils httpDate: DateAndTime now + aDuration ) ]
			]
]

{ #category : 'private' }
CachingDirectivesBuilder >> fieldStringFor: aFieldNameCollection [

	^ String
		streamContents: [ :stream | 
			aFieldNameCollection
				do: [ :fieldName | stream nextPutAll: fieldName ]
				separatedBy: [ stream
						nextPut: $,;
						space
					]
			]
]

{ #category : 'initialization' }
CachingDirectivesBuilder >> initialize [

	super initialize.
	directives := OrderedCollection new.
	self alwaysApplyDirectives
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> mustRevalidate [

	self addCacheControlNamed: 'must-revalidate'
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> requireRevalidation [

	self
		doNotCache;
		beStaleAfter: 0 seconds
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> when: aResponseCondition apply: aDirectiveConfiguration [

	[ currentCondition := aResponseCondition.
	aDirectiveConfiguration cull: self
	]
		ensure: [ self alwaysApplyDirectives ]
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> whenSharedBeStaleAfter: aDuration [

	self addCacheControlNamed: 'S-MaxAge' withToken: aDuration asSeconds
]

{ #category : 'configuring' }
CachingDirectivesBuilder >> whenSharedMustRevalidate [

	self addCacheControlNamed: 'proxy-revalidate'
]
