"
I'm an example RESTful Web Service implementing Pet resource management
"
Class {
	#name : #PetsRESTfulWebService,
	#superclass : #RESTfulWebService,
	#instVars : [
		'pets',
		'nextId',
		'petById'
	],
	#category : #'Stargate-Examples'
}

{ #category : #API }
PetsRESTfulWebService >> createPetBasedOn: anHttpRequest within: aContext [

	^ self
		withCreatedResourceDo: [ :resource | 
			| newPet |

			newPet := Pet named: resource name ofType: resource type.
			pets add: newPet.
			petById at: nextId put: newPet.
			nextId := nextId + 1.
			newPet ]
		decodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #API }
PetsRESTfulWebService >> deletePetBasedOn: anHttpRequest within: aContext [

	[ pets remove: (self petIdentifiedUsing: anHttpRequest) ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalNotFound ].

	^ ZnResponse noContent
]

{ #category : #API }
PetsRESTfulWebService >> getPetBasedOn: anHttpRequest within: aContext [

	^ self
		get: [ self petIdentifiedUsing: anHttpRequest ]
		encodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #API }
PetsRESTfulWebService >> getPetsBasedOn: anHttpRequest within: aContext [

	^ self
		get: [ self pets ]
		asCollectionEncodedUsing: self specification petsMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #initialization }
PetsRESTfulWebService >> initialize [

	super initialize.
	pets := OrderedCollection new.
	petById := IdentityDictionary new.
	nextId := 1 
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> locationOf: aPet [

	| baseUrl |

	baseUrl := '' asZnUrl.
	baseUrlOptional withContentDo: [ :theBaseUrl | baseUrl := theBaseUrl ].

	^ '<1p>/<2p>' expandMacrosWith: baseUrl / self specification endpoint asZnUrl with: (petById keyAtValue: aPet)
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> petIdentifiedUsing: anHttpRequest [

	^ petById at: (anHttpRequest at: #identifier) ifAbsent: [ ObjectNotFound signal ]
]

{ #category : #querying }
PetsRESTfulWebService >> pets [

	^ pets
]

{ #category : #accessing }
PetsRESTfulWebService >> specification [

	^ PetsRESTfulWebServiceSpecification new
]

{ #category : #API }
PetsRESTfulWebService >> updatePetStatusBasedOn: anHttpRequest within: aContext [

	^ self
		get: [ | resource pet |

			resource := self
				decode: anHttpRequest contents
				at: self specification petMappingKey
				from: anHttpRequest contentType
				within: aContext.
			pet := self petIdentifiedUsing: anHttpRequest.
			pet synchronizeWith: (Pet named: (resource at: #name ifAbsent: [ pet name ]) ofType: (resource at: #type ifAbsent: [ pet type ]) withStatus: (resource at: #status ifAbsent: [ pet status ])).
			pet ]
		encodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aContext
]
