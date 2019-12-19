"
I'm a builder of caching headers, translating a Smalltalk expression inside a block into a command that adds a cache-control header (and the expires header) to the response before being sent.
"
Class {
	#name : #CachingDirectivesBuilder,
	#superclass : #Object,
	#instVars : [
		'directives'
	],
	#category : #'Stargate-Model-Caching'
}

{ #category : #private }
CachingDirectivesBuilder >> addCacheControlNamed: aName [

	directives
		add: [ :response :context | 
			response headers
				at: 'Cache-Control'
				put: aName
				ifPresentMerge: [ :old :new | '<1s>, <2s>' expandMacrosWith: old with: new ]
			]
]

{ #category : #private }
CachingDirectivesBuilder >> addCacheControlNamed: aName withString: aString [

	self addCacheControlNamed: ( '<1s>="<2s>"' expandMacrosWith: aString )
]

{ #category : #private }
CachingDirectivesBuilder >> addCacheControlNamed: aName withToken: aValue [

	self addCacheControlNamed: ( '<1s>=<2p>' expandMacrosWith: aName with: aValue )
]

{ #category : #configuring }
CachingDirectivesBuilder >> beAvailableFor: aDuration [

	^ self
		bePublic;
		beStaleAfter: aDuration;
		expireIn: aDuration
]

{ #category : #configuring }
CachingDirectivesBuilder >> beImmutable [

	self addCacheControlNamed: 'immutable'
]

{ #category : #configuring }
CachingDirectivesBuilder >> bePublic [

	self addCacheControlNamed: 'public'
]

{ #category : #configuring }
CachingDirectivesBuilder >> beStaleAfter: aDuration [

	self addCacheControlNamed: 'Max-Age' withToken: aDuration asSeconds
]

{ #category : #building }
CachingDirectivesBuilder >> build [

	^ directives
]

{ #category : #configuring }
CachingDirectivesBuilder >> configureUsing: aBlock [

	aBlock cull: self
]

{ #category : #configuring }
CachingDirectivesBuilder >> doNotExpire [

	^ self
		beImmutable;
		beAvailableFor: 1 year
]

{ #category : #configuring }
CachingDirectivesBuilder >> doNotTransform [

	self addCacheControlNamed: 'no-transform'
]

{ #category : #configuring }
CachingDirectivesBuilder >> expireIn: aDuration [

	directives
		add:
			[ :response :context | response headers at: 'Expires' put: ( ZnUtils httpDate: DateAndTime now + aDuration ) ]
]

{ #category : #initialization }
CachingDirectivesBuilder >> initialize [
	
	super initialize.
	directives := OrderedCollection new
]

{ #category : #configuring }
CachingDirectivesBuilder >> mustRevalidate [

	self addCacheControlNamed: 'must-revalidate'
]

{ #category : #configuring }
CachingDirectivesBuilder >> whenSharedBeStaleAfter: aDuration [

	self addCacheControlNamed: 'S-MaxAge' withToken: aDuration asSeconds
]

{ #category : #configuring }
CachingDirectivesBuilder >> whenSharedMustRevalidate [

	self addCacheControlNamed: 'proxy-revalidate'
]
