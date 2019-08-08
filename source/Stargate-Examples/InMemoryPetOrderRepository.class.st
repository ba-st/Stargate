Class {
	#name : #InMemoryPetOrderRepository,
	#superclass : #Object,
	#instVars : [
		'orders',
		'nextId',
		'orderById',
		'orderStatus',
		'updateTimestamps'
	],
	#category : #'Stargate-Examples'
}

{ #category : #querying }
InMemoryPetOrderRepository >> count [

	^ orders size
]

{ #category : #querying }
InMemoryPetOrderRepository >> findAll [

	^ orders
]

{ #category : #querying }
InMemoryPetOrderRepository >> findIdentifiedBy: anId [

	^ orderById at: anId ifAbsent: [ ObjectNotFound signal ]
]

{ #category : #querying }
InMemoryPetOrderRepository >> identifierOf: aPetOrder [

	^ orderById keyAtValue: aPetOrder
]

{ #category : #initialization }
InMemoryPetOrderRepository >> initialize [

	super initialize.
	orders := OrderedCollection new.
	orderById := IdentityDictionary new.
	orderStatus := IdentityDictionary new.
	updateTimestamps := IdentityDictionary new.
	nextId := 1
]

{ #category : #private }
InMemoryPetOrderRepository >> lastModificationOf: aPetOrder [

	^ updateTimestamps at: (self identifierOf: aPetOrder)
]

{ #category : #private }
InMemoryPetOrderRepository >> recordIdAndUpdateTimestampFor: order [

	orderById at: nextId put: order.
	orderStatus at: nextId put: 'registered'.
	"I will simulate a timestamp using a fixed version revision,
	because for the tests it's easier that using the current datetime"
	updateTimestamps at: nextId put: 1
]

{ #category : #querying }
InMemoryPetOrderRepository >> statusOf: anOrder [

	^ orderStatus at: ( self identifierOf: anOrder ) ifAbsent: [ ObjectNotFound signal ]
]

{ #category : #management }
InMemoryPetOrderRepository >> store: aPetOrder [

	orders add: aPetOrder.
	self recordIdAndUpdateTimestampFor: aPetOrder.
	nextId := nextId + 1.
	^ aPetOrder
]

{ #category : #management }
InMemoryPetOrderRepository >> updateStatusOf: order to: aTargetStatus [

	| id |

	AssertionChecker
		enforce: [ aTargetStatus = 'canceled' or: [ ( self statusOf: order ) = 'registered' ] ]
		because: 'Non pending orders cannot be completed.'
		raising: ConflictingObjectFound.
	id := self identifierOf: order.
	orderStatus at: id put: aTargetStatus.
	updateTimestamps at: id put: ( updateTimestamps at: id ) + 1
]
