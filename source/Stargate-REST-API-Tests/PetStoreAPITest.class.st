"
Test
"
Class {
	#name : #PetStoreAPITest,
	#superclass : #TestCase,
	#instVars : [
		'api'
	],
	#category : #'Stargate-REST-API-Tests-PetStore'
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
			{PetsRESTfulWebService new.
			PetOrdersRESTfulWebService new}.

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

{ #category : #tests }
PetStoreAPITest >> testCantCreatePetWithInvalidContentType [

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

{ #category : #tests }
PetStoreAPITest >> testCreatePet [

	| response |

	response := self newClient
		url: self baseUrl / 'pets' asUrl;
		entity: (ZnEntity with: '{"name":"Firulais","type":"dog"}' ofType: PetsRESTfulWebServiceSpecification new petVersion1dot0dot0MediaType);
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
