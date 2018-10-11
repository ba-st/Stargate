Class {
	#name : #PetsRESTfulWebServiceTest,
	#superclass : #TestCase,
	#instVars : [
		'webService'
	],
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToCreatePetFrom: json [

	^ (ZnRequest post: 'http://BASE_URL/pets')
		entity: (ZnEntity with: json type: webService specification petVersion1dot0dot0MediaType);
		yourself
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToDeletePetIdentifiedBy: id [

	^ TeaRequest fromZnRequest: (ZnRequest delete: ('http://BASE_URL/pets/<1p>' expandMacrosWith: id)) pathParams: {(#identifier -> id)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToGetPetIdentifiedBy: id accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: ('http://BASE_URL/pets/<1p>' expandMacrosWith: id))
				setAccept: anAcceptHeader;
				yourself)
		pathParams: {(#identifier -> id)} asDictionary
]

{ #category : #'private - support' }
PetsRESTfulWebServiceTest >> requestToUpdatePetIdentifiedBy: id statusTo: status [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest patch: ('http://BASE_URL/pets/<1p>' expandMacrosWith: id))
				entity: (ZnEntity with: ('{"status":"<1s>"}' expandMacrosWith: status) type: webService specification petVersion1dot0dot0MediaType);
				yourself)
		pathParams: {(#identifier -> id)} asDictionary
]

{ #category : #running }
PetsRESTfulWebServiceTest >> setUp [
	
	webService := PetsRESTfulWebService new
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
		assert: (response contents includesSubstring: '"identifier":1');
		assert: response contentType asZnMimeType equals: webService specification petVersion1dot0dot0MediaType
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
		assert: (response contents includesSubstring: '"identifier":1');
		assert: (response contents includesSubstring: '"name":"Firulais"');
		deny: (response contents includesSubstring: '"type":"dog"');
		assert: response contentType asZnMimeType equals: webService specification petSummaryVersion1dot0dot0MediaType
]

{ #category : #tests }
PetsRESTfulWebServiceTest >> testPetCreation [

	| petResponse |

	self assert: webService pets isEmpty.

	petResponse := webService createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: HttpRequestContext new.

	self
		assert: petResponse isSuccess;
		assert: petResponse status equals: 201;
		assert: (petResponse location endsWith: '/pets/1');
		assert: petResponse hasEntity;
		assert: webService pets size equals: 1;
		assert: webService pets first identifier equals: 1
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
		assert: (response contents includesSubstring: '"status":"gone"');
		assert: webService pets size equals: 1;
		assert: webService pets first identifier equals: 1;
		assert: webService pets first status equals: 'gone'
]
