"
I'm a user stoty test testing the service providing the Pet resource, in the classic Pet Store example
"
Class {
	#name : #PetsRESTfulWebServiceTest,
	#superclass : #RESTfulWebServiceTest,
	#category : #'Stargate-Examples-Tests'
}

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> baseUrl [

	^ 'https://pets.example.com' asZnUrl 
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> createPet [

	self
		assert:
			(webService
				createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}')
				within: self newHttpRequestContext) isSuccess
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> createSixPets [

	webService
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Lassie","type":"dog"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Garfield","type":"cat"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Rin Tin Tin","type":"dog"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Babe","type":"pig"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Beethoven","type":"dog"}') within: self newHttpRequestContext.

	self assert: webService pets size equals: 6
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> defaultPetMediaType [

	^ webService specification petVersion1dot0dot0MediaType
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> entityTagOfPetIdentifiedBy: anIdentifier [

	| getResponse |

	getResponse := webService getPetBasedOn: (self requestToGetResourceIdentifiedBy: anIdentifier accepting: self defaultPetMediaType) within: self newHttpRequestContext.
	self assert: getResponse isSuccess.
	^ getResponse headers at: 'ETag'
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestMissingIfMatchHeaderToUpdatePetIdentifiedBy: anIdentifier nameTo: aName [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest patch: (self urlForResourceIdentifiedBy: anIdentifier))
				setAccept: self defaultPetMediaType;
				entity: (ZnEntity with: ('{"name":"<1s>"}' expandMacrosWith: aName) type: self defaultPetMediaType);
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToCreatePetFrom: json [

	^ self requestToPOST: json as: self defaultPetMediaType
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToDeletePetIdentifiedBy: anIdentifier [

	^ TeaRequest fromZnRequest: (ZnRequest delete: (self urlForResourceIdentifiedBy: anIdentifier)) pathParams: {(#identifier -> anIdentifier)} asDictionary
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
PetsRESTfulWebServiceTest >> requestToGetPetsAccepting: anAcceptHeader [

	^ self requestToGet: self resourceUrl accepting: anAcceptHeader
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName [

	^ self requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName using: (self entityTagOfPetIdentifiedBy: anIdentifier)
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName using: anETag [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest patch: (self urlForResourceIdentifiedBy: anIdentifier))
				setAccept: self defaultPetMediaType;
				setIfMatchTo: anETag;
				entity: (ZnEntity with: ('{"name":"<1s>"}' expandMacrosWith: aName) type: self defaultPetMediaType);
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToUpdatePetIdentifiedBy: anIdentifier statusTo: aStatus [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest patch: (self urlForResourceIdentifiedBy: anIdentifier))
				setAccept: self defaultPetMediaType;
				setIfMatchTo: (self entityTagOfPetIdentifiedBy: anIdentifier);
				entity: (ZnEntity with: ('{"status":"<1s>"}' expandMacrosWith: aStatus) type: self defaultPetMediaType);
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #running }
PetsRESTfulWebServiceTest >> setUp [

	super setUp.
	self assert: webService pets isEmpty
]

{ #category : #running }
PetsRESTfulWebServiceTest >> setUpWebService [

	webService := PetsRESTfulWebService new
]

{ #category : #'tests - delete' }
PetsRESTfulWebServiceTest >> testCantDeleteInvalidPet [

	self
		should: [ webService deletePetBasedOn: (self requestToDeletePetIdentifiedBy: 1) within: self newHttpRequestContext ]
		raise: HTTPClientError
		withExceptionDo: [ :signal | self assert: signal code equals: 404 ]
]

{ #category : #'tests - update' }
PetsRESTfulWebServiceTest >> testCantUpdatePetIfMissingETag [

	self
		createPet;
		should: [ webService updatePetBasedOn: (self requestMissingIfMatchHeaderToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta') within: self newHttpRequestContext ]
			raise: HTTPClientError
			withExceptionDo: [ :error | self assert: error code equals: 428 ]
]

{ #category : #'tests - update' }
PetsRESTfulWebServiceTest >> testCantUpdatePetWhenETagNotMatching [

	self
		createPet;
		should: [ webService updatePetBasedOn: (self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta' using: '"Frula"') within: self newHttpRequestContext ]
			raise: HTTPClientError
			withExceptionDo: [ :error | self assert: error code equals: 412 ]
]

{ #category : #'tests - get collection' }
PetsRESTfulWebServiceTest >> testComplexPagination [

	| response |

	self createSixPets.
	"Get the 1st page"
	response := webService getPetsBasedOn: (self requestToGet: 'https://pets.example.com/pets?limit=2' accepting: '*/*') within: self newHttpRequestContext.
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/pets?start=3&limit=2';
		assert: response links first rel equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/pets?start=5&limit=2';
		assert: response links second rel equals: 'last'.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json links self equals: 'https://pets.example.com/pets?limit=2';
				assertUrl: json links next equals: 'https://pets.example.com/pets?start=3&limit=2';
				assertUrl: json links last equals: 'https://pets.example.com/pets?start=5&limit=2';
				assert: json items size equals: 2 ].
	"Get the 2nd page"
	response := webService getPetsBasedOn: (self requestToGet: 'https://pets.example.com/pets?start=3&limit=2' accepting: '*/*') within: self newHttpRequestContext.
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 4;
		assertUrl: response links first url equals: 'https://pets.example.com/pets?start=1&limit=2';
		assert: response links first rel equals: 'first';
		assertUrl: response links second url equals: 'https://pets.example.com/pets?start=1&limit=2';
		assert: response links second rel equals: 'prev';
		assertUrl: response links third url equals: 'https://pets.example.com/pets?start=5&limit=2';
		assert: response links third rel equals: 'next';
		assertUrl: response links last url equals: 'https://pets.example.com/pets?start=5&limit=2';
		assert: response links last rel equals: 'last'.
	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json links self asZnUrl equals: 'https://pets.example.com/pets?start=3&limit=2';
				assertUrl: json links first asZnUrl equals: 'https://pets.example.com/pets?start=1&limit=2';
				assertUrl: json links prev asZnUrl equals: 'https://pets.example.com/pets?start=1&limit=2';
				assertUrl: json links next asZnUrl equals: 'https://pets.example.com/pets?start=5&limit=2';
				assertUrl: json links last asZnUrl equals: 'https://pets.example.com/pets?start=5&limit=2';
				assert: json items size equals: 2 ]
]

{ #category : #'tests - delete' }
PetsRESTfulWebServiceTest >> testDeletePet [

	| response |

	self createPet.

	response := webService deletePetBasedOn: (self requestToDeletePetIdentifiedBy: 1) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 204;
		deny: response hasEntity
]

{ #category : #'tests - get individual' }
PetsRESTfulWebServiceTest >> testGetNotModifiedWhenValidETag [

	| response |

	self createPet.

	response := webService
		getPetBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: self defaultPetMediaType)
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response entityTag equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asETag.

	response := webService
		getPetBasedOn:
			(self
				requestToGetResourceIdentifiedBy: 1
				accepting: self defaultPetMediaType
				conditionalTo: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asETag)
		within: self newHttpRequestContext.

	self
		assert: response code equals: 304;
		assert: response entityTag equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asETag
]

{ #category : #'tests - get individual' }
PetsRESTfulWebServiceTest >> testGetPetJustCreated [

	| response |

	self
		assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: self newHttpRequestContext) isSuccess;
		assert: webService pets size equals: 1.

	response := webService getPetBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: self defaultPetMediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: self defaultPetMediaType;
		assert: response entityTag equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asETag.

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
		should: [ webService getPetBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: '*/*') within: self newHttpRequestContext ]
		raise: HTTPClientError
		withExceptionDo: [ :error | self assert: error code equals: 404 ]
]

{ #category : #'tests - get individual' }
PetsRESTfulWebServiceTest >> testGetPetSummaryJustCreated [

	| response |

	self
		assert: (webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: self newHttpRequestContext) isSuccess;
		assert: webService pets size equals: 1.

	response := webService getPetBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification petSummaryVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response entityTag equals: '"1323cdfb8bb0f9011fbd480c5a87c17d05883214"' asETag.

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

	response := webService getPetsBasedOn: (self requestToGetPetsAccepting: '*/*') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json items isEmpty;
				assertUrl: json links self equals: 'https://pets.example.com/pets' ]
]

{ #category : #'tests - get collection' }
PetsRESTfulWebServiceTest >> testGetPetsNotEmpty [

	| response |

	webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: self newHttpRequestContext.

	self assert: webService pets notEmpty.

	response := webService getPetsBasedOn: (self requestToGetPetsAccepting: '*/*') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			| dogSummary |

			self
				assertUrl: json links self equals: 'https://pets.example.com/pets';
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

	response := webService getPetsBasedOn: (self requestToGetPetsAccepting: '*/*') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/pets?start=6&limit=5';
		assert: response links first rel equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/pets?start=6&limit=5';
		assert: response links second rel equals: 'last'.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json links self equals: 'https://pets.example.com/pets';
				assertUrl: json links next equals: 'https://pets.example.com/pets?start=6&limit=5';
				assertUrl: json links last equals: 'https://pets.example.com/pets?start=6&limit=5';
				assert: json items size equals: 5.

			response := webService getPetsBasedOn: (self requestToGet: json links next accepting: response contentType) within: self newHttpRequestContext.
			self
				assert: response isSuccess;
				assert: response status equals: 200;
				assert: response contentType asMediaType equals: webService specification petSummaryVersion1dot0dot0MediaType;
				assert: response links size equals: 2;
				assertUrl: response links first url equals: 'https://pets.example.com/pets?start=1&limit=5';
				assert: response links first rel equals: 'first';
				assertUrl: response links second url equals: 'https://pets.example.com/pets?start=1&limit=5';
				assert: response links second rel equals: 'prev'.
			self
				withJsonFromContentsIn: response
				do: [ :json2 | 
					self
						assertUrl: json2 links self equals: 'https://pets.example.com/pets?start=6&limit=5';
						assertUrl: json2 links first equals: 'https://pets.example.com/pets?start=1&limit=5';
						assertUrl: json2 links prev equals: 'https://pets.example.com/pets?start=1&limit=5';
						assert: json2 links next isNil;
						assert: json2 links last isNil;
						assert: json2 items size equals: 1 ] ]
]

{ #category : #'tests - creation' }
PetsRESTfulWebServiceTest >> testPetCreation [

	| response |

	response := webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: self newHttpRequestContext.

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

	self
		createPet;
		assert: webService pets first name equals: 'Firulais'.

	response := webService updatePetBasedOn: (self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first name equals: 'Mendieta';
		assert: webService pets first status equals: 'new';
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

	self
		createPet;
		assert: webService pets first status equals: 'new'.

	response := webService updatePetBasedOn: (self requestToUpdatePetIdentifiedBy: 1 statusTo: 'gone') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first name equals: 'Firulais';
		assert: webService pets first status equals: 'gone';
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json name equals: 'Firulais';
				assert: json type equals: 'dog';
				assert: json status equals: 'gone';
				assertUrl: json links self equals: 'https://pets.example.com/pets/1' ]
]
