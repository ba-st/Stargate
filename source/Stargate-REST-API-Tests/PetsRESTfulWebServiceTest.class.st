Class {
	#name : #PetsRESTfulWebServiceTest,
	#superclass : #TestCase,
	#instVars : [
		'webService'
	],
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> baseUrl [

	^ 'https://pets.example.com' asZnUrl 
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

	^ (ZnRequest get: self petsUrl)
		setAccept: anAcceptHeader;
		yourself
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
	webService serverUrl: self baseUrl asZnUrl
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testCantDeleteInvalidPet [

	self assert: webService pets isEmpty.

	self should: [ webService deletePetBasedOn: (self requestToDeletePetIdentifiedBy: 1) within: HttpRequestContext new ] raise: HTTPClientError withExceptionDo: [ :signal | self assert: signal code equals: 404 ]
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testDeletePet [

	| response |

	self assert: webService pets isEmpty.

	self
		assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new) isSuccess;
		assert: webService pets size equals: 1.

	response := webService deletePetBasedOn: (self requestToDeletePetIdentifiedBy: 1) within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 204;
		deny: response hasEntity
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testGetPetJustCreated [

	| response |

	self assert: webService pets isEmpty.

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
				assert: json links self equals: 'https://pets.example.com/pets/1' ]
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testGetPetNotFoundShouldFail [

	self assert: webService pets isEmpty.

	self
		should: [ webService getPetBasedOn: (self requestToGetPetIdentifiedBy: 1 accepting: '*/*') within: HttpRequestContext new ]
		raise: HTTPClientError
		withExceptionDo: [ :error | self assert: error code equals: 404 ]
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testGetPetSummaryJustCreated [

	| response |

	self assert: webService pets isEmpty.

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
				assert: json links self equals: 'https://pets.example.com/pets/1';
				assert: json type isNil ]
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testGetPets [

	| response |

	self assert: webService pets isEmpty.

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
				assert: json links self equals: 'https://pets.example.com/pets/' ]
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testGetPetsNotEmpty [

	| response |

	self assert: webService pets isEmpty.

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
				assert: json links self equals: 'https://pets.example.com/pets/';
				assert: json items size equals: 1.
			dogSummary := json items first.
			self
				assert: dogSummary name equals: 'Firulais';
				assert: dogSummary links self equals: 'https://pets.example.com/pets/1';
				assert: dogSummary type isNil ]
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testPetCreation [

	| response |

	self assert: webService pets isEmpty.

	response := webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new.

	self
		assert: response isSuccess;
		assert: response status equals: 201;
		assert: response location equals: 'https://pets.example.com/pets/1';
		assert: response hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first name equals: 'Firulais'
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testUpdatePetStatus [

	| response |

	self assert: webService pets isEmpty.

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
				assert: json links self equals: 'https://pets.example.com/pets/1' ]
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> urlForPetIdentifiedBy: anIdentifier [

	^ self petsUrl / anIdentifier printString asZnUrl
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
