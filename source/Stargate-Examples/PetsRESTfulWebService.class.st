Class {
	#name : #PetsRESTfulWebService,
	#superclass : #RESTfulWebService,
	#instVars : [
		'pets',
		'nextId'
	],
	#category : #'Stargate-Examples'
}

{ #category : #API }
PetsRESTfulWebService >> createPetBasedOn: anHttpRequest within: aHttpRequestContext [

	^ self
		withCreatedResourceDo: [ :pet | 
			pets add: pet.
			pet at: self specification identifierKey put: nextId.
			nextId := nextId + 1 ]
		decodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aHttpRequestContext
]

{ #category : #initialization }
PetsRESTfulWebService >> initialize [

	super initialize.
	pets := OrderedCollection new.
	nextId := 1 
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> locationOf: aPet [

	^ 'base_url/<1s>/<2p>' expandMacrosWith: self specification endpoint with: (pets indexOf: aPet)
]

{ #category : #querying }
PetsRESTfulWebService >> pets [

	^ pets
]

{ #category : #accessing }
PetsRESTfulWebService >> specification [

	^ PetsRESTfulWebServiceSpecification new
]
