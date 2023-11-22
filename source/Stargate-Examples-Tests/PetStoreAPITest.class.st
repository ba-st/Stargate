"
Test
"
Class {
	#name : 'PetStoreAPITest',
	#superclass : 'HTTPBasedRESTfulAPITest',
	#instVars : [
		'petsController',
		'ordersController'
	],
	#category : 'Stargate-Examples-Tests-PetStore',
	#package : 'Stargate-Examples-Tests',
	#tag : 'PetStore'
}

{ #category : 'tests - support' }
PetStoreAPITest >> assert: aResponse canBeSharedWithRequestsFrom: anOriginLocation [

	self
		assert: ( aResponse headers at: 'Access-Control-Allow-Origin' )
		equals: anOriginLocation asWebOrigin asString
]

{ #category : 'private' }
PetStoreAPITest >> controllersToInstall [

	^ {petsController.
	ordersController}
]

{ #category : 'private' }
PetStoreAPITest >> port [

	^ 65535
]

{ #category : 'running' }
PetStoreAPITest >> setUpAPI [

	petsController := PetsRESTfulController new.
	ordersController := PetOrdersRESTfulController new.
	super setUpAPI
]

{ #category : 'tests - client errors' }
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

{ #category : 'tests - CORS' }
PetStoreAPITest >> testCORSAllowingAnyOrigin [

	| response |

	api allowCrossOriginSharingApplying: [ :cors | cors allowAnyOrigin ].

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
		            options;
		            response.

	self
		assert: response isNoContent;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'POST, GET'.

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            get;
		            response.

	self
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*'.

	response := self newClient
		            url: self baseUrl / 'pets' / '404' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response isNotFound;
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*'
]

{ #category : 'tests - CORS' }
PetStoreAPITest >> testCORSAllowingExactlyOneOrigin [

	| response |

	api allowCrossOriginSharingApplying: [ :cors | cors allowOnlyFrom: { self baseUrl } ].

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
		            options;
		            response.

	self
		assert: response isNoContent;
		assert: response canBeSharedWithRequestsFrom: self baseUrl;
		assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Origin';
		assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'POST, GET'.

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            get;
		            response.

	self
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Origin';
		assert: response canBeSharedWithRequestsFrom: self baseUrl.

	response := self newClient
		            url: self baseUrl / 'pets' / '404' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response isNotFound;
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Origin';
		assert: response canBeSharedWithRequestsFrom: self baseUrl
]

{ #category : 'tests - CORS' }
PetStoreAPITest >> testCORSAllowingMoreThanOneOrigin [

	| response |

	api allowCrossOriginSharingApplying: [ :cors |
		cors allowOnlyFrom: {
				self baseUrl.
				'http://google.com/' asUrl }
		].

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
		            options;
		            response.

	self
		assert: response isNoContent;
		assert: response canBeSharedWithRequestsFrom: self baseUrl;
		assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
		assert: response varyHeaderNames includes: 'Origin';
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'POST, GET'.

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            get;
		            response.

	self
		assert: response varyHeaderNames includes: 'Origin';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: response canBeSharedWithRequestsFrom: self baseUrl.

	response := self newClient
		            url: self baseUrl / 'pets' / '404' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response isNotFound;
		assert: response varyHeaderNames includes: 'Origin';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: response canBeSharedWithRequestsFrom: self baseUrl
]

{ #category : 'tests - CORS' }
PetStoreAPITest >> testCORSOptionalHeaders [

	| response |

	api allowCrossOriginSharingApplying: [ :cors |
		cors
			allowAnyOrigin;
			allowCredentials;
			expireIn: 600 seconds;
			expose: #( 'Authorization' 'X-Custom' )
		].

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
		            options;
		            response.

	self
		assert: response isNoContent;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
		assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'POST, GET';
		assert: ( response headers at: 'Access-Control-Expose-Headers' )
		equals: 'Authorization, X-Custom';
		assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
		assert: ( response headers at: 'Access-Control-Max-Age' ) equals: '600';
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers'.

	response := self newClient
		            url: self baseUrl / 'pets' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            get;
		            response.

	self
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound;
		assert: ( response headers at: 'Access-Control-Expose-Headers' )
		equals: 'Authorization, X-Custom';
		assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
		should: [ response headers at: 'Access-Control-Max-Age' ] raise: KeyNotFound;
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers'.

	response := self newClient
		            url: self baseUrl / 'pets' / '404' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response isNotFound;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound;
		assert: ( response headers at: 'Access-Control-Expose-Headers' )
		equals: 'Authorization, X-Custom';
		assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
		should: [ response headers at: 'Access-Control-Max-Age' ] raise: KeyNotFound;
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers'
]

{ #category : 'tests - CORS' }
PetStoreAPITest >> testCORSRespondWithEmptyHeadersIfOriginNotAllowed [

	| response |

	api allowCrossOriginSharingApplying: [ :cors | cors allowOnlyFrom: {'https://google.com' asUrl} ].

	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		headerAt: 'Origin' put: self baseUrl printString;
		headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
		options;
		response.

	self
		assert: response isNoContent;
		should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound.

	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		headerAt: 'Origin' put: self baseUrl printString;
		get;
		response.

	self
		assert: response varyHeaderNames isEmpty;
		should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound
]

{ #category : 'tests - client errors' }
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

{ #category : 'tests' }
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
		assert: response location equals: ( self baseUrl / 'pets' / '1' ) asString;
		assert: response contentType equals: petsController petVersion1dot0dot0MediaType.

	json := NeoJSONObject fromString: response contents.
	self
		assert: json status equals: 'new';
		assert: json name equals: 'Firulais';
		assert: json type equals: 'dog';
		assert: json selfLocation equals: response location
]

{ #category : 'tests' }
PetStoreAPITest >> testGetPets [

	| json |

	json := NeoJSONObject fromString: (self newClient get: self baseUrl / 'pets' asUrl).

	self
		assert: json items isEmpty;
		assert: json links size equals: 1
]

{ #category : 'tests - client errors' }
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

{ #category : 'tests - client errors' }
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

{ #category : 'tests - client errors' }
PetStoreAPITest >> testNotFound [

	self 
		should: [ self newClient get: self baseUrl / 'pets/1' asUrl ] 
		raise: ZnHttpUnsuccessful 
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : 'tests - client errors' }
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
