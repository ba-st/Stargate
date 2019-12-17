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

{ #category : #building }
CachingDirectivesBuilder >> build [

	^ directives
]

{ #category : #configuring }
CachingDirectivesBuilder >> configureUsing: aBlock [

	aBlock cull: self
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
	directives := Set new
]
