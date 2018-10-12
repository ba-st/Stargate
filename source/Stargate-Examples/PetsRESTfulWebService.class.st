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
PetsRESTfulWebService >> createPetBasedOn: anHttpRequest within: aHttpRequestContext [

	^ self
		withCreatedResourceDo: [ :pet | 
			pets add: pet.
			pet at: #status put: 'new'.
			petById at: nextId put: pet.
			nextId := nextId + 1 ]
		decodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aHttpRequestContext
]

{ #category : #API }
PetsRESTfulWebService >> deletePetBasedOn: anHttpRequest within: aHttpRequestContext [

	[ pets remove: (self petIdentifiedUsing: anHttpRequest) ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalNotFound ].

	^ ZnResponse noContent
]

{ #category : #API }
PetsRESTfulWebService >> getPetBasedOn: aHttpRequest within: aHttpRequestContext [

	^ self
		get: [ self petIdentifiedUsing: aHttpRequest ]
		encodedUsing: self specification petMappingKey
		basedOn: aHttpRequest
		within: aHttpRequestContext
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
PetsRESTfulWebService >> petIdentifiedUsing: aHttpRequest [

	^ petById at: (aHttpRequest at: #identifier) ifAbsent: [ ObjectNotFound signal ]
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
				at: #pets
				from: anHttpRequest contentType
				within: aContext.
			pet := self petIdentifiedUsing: anHttpRequest.
			pet at: #status put: (resource at: #status).
			pet ]
		encodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aContext
]
