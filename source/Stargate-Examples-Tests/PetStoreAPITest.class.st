"
Test
"
Class {
	#name : #PetStoreAPITest,
	#superclass : #TestCase,
	#instVars : [
		'api'
	],
	#category : #'Stargate-Examples-Tests'
}

{ #category : #private }
PetStoreAPITest >> baseUrl [

	^ 'http://localhost' asUrl port: self port
]

{ #category : #private }
PetStoreAPITest >> newClient [

	^ ZnClient new
		beOneShot;
		enforceHttpSuccess: true;
		yourself
]

{ #category : #private }
PetStoreAPITest >> ordersSpec [

	^ PetOrdersRESTfulControllerSpecification new
]

{ #category : #private }
PetStoreAPITest >> petsSpec [

	^ PetsRESTfulControllerSpecification new
]

{ #category : #private }
PetStoreAPITest >> port [

	^ 9999
]

{ #category : #running }
PetStoreAPITest >> setUp [

	super setUp.
	api := HTTPBasedRESTfulAPI
		configuredBy:
			{(#port -> self port).
			(#serverUrl -> self baseUrl)}
		installing:
			{PetsRESTfulController new.
			PetOrdersRESTfulController new}.

	api
		install;
		start
]

{ #category : #running }
PetStoreAPITest >> tearDown [

	api ifNotNil: [ api stop ].
	api := nil.
	super tearDown
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testBadRequest [

	self
		should: [ self newClient
				url: self baseUrl / 'orders' asUrl;
				entity: (ZnEntity with: '{xxxx}' ofType: self ordersSpec orderVersion1dot0dot0MediaType);
				post;
				response ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isBadRequest ]
]

{ #category : #'tests - CORS' }
PetStoreAPITest >> testCORSHeadersWhenOriginIsAllowed [

	| response |

	api beCORSAwareAllowing: {self baseUrl}.
	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		headerAt: 'Origin' put: self baseUrl printString;
		get;
		response.

	self
		assert: (response headers at: 'Vary') equals: 'Origin';
		assert: (response headers at: 'Access-Control-Allow-Origin') asUrl equals: self baseUrl
]

{ #category : #'tests - CORS' }
PetStoreAPITest >> testCORSHeadersWhenOriginIsNotAllowed [

	| response |

	api beCORSAwareAllowing: {'https://google.com' asUrl}.
	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		headerAt: 'Origin' put: self baseUrl printString;
		get;
		response.

	self
		should: [ response headers at: 'Vary' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testConflict [

	self newClient
		url: self baseUrl / 'orders' asUrl;
		entity: (ZnEntity with: '{"date":"2018-10-24T18:05:46.418Z","pet":"https://api.example.com/pets/1"}' ofType: self ordersSpec orderVersion1dot0dot0MediaType);
		post.

	self newClient
		url: self baseUrl / 'orders/1/cancel' asUrl;
		post.

	self
		should: [ self newClient
				url: self baseUrl / 'orders/1/complete' asUrl;
				post ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 409 ]
]

{ #category : #tests }
PetStoreAPITest >> testCreatePet [

	| response |

	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		entity: (ZnEntity with: '{"name":"Firulais","type":"dog"}' ofType: self petsSpec petVersion1dot0dot0MediaType);
		post;
		response.

	self
		assert: response isCreated;
		assert: response location equals: 'http://localhost:9999/pets/1'
]

{ #category : #tests }
PetStoreAPITest >> testGetPets [

	| json |

	json := NeoJSONObject fromString: (self newClient get: self baseUrl / 'pets' asUrl).

	self
		assert: json items isEmpty;
		assert: json links size equals: 1
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testMethodNotAllowed [

	self newClient
		url: self baseUrl / 'pets' asUrl;
		entity: (ZnEntity with: '{"name":"Firulais","type":"dog"}' ofType: self petsSpec petVersion1dot0dot0MediaType);
		post.

	self
		should: [ self newClient put: self baseUrl / 'pets/1' asUrl contents: '' ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 405 ]
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testNotAcceptable [

	self
		should: [ self newClient
				setAccept: 'application/xml';
				get: self baseUrl / 'pets' asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response code equals: 406;
				assert: error response hasEntity ]
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testNotFound [

	self 
		should: [ self newClient get: self baseUrl / 'pets/1' asUrl ] 
		raise: ZnHttpUnsuccessful 
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testUnsupportedMediaType [

	self
		should: [ self newClient 
				url: self baseUrl / 'pets' asUrl;
				entity: (ZnEntity json: '{"name":"Firulais","type":"dog"}');
				post ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 415 ]
]
