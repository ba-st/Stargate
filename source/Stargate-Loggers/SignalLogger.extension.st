Extension { #name : #SignalLogger }

{ #category : #'*Stargate-Loggers' }
SignalLogger class >> availableInStargate [

	^ self allSubclasses select: [ :class | class isAbstract not and: [ class isSupportedInStargate ] ]
]

{ #category : #'*Stargate-Loggers' }
SignalLogger class >> isSupportedInStargate [

	^ false
]

{ #category : #'*Stargate-Loggers' }
SignalLogger >> typeDescription [

	^ self class typeDescription
]
