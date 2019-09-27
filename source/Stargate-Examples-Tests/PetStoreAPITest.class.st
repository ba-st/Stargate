"
Test
"
Class {
	#name : #PetStoreAPITest,
	#superclass : #HTTPBasedRESTfulAPITest,
	#instVars : [
		'petsController',
		'ordersController'
	],
	#category : #'Stargate-Examples-Tests-PetStore'
}

{ #category : #private }
PetStoreAPITest >> controllersToInstall [

	^ {petsController.
	ordersController}
]

{ #category : #private }
PetStoreAPITest >> port [

	^ 9999
]

{ #category : #running }
PetStoreAPITest >> setUpAPI [

	petsController := PetsRESTfulController new.
	ordersController := PetOrdersRESTfulController new.
	super setUpAPI
]

{ #category : #'tests - client errors' }
PetStoreAPITest >> testBadRequest [

	self
		should: [ self newClient
				url: self baseUrl / 'orders' asUrl;
				entity: ( ZnEntity with: '{xxxx}' ofType: ordersController orderVersion1dot0dot0MediaType );
				post;
				response
			]
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
		entity:
			( ZnEntity
				with: '{"date":"2018-10-24T18:05:46.418Z","pet":"https://api.example.com/pets/1"}'
				ofType: ordersController orderVersion1dot0dot0MediaType );
		post.

	self newClient
		url: self baseUrl / 'orders/1/cancel' asUrl;
		post.

	self
		should: [ self newClient
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
PetStoreAPITest >> testCreatePet [

	| response json |

	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		entity:
			( ZnEntity
				with: '{"name":"Firulais","type":"dog"}'
				ofType: petsController petVersion1dot0dot0MediaType );
		setAccept: petsController petVersion1dot0dot0MediaType;
		post;
		response.

	self
		assert: response isCreated;
		assert: response location equals: 'http://localhost:9999/pets/1';
		assert: response contentType equals: petsController petVersion1dot0dot0MediaType.

	json := NeoJSONObject fromString: response contents.
	self
		assert: json status equals: 'new';
		assert: json name equals: 'Firulais';
		assert: json type equals: 'dog';
		assert: json selfLocation equals: response location
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
		entity:
			( ZnEntity
				with: '{"name":"Firulais","type":"dog"}'
				ofType: petsController petVersion1dot0dot0MediaType );
		post.

	self
		should: [ self newClient put: self baseUrl / 'pets/1' asUrl contents: '' ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response isError;
				assert: error response code equals: 405
			]
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
