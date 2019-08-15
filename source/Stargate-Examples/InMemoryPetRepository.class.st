Class {
	#name : #InMemoryPetRepository,
	#superclass : #Object,
	#instVars : [
		'pets',
		'petById',
		'updateTimestamps',
		'nextId'
	],
	#category : #'Stargate-Examples-PetStore'
}

{ #category : #querying }
InMemoryPetRepository >> count [

	^ pets size
]

{ #category : #querying }
InMemoryPetRepository >> findAll [

	^ pets
]

{ #category : #querying }
InMemoryPetRepository >> findIdentifiedBy: anId [

	^ petById at: anId ifAbsent: [ ObjectNotFound signal ]
]

{ #category : #'private - repository' }
InMemoryPetRepository >> identifierOf: aPet [

	^ petById keyAtValue: aPet
]

{ #category : #initialization }
InMemoryPetRepository >> initialize [

	super initialize.
	pets := OrderedCollection new.
	petById := IdentityDictionary new.
	updateTimestamps := IdentityDictionary new.
	nextId := 1
]

{ #category : #'private - repository' }
InMemoryPetRepository >> lastModificationOf: aPet [

	^ updateTimestamps at: (self identifierOf: aPet)
]

{ #category : #management }
InMemoryPetRepository >> purge: aPet [

	pets remove: aPet
]

{ #category : #'private - repository' }
InMemoryPetRepository >> recordIdAndUpdateTimestampFor: newPet [

	petById at: nextId put: newPet.
	"I will simulate a timestamp using a fixed version revision,
	because for the tests it's easier than using the current datetime"
	updateTimestamps at: nextId put: 1
]

{ #category : #management }
InMemoryPetRepository >> store: aPet [

	pets add: aPet.
	self recordIdAndUpdateTimestampFor: aPet.
	nextId := nextId + 1.
	^ aPet
]

{ #category : #management }
InMemoryPetRepository >> update: pet with: updatedPet [

	pet synchronizeWith: updatedPet.
	updateTimestamps
		at: ( self identifierOf: pet )
		put: ( updateTimestamps at: ( self identifierOf: pet ) ) + 1
]
