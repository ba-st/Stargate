"
I'm an example RESTful Web Service implementing Pet resource management
"
Class {
	#name : #PetsRESTfulWebService,
	#superclass : #RESTfulWebService,
	#instVars : [
		'pets',
		'nextId',
		'petById',
		'updateTimestamps'
	],
	#category : #'Stargate-Examples'
}

{ #category : #'private - accessing' }
PetsRESTfulWebService >> addPaginationControlsTo: aContext basedOn: url start: start limit: limit end: end count: total [

	start = 1
		ifFalse: [ aContext addPaginationControl: 'first' -> (self urlFrom: url startingAt: 1 limitedTo: limit) ].
	start > limit
		ifTrue: [ aContext addPaginationControl: 'prev' -> (self urlFrom: url startingAt: start - limit limitedTo: limit) ].
	total > end
		ifTrue: [ aContext addPaginationControl: 'next' -> (self urlFrom: url startingAt: end + 1 limitedTo: limit) ].
	total = end
		ifFalse: [ aContext addPaginationControl: 'last' -> (self urlFrom: url startingAt: (total - 1)// limit * limit + 1 limitedTo: limit) ]
]

{ #category : #API }
PetsRESTfulWebService >> createPetBasedOn: anHttpRequest within: aContext [

	^ self
		withCreatedResourceDo: [ :resource | 
			| newPet |

			newPet := Pet named: resource name ofType: resource type.
			pets add: newPet.
			self recordIdAndUpdateTimestampFor: newPet.
			nextId := nextId + 1.
			newPet ]
		decodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> defaultPaginationLimit [

	^ 5
]

{ #category : #API }
PetsRESTfulWebService >> deletePetBasedOn: anHttpRequest within: aContext [

	[ pets remove: (self petIdentifiedUsing: anHttpRequest) ]
		on: ObjectNotFound
		do: [ :signal | HTTPClientError signalNotFound ].

	^ ZnResponse noContent
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> entityTagOf: aPet encodedAs: mediaType [

	^ (SHA1 new
		hashMessage:
			('<1s>-<2s>-<3s>'
				expandMacrosWith: (self identifierOf: aPet) asString
				with: (self lastModificationOf: aPet) asString
				with: mediaType asString)) hex
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
		get: [ :pagination | 
			self pets
				ifEmpty: [ #() ]
				ifNotEmpty: [ | start end total |

					total := self pets size.
					start := pagination start min: total.
					end := pagination end min: total.
					self
						addPaginationControlsTo: aContext
						basedOn: anHttpRequest absoluteUrl
						start: start
						limit: pagination limit
						end: end
						count: total.
					self pets copyFrom: start to: end ] ]
		asCollectionEncodedUsing: self specification petsMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> identifierOf: aPet [

	^ petById keyAtValue: aPet
]

{ #category : #initialization }
PetsRESTfulWebService >> initialize [

	super initialize.
	pets := OrderedCollection new.
	petById := IdentityDictionary new.
	updateTimestamps := IdentityDictionary new.
	nextId := 1 
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> lastModificationOf: aPet [

	^ updateTimestamps at: (self identifierOf: aPet)
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> locationOf: aPet [

	| baseUrl |

	baseUrl := '' asZnUrl.
	baseUrlOptional withContentDo: [ :theBaseUrl | baseUrl := theBaseUrl ].

	^ baseUrl / self specification endpoint asZnUrl / (self identifierOf: aPet) printString asZnUrl
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> petIdentifiedUsing: anHttpRequest [

	^ petById at: (anHttpRequest at: #identifier) ifAbsent: [ ObjectNotFound signal ]
]

{ #category : #querying }
PetsRESTfulWebService >> pets [

	^ pets
]

{ #category : #'private - state management' }
PetsRESTfulWebService >> recordIdAndUpdateTimestampFor: newPet [

	petById at: nextId put: newPet.
	"I will simulate a timestamp using a fixed version revision,
	because for the tests it's easier that using the current datetime"
	updateTimestamps at: nextId put: 1
]

{ #category : #accessing }
PetsRESTfulWebService >> specification [

	^ PetsRESTfulWebServiceSpecification new
]

{ #category : #'private - state management' }
PetsRESTfulWebService >> updatePet: pet with: resource [

	pet
		synchronizeWith:
			(Pet
				named: (resource at: #name ifAbsent: [ pet name ])
				ofType: (resource at: #type ifAbsent: [ pet type ])
				withStatus: (resource at: #status ifAbsent: [ pet status ])).
	updateTimestamps at: (self identifierOf: pet) put: (updateTimestamps at: (self identifierOf: pet)) + 1
]

{ #category : #API }
PetsRESTfulWebService >> updatePetBasedOn: anHttpRequest within: aContext [

	| etag |

	etag := self entityTagToMatchBasedOn: anHttpRequest.

	^ self
		get: [ | resource pet |

			pet := self petIdentifiedUsing: anHttpRequest.
			self assert: etag matchesEntityTagOf: pet encodedAs: anHttpRequest contentType.
			resource := self
				decode: anHttpRequest contents
				at: self specification petMappingKey
				from: anHttpRequest contentType
				within: aContext.
			self updatePet: pet with: resource.
			pet ]
		encodedUsing: self specification petMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #'private - accessing' }
PetsRESTfulWebService >> urlFrom: url startingAt: start limitedTo: limit [

	^ url copy
		queryAt: 'start' put: start;
		queryAt: 'limit' put: limit;
		yourself
]
