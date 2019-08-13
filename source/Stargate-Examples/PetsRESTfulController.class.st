"
I'm an example RESTful Controller implementing Pet resource management
"
Class {
	#name : #PetsRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'petsRepository',
		'requestHandler'
	],
	#category : #'Stargate-Examples'
}

{ #category : #'instance creation' }
PetsRESTfulController class >> new [

	^ self persistingTo: InMemoryPetRepository new
]

{ #category : #'instance creation' }
PetsRESTfulController class >> persistingTo: aPetRepository [

	^ self basicNew initializePersistingTo: aPetRepository
]

{ #category : #private }
PetsRESTfulController >> addPaginationControlsTo: requestContext basedOn: url start: start limit: limit end: end count: total [

	start = 1
		ifFalse: [ requestContext
				addPaginationLink: ( self urlFrom: url startingAt: 1 limitedTo: limit )
				relatedTo: 'first'
			].
	start > limit
		ifTrue: [ requestContext
				addPaginationLink: ( self urlFrom: url startingAt: start - limit limitedTo: limit )
				relatedTo: 'prev'
			].
	total > end
		ifTrue: [ requestContext
				addPaginationLink: ( self urlFrom: url startingAt: end + 1 limitedTo: limit )
				relatedTo: 'next'
			].
	total = end
		ifFalse: [ requestContext
				addPaginationLink: ( self urlFrom: url startingAt: ( total - 1 ) // limit * limit + 1 limitedTo: limit )
				relatedTo: 'last'
			]
]

{ #category : #private }
PetsRESTfulController >> configurePetEncodingOn: writer within: requestContext [

	writer
		for: Pet
		do: [ :mapping | 
			mapping
				mapInstVars;
				mapAsHypermediaControls: [ :pet | requestContext hypermediaControlsFor: pet ]
			]
]

{ #category : #private }
PetsRESTfulController >> configurePetSummaryEncodingOn: writer within: requestContext [

	writer
		for: Pet
		do: [ :mapping | 
			mapping
				mapInstVar: #name;
				mapAsHypermediaControls: [ :pet | requestContext hypermediaControlsFor: pet ]
			]
]

{ #category : #API }
PetsRESTfulController >> createPetBasedOn: httpRequest within: requestContext [

	^ requestHandler
		withRepresentationIn: httpRequest
		within: requestContext
		createResourceWith:
			[ :decodedRepresentation | Pet named: decodedRepresentation name ofType: decodedRepresentation type ]
		thenDo: [ :pet | petsRepository store: pet ]
]

{ #category : #routes }
PetsRESTfulController >> declareCreatePetRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self createPetBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetsRESTfulController >> declareDeletePetRoute [

	^ RouteSpecification
		handling: #DELETE
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self deletePetBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetsRESTfulController >> declareGetPetRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self getPetBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetsRESTfulController >> declareGetPetsRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self getPetsBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetsRESTfulController >> declareUpdatePetRoute [

	^ RouteSpecification
		handling: #PATCH
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self updatePetBasedOn: httpRequest within: requestContext ]
]

{ #category : #API }
PetsRESTfulController >> deletePetBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		get: [ petsRepository findIdentifiedBy: ( self identifierIn: httpRequest ) ]
		thenDo: [ :pet | petsRepository purge: pet ]
]

{ #category : #API }
PetsRESTfulController >> getPetBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		get: [ petsRepository findIdentifiedBy: ( self identifierIn: httpRequest ) ]
]

{ #category : #API }
PetsRESTfulController >> getPetsBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ :pagination | 
			petsRepository findAll
				ifEmpty: [ #() ]
				ifNotEmpty: [ :allPets | 
					| start end total |

					total := allPets size.
					start := pagination start min: total.
					end := pagination end min: total.
					self
						addPaginationControlsTo: requestContext
						basedOn: httpRequest absoluteUrl
						start: start
						limit: pagination limit
						end: end
						count: total.
					allPets copyFrom: start to: end
					]
			]
]

{ #category : #initialization }
PetsRESTfulController >> initializePersistingTo: aPetRepository [

	petsRepository := aPetRepository.
	self initializeRequestHandler
]

{ #category : #initialization }
PetsRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		endpoint: 'pets';
		calculateLocationUsing: [ :pet :requestContext | petsRepository identifierOf: pet ];
		beHypermediaDriven;
		paginateCollectionsWithDefaultLimit: 5;
		decodeToNeoJSONObjectWhenAccepting: self petVersion1dot0dot0MediaType;
		whenResponding: self petVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | self configurePetEncodingOn: writer within: requestContext ];
		whenResponding: self petSummaryVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | self configurePetSummaryEncodingOn: writer within: requestContext ];
		createEntityTagHashing: [ :hasher :pet :requestContext | 
			hasher
				include: ( petsRepository identifierOf: pet );
				include: ( petsRepository lastModificationOf: pet )
			];
		build
]

{ #category : #'accessing - media types' }
PetsRESTfulController >> petSummaryVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'pet.summary' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #'accessing - media types' }
PetsRESTfulController >> petVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'pet' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #private }
PetsRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
PetsRESTfulController >> typeIdConstraint [

	^ IsInteger
]

{ #category : #API }
PetsRESTfulController >> updatePetBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		get: [ petsRepository findIdentifiedBy: ( self identifierIn: httpRequest ) ]
		thenUpdateWith: [ :pet :decoded | 
			petsRepository
				update: pet
				with:
					( Pet
						named: ( decoded at: #name ifAbsent: [ pet name ] )
						ofType: ( decoded at: #type ifAbsent: [ pet type ] )
						withStatus: ( decoded at: #status ifAbsent: [ pet status ] ) )
			]
]

{ #category : #private }
PetsRESTfulController >> urlFrom: url startingAt: start limitedTo: limit [

	^ url copy
		queryAt: 'start' put: start;
		queryAt: 'limit' put: limit;
		yourself
]
