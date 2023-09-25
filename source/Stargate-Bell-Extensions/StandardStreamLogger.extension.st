Extension { #name : 'StandardStreamLogger' }

{ #category : '*Stargate-Bell-Extensions' }
StandardStreamLogger class >> isSupportedInStargate [

	^ true
]

{ #category : '*Stargate-Bell-Extensions' }
StandardStreamLogger class >> typeDescription [

	^ self subclassResponsibility
]
