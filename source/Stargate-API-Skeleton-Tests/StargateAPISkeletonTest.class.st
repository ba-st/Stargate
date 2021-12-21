"
A StargateAPISkeletonTest is a test class for testing the behavior of StargateAPISkeleton
"
Class {
	#name : #StargateAPISkeletonTest,
	#superclass : #TestCase,
	#instVars : [
		'logger',
		'application'
	],
	#category : #'Stargate-API-Skeleton-Tests'
}

{ #category : #private }
StargateAPISkeletonTest >> baseUrl [

	^ application configuration petStore stargate publicURL
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
	String streamContents: [ :stream | 
		| context rootCommand port |

		port := self freeListeningTCPPort.

		rootCommand := LaunchpadRootCommand new.
		context := LaunchpadCommandLineProcessingContext
			           handling: ( CommandLineArguments withArguments: { 
						             'launchpad'.
						             'start'.
						             PetStoreAPI commandName.
						             '--pet-store.stargate.public-url=http://localhost:<1p>' expandMacrosWith: port.
						             '--pet-store.stargate.port=<1p>' expandMacrosWith: port.
						             '--pet-store.stargate.operations-secret=<1s>' expandMacrosWith: self secret } )
			           writingTo: stream.
		self assert: ( rootCommand canHandle: ( context nextCommandLineArgumentIfNone: [ self fail ] ) ).
		rootCommand evaluateWithin: context.
		application := LaunchpadApplication currentlyRunning.
		]
]

{ #category : #running }
StargateAPISkeletonTest >> tearDown [

	application ifNotNil: [ :theApplication | theApplication stop ].
	super tearDown
]

{ #category : #tests }
StargateAPISkeletonTest >> testBadRequest [

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

{ #category : #tests }
StargateAPISkeletonTest >> testConflict [

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

{ #category : #tests }
StargateAPISkeletonTest >> testCreatePet [

	| response json |

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

{ #category : #tests }
StargateAPISkeletonTest >> testGetPets [

	| json |

	json := NeoJSONObject fromString: (self newClient get: self baseUrl / 'pets' asUrl).

	self
		assert: json items isEmpty;
		assert: json links size equals: 1
]

{ #category : #tests }
StargateAPISkeletonTest >> testMethodNotAllowed [

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

{ #category : #tests }
StargateAPISkeletonTest >> testNotAcceptable [

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

{ #category : #tests }
StargateAPISkeletonTest >> testNotFound [

	self should: [ self newClient get: self baseUrl / 'pets/1' asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #tests }
StargateAPISkeletonTest >> testUnsupportedMediaType [

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
