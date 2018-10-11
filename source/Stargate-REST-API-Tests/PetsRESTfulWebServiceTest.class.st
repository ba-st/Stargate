Class {
	#name : #PetsRESTfulWebServiceTest,
	#superclass : #TestCase,
	#instVars : [
		'webService'
	],
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #support }
PetsRESTfulWebServiceTest >> requestToCreatePetFrom: json [

	^ (ZnRequest post: 'http://BASE_URL/pets')
		entity: (ZnEntity with: json type: webService specification petVersion1dot0dot0MediaType);
		yourself
]

{ #category : #running }
PetsRESTfulWebServiceTest >> setUp [
	
	webService := PetsRESTfulWebService new
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
		assert: petResponse hasEntity
]
