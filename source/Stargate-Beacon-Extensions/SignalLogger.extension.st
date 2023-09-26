Extension { #name : 'SignalLogger' }

{ #category : '*Stargate-Beacon-Extensions' }
SignalLogger class >> availableInStargate [

	^ self allSubclasses select: [ :class | class isAbstract not and: [ class isSupportedInStargate ] ]
]

{ #category : '*Stargate-Beacon-Extensions' }
SignalLogger class >> isSupportedInStargate [

	^ false
]

{ #category : '*Stargate-Beacon-Extensions' }
SignalLogger >> typeDescription [

	^ self class typeDescription
]
