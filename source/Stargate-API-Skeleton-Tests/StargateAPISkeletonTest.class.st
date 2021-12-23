"
A StargateAPISkeletonTest is a test class for testing the behavior of StargateAPISkeleton
"
Class {
	#name : #StargateAPISkeletonTest,
	#superclass : #TestCase,
	#instVars : [
		'logger',
		'application',
		'port',
		'baseUrl'
	],
	#category : #'Stargate-API-Skeleton-Tests'
}

{ #category : #accessing }
StargateAPISkeletonTest class >> defaultTimeLimit [

	^5 minute
]

{ #category : #private }
StargateAPISkeletonTest >> baseUrl [

	^ baseUrl
]

{ #category : #private }
StargateAPISkeletonTest >> newClient [

	^ ZnClient new
		  beOneShot;
		  enforceHttpSuccess: true;
		  yourself
]

{ #category : #private }
StargateAPISkeletonTest >> orderVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.order+json;version=1.0.0' asMediaType
]

{ #category : #private }
StargateAPISkeletonTest >> petVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType
]

{ #category : #running }
StargateAPISkeletonTest >> runCase [

	self shouldnt: [ super runCase ] raise: Exit
]

{ #category : #private }
StargateAPISkeletonTest >> secret [

	^ 'secret'
]

{ #category : #running }
StargateAPISkeletonTest >> setUp [

	super setUp.
	logger := MemoryLogger new.
	port := self freeListeningTCPPort.
	StargateAPISkeleton logsDirectory ensureCreateDirectory
]

{ #category : #private }
StargateAPISkeletonTest >> start: aLaunchpadApplication withAll: arguments [

	String streamContents: [ :stream | 
		| context rootCommand |


		rootCommand := LaunchpadRootCommand new.
		context := LaunchpadCommandLineProcessingContext
			           handling: ( CommandLineArguments withArguments: { 
						             'launchpad'.
						             'start'.
						             aLaunchpadApplication commandName } , arguments )
			           writingTo: stream.
		self assert: ( rootCommand canHandle: ( context nextCommandLineArgumentIfNone: [ self fail ] ) ).
		rootCommand evaluateWithin: context.
		application := LaunchpadApplication currentlyRunning
		]
]

{ #category : #private }
StargateAPISkeletonTest >> startPetStoreAPI [

	self start: PetStoreAPI withAll: { 
			'--pet-store.stargate.public-url=http://localhost:<1p>' expandMacrosWith: port.
			'--pet-store.stargate.port=<1p>' expandMacrosWith: port.
			'--pet-store.stargate.operations-secret=<1s>' expandMacrosWith: self secret }.
	baseUrl := application configuration petStore stargate publicURL
]

{ #category : #private }
StargateAPISkeletonTest >> startSouthAmericanCurrenciesAPI [

	self start: SouthAmericanCurrenciesAPI withAll: { 
			'--stargate.public-url=http://localhost:<1p>' expandMacrosWith: port.
			'--stargate.port=<1p>' expandMacrosWith: port.
			'--stargate.operations-secret=<1s>' expandMacrosWith: self secret }.
	baseUrl := application configuration stargate publicURL
]

{ #category : #running }
StargateAPISkeletonTest >> tearDown [

	application ifNotNil: [ :theApplication | theApplication stop ].
	super tearDown
]

{ #category : #'tests - application' }
StargateAPISkeletonTest >> testApplicationBaselineName [

	self
		assert: PetStoreAPI applicationBaselineName equals: #BaselineOfStargate;
		assert: SouthAmericanCurrenciesAPI applicationBaselineName equals: #BaselineOfStargate
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testBadRequest [

	self startPetStoreAPI.
	self
		should: [ 
			self newClient
				url: self baseUrl / 'orders' asUrl;
				entity: ( ZnEntity with: '{xxxx}' ofType: self orderVersion1dot0dot0MediaType );
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isBadRequest ]
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testConflict [

	self startPetStoreAPI.
	self newClient
		url: self baseUrl / 'orders' asUrl;
		entity:
			( ZnEntity with: '{"date":"2018-10-24T18:05:46.418Z","pet":"https://api.example.com/pets/1"}'
				  ofType: self orderVersion1dot0dot0MediaType );
		post.

	self newClient
		url: self baseUrl / 'orders/1/cancel' asUrl;
		post.

	self
		should: [ 
			self newClient
				url: self baseUrl / 'orders/1/complete' asUrl;
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 409
			]
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testCreatePet [

	| response json |

	self startPetStoreAPI.
	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            entity:
			            ( ZnEntity with: '{"name":"Firulais","type":"dog"}'
				              ofType: self petVersion1dot0dot0MediaType );
		            setAccept: self petVersion1dot0dot0MediaType;
		            post;
		            response.

	self
		assert: response isCreated;
		assert: response location equals: ( self baseUrl / 'pets' / '1' ) asString;
		assert: response contentType equals: self petVersion1dot0dot0MediaType.

	json := NeoJSONObject fromString: response contents.
	self
		assert: json status equals: 'new';
		assert: json name equals: 'Firulais';
		assert: json type equals: 'dog';
		assert: json selfLocation equals: response location
]

{ #category : #'tests - application' }
StargateAPISkeletonTest >> testFileReferenceToDumpStackTrace [

	| segments |

	segments := PetStoreAPI fileReferenceToDumpStackTrace asPath segments.
	self
		assert: segments size equals: 2;
		assert: segments first equals: 'logs';
		assert: (segments last beginsWith: PetStoreAPI commandName);
		assert: (segments last endsWith: '.fuel')
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testGetCurrencies [

	| currencies |

	self startSouthAmericanCurrenciesAPI.
	currencies := NeoJSONObject fromString: ( self newClient get: self baseUrl / 'currencies' asUrl ).

	self assert: currencies size equals: 11
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testGetPets [

	| json |

	self startPetStoreAPI.
	json := NeoJSONObject fromString: ( self newClient get: self baseUrl / 'pets' asUrl ).

	self
		assert: json items isEmpty;
		assert: json links size equals: 1
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testMethodNotAllowed [

	self startPetStoreAPI.
	self newClient
		url: self baseUrl / 'pets' asUrl;
		entity:
			( ZnEntity with: '{"name":"Firulais","type":"dog"}' ofType: self petVersion1dot0dot0MediaType );
		post.

	self should: [ self newClient put: self baseUrl / 'pets/1' asUrl contents: '' ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 405
			]
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testNotAcceptable [

	self startPetStoreAPI.
	self
		should: [ 
			self newClient
				setAccept: 'application/xml';
				get: self baseUrl / 'pets' asUrl
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response code equals: 406;
				assert: error response hasEntity
			]
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testNotFound [

	self startPetStoreAPI.
	self should: [ self newClient get: self baseUrl / 'pets/1' asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #'tests - application' }
StargateAPISkeletonTest >> testPrintHelpOn [

	| help |

	help := String streamContents: [ :stream | PetStoreAPI printHelpOn: stream ].

	self assert: help equals: ('NAME
		pet-store [<1s>] - A RESTful API for Pet stores
SYNOPSYS
		pet-store --pet-store.stargate.public-url=%<publicURL%> --pet-store.stargate.port=%<port%> --pet-store.stargate.operations-secret=%<operationsSecret%>
PARAMETERS
		--pet-store.stargate.public-url=%<publicURL%>
			Public URL where the API is deployed. Used to create hypermedia links.
		--pet-store.stargate.port=%<port%>
			Listening port.
		--pet-store.stargate.operations-secret=%<operationsSecret%>
			Secret key for checking JWT signatures.
ENVIRONMENT
		PET_STORE__STARGATE__PUBLIC_URL
			Public URL where the API is deployed. Used to create hypermedia links.
		PET_STORE__STARGATE__PORT
			Listening port.
		PET_STORE__STARGATE__OPERATIONS_SECRET
			Secret key for checking JWT signatures.
' expandMacrosWith: PetStoreAPI version)
]

{ #category : #'tests - application' }
StargateAPISkeletonTest >> testStackTraceDumper [

	| dumper result |

	dumper := PetStoreAPI new stackTraceDumper.

	result := [ 1 / 0 ] on: ZeroDivide
		          do: [ :zeroDivide | 
			          dumper dumpStackTraceFor: zeroDivide.
			          zeroDivide return: 5
			          ].
	self assert: result equals: 5
]

{ #category : #'tests - api' }
StargateAPISkeletonTest >> testUnsupportedMediaType [

	self startPetStoreAPI.
	self
		should: [ 
			self newClient
				url: self baseUrl / 'pets' asUrl;
				entity: ( ZnEntity json: '{"name":"Firulais","type":"dog"}' );
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 415
			]
]
