"
I'm a user stoty test testing the service providing the Pet resource, in the classic Pet Store example
"
Class {
	#name : #PetsRESTfulWebServiceTest,
	#superclass : #TestCase,
	#instVars : [
		'webService'
	],
	#category : #'Stargate-REST-API-Tests-PetStore'
}

{ #category : #'private - asserting' }
PetsRESTfulWebServiceTest >> assertUrl: aStringOrUrl equals: anotherStringOrUrl [

	self assert: aStringOrUrl asZnUrl equals: anotherStringOrUrl asZnUrl
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> baseUrl [

	^ 'https://pets.example.com' asZnUrl 
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> createSixPets [

	webService
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Lassie","type":"dog"}') within: HttpRequestContext new;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Garfield","type":"cat"}') within: HttpRequestContext new;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Rin Tin Tin","type":"dog"}') within: HttpRequestContext new;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Babe","type":"pig"}') within: HttpRequestContext new;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Beethoven","type":"dog"}') within: HttpRequestContext new.

	self assert: webService pets size equals: 6
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> petsUrl [

	^ self baseUrl / '/pets/' asZnUrl
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToCreatePetFrom: aJson [

	^ (ZnRequest post: self petsUrl)
		entity: (ZnEntity with: aJson type: webService specification petVersion1dot0dot0MediaType);
		yourself
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToDeletePetIdentifiedBy: anIdentifier [

	^ TeaRequest fromZnRequest: (ZnRequest delete: (self urlForPetIdentifiedBy: anIdentifier)) pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToGet: aUrl accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: aUrl)
				setAccept: anAcceptHeader;
				yourself)
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToGetPetIdentifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: (self urlForPetIdentifiedBy: anIdentifier))
				setAccept: anAcceptHeader;
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToGetPetsAccepting: anAcceptHeader [

	^ self requestToGet: self petsUrl accepting: anAcceptHeader
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest patch: (self urlForPetIdentifiedBy: anIdentifier))
				entity: (ZnEntity with: ('{"name":"<1s>"}' expandMacrosWith: aName) type: webService specification petVersion1dot0dot0MediaType);
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToUpdatePetIdentifiedBy: anIdentifier statusTo: aStatus [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest patch: (self urlForPetIdentifiedBy: anIdentifier))
				entity: (ZnEntity with: ('{"status":"<1s>"}' expandMacrosWith: aStatus) type: webService specification petVersion1dot0dot0MediaType);
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #running }
PetsRESTfulWebServiceTest >> setUp [

	webService := PetsRESTfulWebService new.
	webService serverUrl: self baseUrl asZnUrl.
	self assert: webService pets isEmpty
]

{ #category : #'tests - delete' }
PetsRESTfulWebServiceTest >> testCantDeleteInvalidPet [

	self should: [ webService deletePetBasedOn: (self requestToDeletePetIdentifiedBy: 1) within: HttpRequestContext new ] raise: HTTPClientError withExceptionDo: [ :signal | self assert: signal code equals: 404 ]
]

{ #category : #'tests - get collection' }
PetsRESTfulWebServiceTest >> testComplexPagination [

	| response |

	self createSixPets.
	"Get the 1st page"
	response := webService getPetsBasedOn: (self requestToGet: 'https://pets.example.com/pets/?limit=2' accepting: '*/*') within: HttpRequestContext new.
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/pets/?start=3&limit=2';
		assert: response links first rel equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/pets/?start=5&limit=2';
		assert: response links second rel equals: 'last'.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json links self equals: 'https://pets.example.com/pets/?limit=2';
				assertUrl: json links next equals: 'https://pets.example.com/pets/?start=3&limit=2';
				assertUrl: json links last equals: 'https://pets.example.com/pets/?start=5&limit=2';
				assert: json items size equals: 2 ].
	"Get the 2nd page"
	response := webService getPetsBasedOn: (self requestToGet: 'https://pets.example.com/pets/?start=3&limit=2' accepting: '*/*') within: HttpRequestContext new.
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 4;
		assertUrl: response links first url equals: 'https://pets.example.com/pets/?start=1&limit=2';
		assert: response links first rel equals: 'first';
		assertUrl: response links second url equals: 'https://pets.example.com/pets/?start=1&limit=2';
		assert: response links second rel equals: 'prev';
		assertUrl: response links third url equals: 'https://pets.example.com/pets/?start=5&limit=2';
		assert: response links third rel equals: 'next';
		assertUrl: response links last url equals: 'https://pets.example.com/pets/?start=5&limit=2';
		assert: response links last rel equals: 'last'.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json links self asZnUrl equals: 'https://pets.example.com/pets/?start=3&limit=2';
				assertUrl: json links first asZnUrl equals: 'https://pets.example.com/pets/?start=1&limit=2';
				assertUrl: json links prev asZnUrl equals: 'https://pets.example.com/pets/?start=1&limit=2';
				assertUrl: json links next asZnUrl equals: 'https://pets.example.com/pets/?start=5&limit=2';
				assertUrl: json links last asZnUrl equals: 'https://pets.example.com/pets/?start=5&limit=2';
				assert: json items size equals: 2 ]
]

{ #category : #'tests - delete' }
PetsRESTfulWebServiceTest >> testDeletePet [

	| response |

	self
		assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new) isSuccess;
		assert: webService pets size equals: 1.

	response := webService deletePetBasedOn: (self requestToDeletePetIdentifiedBy: 1) within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 204;
		deny: response hasEntity
]

{ #category : #'tests - get individual' }
PetsRESTfulWebServiceTest >> testGetPetJustCreated [

	| response |

	self
		assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new) isSuccess;
		assert: webService pets size equals: 1.

	response := webService getPetBasedOn: (self requestToGetPetIdentifiedBy: 1 accepting: '*/*') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json name equals: 'Firulais';
				assert: json type equals: 'dog';
				assert: json status equals: 'new';
				assertUrl: json links self equals: 'https://pets.example.com/pets/1' ]
]

