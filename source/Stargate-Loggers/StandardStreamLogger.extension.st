Extension { #name : #StandardStreamLogger }

{ #category : #'*Stargate-Loggers' }
StandardStreamLogger class >> isSupportedInStargate [

	^ true
]

{ #category : #'*Stargate-Loggers' }
StandardStreamLogger class >> typeDescription [

	^ self subclassResponsibility
]