{ #category : #'tests - get individual' }
PetsRESTfulWebServiceTest >> testGetPetNotFoundShouldFail [

	self
		should: [ webService getPetBasedOn: (self requestToGetPetIdentifiedBy: 1 accepting: '*/*') within: HttpRequestContext new ]
		raise: HTTPClientError
		withExceptionDo: [ :error | self assert: error code equals: 404 ]
]

{ #category : #'tests - get individual' }
PetsRESTfulWebServiceTest >> testGetPetSummaryJustCreated [

	| response |

	self
		assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new) isSuccess;
		assert: webService pets size equals: 1.

	response := webService getPetBasedOn: (self requestToGetPetIdentifiedBy: 1 accepting: webService specification petSummaryVersion1dot0dot0MediaType) within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json name equals: 'Firulais';
				assertUrl: json links self equals: 'https://pets.example.com/pets/1';
				assert: json type isNil;
				assert: json status isNil ]
]

{ #category : #'tests - get collection' }
PetsRESTfulWebServiceTest >> testGetPets [

	| response |

	response := webService getPetsBasedOn: (self requestToGetPetsAccepting: '*/*') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json items isEmpty;
				assertUrl: json links self equals: 'https://pets.example.com/pets/' ]
]

{ #category : #'tests - get collection' }
PetsRESTfulWebServiceTest >> testGetPetsNotEmpty [

	| response |

	webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new.

	self assert: webService pets notEmpty.

	response := webService getPetsBasedOn: (self requestToGetPetsAccepting: '*/*') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			| dogSummary |

			self
				assertUrl: json links self equals: 'https://pets.example.com/pets/';
				assert: json items size equals: 1.
			dogSummary := json items first.
			self
				assert: dogSummary name equals: 'Firulais';
				assertUrl: dogSummary links self equals: 'https://pets.example.com/pets/1';
				assert: dogSummary type isNil ]
]

{ #category : #'tests - get collection' }
PetsRESTfulWebServiceTest >> testGetPetsWithPagination [

	| response |

	self createSixPets.

	response := webService getPetsBasedOn: (self requestToGetPetsAccepting: '*/*') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/pets/?start=6&limit=5';
		assert: response links first rel equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/pets/?start=6&limit=5';
		assert: response links second rel equals: 'last'.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json links self equals: 'https://pets.example.com/pets/';
				assertUrl: json links next equals: 'https://pets.example.com/pets/?start=6&limit=5';
				assertUrl: json links last equals: 'https://pets.example.com/pets/?start=6&limit=5';
				assert: json items size equals: 5.

			response := webService getPetsBasedOn: (self requestToGet: json links next accepting: response contentType) within: HttpRequestContext new.
			self
				assert: response isSuccess;
				assert: response status equals: 200;
				assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType;
				assert: response links size equals: 2;
				assertUrl: response links first url equals: 'https://pets.example.com/pets/?start=1&limit=5';
				assert: response links first rel equals: 'first';
				assertUrl: response links second url equals: 'https://pets.example.com/pets/?start=1&limit=5';
				assert: response links second rel equals: 'prev'.
			self
				withJsonFromContentsIn: response
				do: [ :json2 | 
					self
						assertUrl: json2 links self equals: 'https://pets.example.com/pets/?start=6&limit=5';
						assertUrl: json2 links first equals: 'https://pets.example.com/pets/?start=1&limit=5';
						assertUrl: json2 links prev equals: 'https://pets.example.com/pets/?start=1&limit=5';
						assert: json2 links next isNil;
						assert: json2 links last isNil;
						assert: json2 items size equals: 1 ] ]
]

{ #category : #'tests - creation' }
PetsRESTfulWebServiceTest >> testPetCreation [

	| response |

	response := webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 201;
		assertUrl: response location equals: 'https://pets.example.com/pets/1';
		assert: response hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first name equals: 'Firulais'
]

{ #category : #'tests - update' }
PetsRESTfulWebServiceTest >> testUpdatePetName [

	| response |

	self assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new) isSuccess.

	self assert: webService pets first name equals: 'Firulais'.

	response := webService updatePetStatusBasedOn: (self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first name equals: 'Mendieta';
		assert: webService pets first status equals: 'new'.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json name equals: 'Mendieta';
				assert: json type equals: 'dog';
				assert: json status equals: 'new';
				assertUrl: json links self equals: 'https://pets.example.com/pets/1' ]
]

{ #category : #'tests - update' }
PetsRESTfulWebServiceTest >> testUpdatePetStatus [

	| response |

	self assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new) isSuccess.

	self assert: webService pets first status equals: 'new'.

	response := webService updatePetStatusBasedOn: (self requestToUpdatePetIdentifiedBy: 1 statusTo: 'gone') within: HttpRequestContext new.

	self assert: webService pets first status equals: 'gone'.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first name equals: 'Firulais';
		assert: webService pets first status equals: 'gone'.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json name equals: 'Firulais';
				assert: json type equals: 'dog';
				assert: json status equals: 'gone';
				assertUrl: json links self equals: 'https://pets.example.com/pets/1' ]
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> urlForPetIdentifiedBy: anIdentifier [

	^ self petsUrl / anIdentifier printString asZnUrl
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
